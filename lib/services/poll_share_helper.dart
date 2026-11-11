import 'package:chotanews/aggricator_screens/polls_screens/poll_model.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds canonical deep links, localized share copy, and analytics events
/// when sharing Poll cards.
class PollShareHelper {
  static const String baseUrl = 'https://app.bigtv24x7.com';
  static const String _imageHost = 'https://migwp.chotanews.com';

  /// Generates the canonical deep link URL for a poll using app.bigtv24x7.com.
  static String getPollShareUrl(dynamic postId) {
    final id = postId?.toString().trim() ?? '';
    if (id.isNotEmpty && id != '0' && id.toLowerCase() != 'null') {
      return '$baseUrl/polls?postId=$id';
    }
    return '$baseUrl/polls';
  }

  /// Resolves a relative or absolute poll background image URL for sharing.
  static String resolveImageUrl(dynamic imageUrl) {
    final url = imageUrl?.toString().trim() ?? '';
    if (url.isEmpty || url.toLowerCase() == 'null') return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_imageHost$url';
    return '$_imageHost/$url';
  }

  /// Generates localized share text for a poll with options and deep link.
  static String getShareText({
    required Map<String, dynamic> article,
    PollData? pollData,
    String? langCode,
    bool? isTelugu,
  }) {
    final code = _normalizeLanguage(langCode: langCode, isTelugu: isTelugu);
    final postId = article['id'] ?? article['post_id'] ?? article['postId'];
    final shareUrl = getPollShareUrl(postId);

    final rawPollMap = article['pollData'] is Map
        ? Map<String, dynamic>.from(article['pollData'] as Map)
        : (article['poll_data'] is Map
            ? Map<String, dynamic>.from(article['poll_data'] as Map)
            : <String, dynamic>{});

    final title = (article['title'] ?? rawPollMap['title'] ?? '')
        .toString()
        .trim();
    final category =
        (article['category'] ?? article['categoryName'] ?? '').toString().trim();

    final options = _extractOptionTexts(article, rawPollMap, pollData);

    final buffer = StringBuffer();
    if (code == 'ml') {
      buffer.writeln(
        '📊 BIG TV വോട്ടെടുപ്പ്${category.isNotEmpty ? ' ($category)' : ''}',
      );
    } else if (code == 'en') {
      buffer.writeln(
        '📊 BIG TV Poll${category.isNotEmpty ? ' ($category)' : ''}',
      );
    } else {
      buffer.writeln(
        '📊 BIG TV పోల్${category.isNotEmpty ? ' ($category)' : ''}',
      );
    }

    if (title.isNotEmpty) {
      buffer.writeln(title);
    }

    if (options.isNotEmpty) {
      buffer.writeln();
      for (var i = 0; i < options.length; i++) {
        buffer.writeln('${i + 1}. ${options[i]}');
      }
    }

    buffer.writeln();
    if (code == 'ml') {
      buffer.writeln('നിങ്ങളുടെ വോട്ട് രേഖപ്പെടുത്തൂ & തത്സമയ ഫലങ്ങൾ കാണൂ:');
    } else if (code == 'en') {
      buffer.writeln('Cast your vote & view live results on BIG TV:');
    } else {
      buffer.writeln('మీ ఓటు వేయండి & లైవ్ ఫలితాలు చూడండి:');
    }
    buffer.write(shareUrl);

    return buffer.toString();
  }

  /// Shares a poll card via WhatsApp or the system share sheet.
  static Future<void> sharePoll({
    required BuildContext context,
    required Map<String, dynamic> article,
    PollData? pollData,
    ScreenshotController? screenshotController,
    bool isWhatsAppOnly = false,
    String? langCode,
    ContentShareDispatcher? dispatcher,
  }) async {
    final resolvedLang = await _resolveLanguage(context, langCode: langCode);
    if (!context.mounted) return;

    final postId = article['id'] ?? article['post_id'] ?? article['postId'];
    final shareUrl = getPollShareUrl(postId);
    final pollTitle = (article['title'] ?? 'BIG TV Poll').toString().trim();
    final imageUrl =
        resolveImageUrl(article['image_url'] ?? article['imageUrl']);

    final shareText = getShareText(
      article: article,
      pollData: pollData,
      langCode: resolvedLang,
    );

    AnalyticsService.instance.track(
      AnalyticsEventName.pollShare,
      properties: {
        'post_id': postId?.toString() ?? '',
        'poll_title': pollTitle,
        'share_target': isWhatsAppOnly ? 'whatsapp' : 'system_share',
        'share_url': shareUrl,
        'language': resolvedLang,
      },
    );

    final activeDispatcher = dispatcher ?? ContentShareDispatcher();
    await activeDispatcher.shareContent(
      context: context,
      shareText: shareText,
      subject:
          pollTitle.isNotEmpty ? '$pollTitle - BIG TV Poll' : 'BIG TV Poll',
      filePrefix: 'poll',
      screenshotController: screenshotController,
      fallbackImageUrl: imageUrl,
      isWhatsAppOnly: isWhatsAppOnly,
    );
  }

  static List<String> _extractOptionTexts(
    Map<String, dynamic> article,
    Map<String, dynamic> rawPollMap,
    PollData? pollData,
  ) {
    if (pollData != null && pollData.options.isNotEmpty) {
      return pollData.options
          .map((o) => o.text.trim())
          .where((t) => t.isNotEmpty)
          .take(4)
          .toList();
    }

    final rawOpts = (rawPollMap['options'] is List &&
            (rawPollMap['options'] as List).isNotEmpty)
        ? rawPollMap['options'] as List
        : (article['poll_options'] is List &&
                (article['poll_options'] as List).isNotEmpty)
            ? article['poll_options'] as List
            : (article['options'] is List &&
                    (article['options'] as List).isNotEmpty)
                ? article['options'] as List
                : const [];

    final texts = <String>[];
    for (final opt in rawOpts) {
      if (opt is Map) {
        final txt = (opt['text'] ??
                opt['option_name'] ??
                opt['name'] ??
                opt['title'] ??
                '')
            .toString()
            .trim();
        if (txt.isNotEmpty) texts.add(txt);
      } else {
        final txt = opt.toString().trim();
        if (txt.isNotEmpty) texts.add(txt);
      }
      if (texts.length >= 4) break;
    }
    return texts;
  }

  static String _normalizeLanguage({String? langCode, bool? isTelugu}) {
    final code = (langCode ?? '').trim().toLowerCase();
    if (code.isNotEmpty) return code;
    if (isTelugu != null) return isTelugu ? 'te' : 'ml';
    return 'te';
  }

  static Future<String> _resolveLanguage(
    BuildContext context, {
    String? langCode,
  }) async {
    if (langCode != null && langCode.trim().isNotEmpty) {
      return langCode.trim().toLowerCase();
    }
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.langCode.trim().isNotEmpty) {
        return homeProvider.langCode.trim().toLowerCase();
      }
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getString('selectedLanguageCode') ??
              prefs.getString('selectedLanguage') ??
              'te')
          .trim()
          .toLowerCase();
    } catch (_) {
      return 'te';
    }
  }
}

