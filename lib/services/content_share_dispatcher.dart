import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared helper for capturing or downloading preview imagery and dispatching
/// share intents across WhatsApp and the system share sheet.
class ContentShareDispatcher {
  ContentShareDispatcher({
    http.Client? httpClient,
    Future<Directory> Function()? tempDirectoryProvider,
    Future<void> Function(String imagePath, String text)? whatsAppChannelInvoker,
    Future<void> Function(
      List<XFile> files, {
      String? text,
      String? subject,
      Rect? sharePositionOrigin,
    })? shareXFilesFn,
    Future<void> Function(
      String text, {
      String? subject,
      Rect? sharePositionOrigin,
    })? shareTextFn,
    Future<bool> Function(Uri uri)? canLaunchUrlFn,
    Future<bool> Function(Uri uri)? launchUrlFn,
  })  : _httpClient = httpClient,
        _tempDirectoryProvider = tempDirectoryProvider,
        _whatsAppChannelInvoker = whatsAppChannelInvoker,
        _shareXFilesFn = shareXFilesFn,
        _shareTextFn = shareTextFn,
        _canLaunchUrlFn = canLaunchUrlFn,
        _launchUrlFn = launchUrlFn;

  /// Optional test hook allowing widget/unit tests to intercept share dispatches.
  @visibleForTesting
  static Future<void> Function({
    required String shareText,
    required String subject,
    required bool isWhatsAppOnly,
    String? imagePath,
  })? debugShareOverride;

  final http.Client? _httpClient;
  final Future<Directory> Function()? _tempDirectoryProvider;
  final Future<void> Function(String imagePath, String text)?
      _whatsAppChannelInvoker;
  final Future<void> Function(
    List<XFile> files, {
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  })? _shareXFilesFn;
  final Future<void> Function(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  })? _shareTextFn;
  final Future<bool> Function(Uri uri)? _canLaunchUrlFn;
  final Future<bool> Function(Uri uri)? _launchUrlFn;

  static const MethodChannel _whatsAppChannel =
      MethodChannel('com.chotanews/whatsapp');

  /// Shares formatted content and optional captured/downloaded image via
  /// WhatsApp (with fallback) or the system share sheet.
  Future<void> shareContent({
    required BuildContext context,
    required String shareText,
    required String subject,
    required String filePrefix,
    ScreenshotController? screenshotController,
    String? fallbackImageUrl,
    bool isWhatsAppOnly = false,
  }) async {
    final Size size = MediaQuery.of(context).size;
    final Rect shareOrigin = Rect.fromLTWH(0, 0, size.width, size.height / 2);

    Uint8List? imageBytes;
    if (screenshotController != null && debugShareOverride == null) {
      try {
        imageBytes = await screenshotController
            .capture(
              delay: const Duration(milliseconds: 10),
            )
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            );
      } catch (e) {
        debugPrint('ContentShareDispatcher screenshot capture failed: $e');
      }
    }

    if ((imageBytes == null || imageBytes.isEmpty) &&
        fallbackImageUrl != null &&
        fallbackImageUrl.trim().isNotEmpty) {
      final cleanUrl = fallbackImageUrl.trim();
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        imageBytes = await _downloadImageBytes(cleanUrl);
      }
    }

    File? imageFile;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      imageFile = await _writeTempImage(imageBytes, filePrefix);
    }

    if (debugShareOverride != null) {
      await debugShareOverride!(
        shareText: shareText,
        subject: subject,
        isWhatsAppOnly: isWhatsAppOnly,
        imagePath: imageFile?.path,
      );
      return;
    }

    try {
      if (isWhatsAppOnly) {
        await _dispatchWhatsAppShare(
          shareText: shareText,
          subject: subject,
          shareOrigin: shareOrigin,
          imageFile: imageFile,
        );
      } else {
        await _dispatchSystemShare(
          shareText: shareText,
          subject: subject,
          shareOrigin: shareOrigin,
          imageFile: imageFile,
        );
      }
    } catch (e) {
      debugPrint('ContentShareDispatcher.shareContent error: $e');
      await _shareText(shareText, subject: subject, origin: shareOrigin);
    }
  }

  Future<Uint8List?> _downloadImageBytes(String url) async {
    final client = _httpClient ?? http.Client();
    final shouldClose = _httpClient == null;
    try {
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('ContentShareDispatcher image download failed: $e');
    } finally {
      if (shouldClose) {
        client.close();
      }
    }
    return null;
  }

  Future<File?> _writeTempImage(Uint8List bytes, String filePrefix) async {
    try {
      final tempDir =
          await (_tempDirectoryProvider?.call() ?? getTemporaryDirectory());
      final file = File(
        '${tempDir.path}/${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('ContentShareDispatcher temp image write failed: $e');
      return null;
    }
  }

  Future<void> _dispatchWhatsAppShare({
    required String shareText,
    required String subject,
    required Rect shareOrigin,
    File? imageFile,
  }) async {
    if (imageFile != null && await imageFile.exists()) {
      if (!kIsWeb && Platform.isAndroid) {
        try {
          if (_whatsAppChannelInvoker != null) {
            await _whatsAppChannelInvoker(imageFile.path, shareText);
          } else {
            await _whatsAppChannel.invokeMethod('shareToWhatsApp', {
              'imagePath': imageFile.path,
              'text': shareText,
            });
          }
          return;
        } catch (e) {
          debugPrint('WhatsApp channel fallback to share sheet: $e');
        }
      }

      await _shareFiles(
        [XFile(imageFile.path)],
        text: shareText,
        subject: subject,
        origin: shareOrigin,
      );
      return;
    }

    final Uri whatsappUri =
        Uri.parse('whatsapp://send?text=${Uri.encodeComponent(shareText)}');
    final canLaunch = await (_canLaunchUrlFn?.call(whatsappUri) ??
        canLaunchUrl(whatsappUri));
    if (canLaunch) {
      final launched = await (_launchUrlFn?.call(whatsappUri) ??
          launchUrl(whatsappUri, mode: LaunchMode.externalApplication));
      if (launched) return;
    }

    await _shareText(shareText, subject: subject, origin: shareOrigin);
  }

  Future<void> _dispatchSystemShare({
    required String shareText,
    required String subject,
    required Rect shareOrigin,
    File? imageFile,
  }) async {
    if (imageFile != null && await imageFile.exists()) {
      await _shareFiles(
        [XFile(imageFile.path)],
        text: shareText,
        subject: subject,
        origin: shareOrigin,
      );
      return;
    }

    await _shareText(shareText, subject: subject, origin: shareOrigin);
  }

  Future<void> _shareFiles(
    List<XFile> files, {
    required String text,
    required String subject,
    required Rect origin,
  }) async {
    if (_shareXFilesFn != null) {
      await _shareXFilesFn(
        files,
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      );
      return;
    }
    await Share.shareXFiles(
      files,
      text: text,
      subject: subject,
      sharePositionOrigin: origin,
    );
  }

  Future<void> _shareText(
    String text, {
    required String subject,
    required Rect origin,
  }) async {
    if (_shareTextFn != null) {
      await _shareTextFn(
        text,
        subject: subject,
        sharePositionOrigin: origin,
      );
      return;
    }
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: origin,
    );
  }
}
