import 'dart:io';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class EpaperShareHelper {
  /// Generates the official app.bigtv24x7.com app link for e-papers using the single e-paper ID
  static String _getEpaperShareLink(Map<String, dynamic> epaper) {
    final String id = epaper['_id']?.toString() ?? epaper['id']?.toString() ?? epaper['epaperId']?.toString() ?? '';
    return "https://app.bigtv24x7.com/epaper?id=$id";
  }

  /// Shares an individual e-paper page image attached with the clickable www.bigtv24x7.com link
  static Future<void> shareIndividualPage({
    required BuildContext context,
    required Map<String, dynamic> epaper,
    required int pageIndex,
  }) async {
    final List<dynamic> paperImages = epaper['paperImages'] as List<dynamic>? ?? [];
    if (paperImages.isEmpty || pageIndex >= paperImages.length) {
      CustomToast.showErrorToast(msg: "No image available to share.");
      return;
    }

    final String imageUrl = paperImages[pageIndex].toString();
    final String editionName = epaper['editionName']?.toString() ?? 'E-Paper';
    final String publishDate = epaper['publishDate']?.toString() ?? '';
    final String title = "$editionName - $publishDate (Page ${pageIndex + 1})";
    final String appLink = _getEpaperShareLink(epaper);
    final String shareText = "$title\n\nView on BigTV App:\n$appLink";

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/epaper_page_${pageIndex + 1}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!context.mounted) return;

        final Size size = MediaQuery.of(context).size;
        try {
          if (Platform.isIOS) {
            await Share.shareXFiles(
              [XFile(file.path)],
              text: shareText,
              sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
            );
          } else {
            const platform = MethodChannel('com.chotanews/whatsapp');
            await platform.invokeMethod('shareToWhatsApp', {'imagePath': file.path, 'text': shareText});
          }
        } catch (_) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
          );
        }
      } else {
        if (context.mounted) {
          CustomToast.showErrorToast(msg: "Failed to download e-paper image.");
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.showErrorToast(msg: "Share failed: $e");
      }
    }
  }

  /// Generates a multi-page PDF of all e-paper pages and shares the document along with the clickable www.bigtv24x7.com link
  static Future<void> shareAsPdf({
    required BuildContext context,
    required Map<String, dynamic> epaper,
  }) async {
    final List<dynamic> paperImages = epaper['paperImages'] as List<dynamic>? ?? [];
    if (paperImages.isEmpty) {
      CustomToast.showErrorToast(msg: "No pages found to generate PDF.");
      return;
    }

    final String editionName = epaper['editionName']?.toString() ?? 'E-Paper';
    final String publishDate = epaper['publishDate']?.toString() ?? '';
    final String appLink = _getEpaperShareLink(epaper);
    final String shareText = "$editionName - $publishDate E-Paper\n\nView on BigTV App:\n$appLink";

    try {
      final pdf = pw.Document();

      for (var i = 0; i < paperImages.length; i++) {
        final String url = paperImages[i].toString();
        if (url.isNotEmpty) {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final Uint8List bytes = response.bodyBytes;
            final pdfImage = pw.MemoryImage(bytes);
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context ctx) {
                  return pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Image(pdfImage, fit: pw.BoxFit.fill),
                  );
                },
              ),
            );
          }
        }
      }

      final tempDir = await getTemporaryDirectory();
      final sanitizedEdition = editionName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final sanitizedDate = publishDate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = "${sanitizedEdition}_${sanitizedDate}_Epaper.pdf";
      final filePath = "${tempDir.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!context.mounted) return;

      final Size size = MediaQuery.of(context).size;
      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        text: shareText,
        subject: shareText,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } catch (e) {
      if (context.mounted) {
        CustomToast.showErrorToast(msg: "PDF generation failed: $e");
      }
    }
  }
}
