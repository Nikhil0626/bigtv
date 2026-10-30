import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class LiveTvShareHelper {
  static const String baseUrl = 'https://app.bigtv24x7.com';
  static const String liveShareUrl = '$baseUrl/live';

  /// Generates the canonical deep link URL for Live TV using app.bigtv24x7.com
  static String getLiveTvShareUrl() => liveShareUrl;

  /// Generates the localized share text with app.bigtv24x7.com deep link
  static String getShareText({
    String channelName = "BIG TV",
    bool? isTelugu,
    String? langCode,
  }) {
    final code = (langCode ?? '').trim().toLowerCase();

    // 1. Explicit Malayalam language check
    if (code == 'ml' || isTelugu == false) {
      return "🔴 ബിഗ് ടിവി തത്സമയ സംപ്രേക്ഷണം കാണുക (24x7 Live News)!\n\n"
          "ലൈവ് കാണാൻ ഇവിടെ ക്ലിക്ക് ചെയ്യുക:\n"
          "$liveShareUrl\n\n"
          "ഏറ്റവും പുതിയ ബ്രേക്കിംഗ് വാർത്തകൾക്കും ലൈവ് അപ്‌ഡേറ്റുകൾക്കുമായി BIG TV ആപ്പ് ഡൗൺലോഡ് ചെയ്യുക:\n"
          "https://play.google.com/store/apps/details?id=com.chotanews";
    }

    // 2. Explicit English language check
    if (code == 'en') {
      return "🔴 Watch $channelName Live 24x7 News Streaming!\n\n"
          "Click here to watch Live in the app:\n"
          "$liveShareUrl\n\n"
          "Download the BIG TV App for latest breaking news and live updates:\n"
          "https://play.google.com/store/apps/details?id=com.chotanews";
    }

    // 3. Telugu language description (default for Telugu or unspecified)
    return "🔴 బిగ్ టీవీ ప్రత్యక్ష ప్రసారం చూడండి (24x7 Live News)!\n\n"
        "లైవ్ చూడటానికి ఇక్కడ క్లిక్ చేయండి:\n"
        "$liveShareUrl\n\n"
        "తాజా బ్రేకింగ్ వార్తలు మరియు లైవ్ అప్‌డేట్స్ కోసం BIG TV యాప్‌ను డౌన్‌లోడ్ చేసుకోండి:\n"
        "https://play.google.com/store/apps/details?id=com.chotanews";
  }

  /// Triggers the system share dialog for Live TV
  static Future<void> shareLiveTv({
    required BuildContext context,
    String channelName = "BIG TV",
    bool? isTelugu,
    String? langCode,
    String source = "player",
  }) async {
    // Capture context properties synchronously before any async gap
    final size = MediaQuery.of(context).size;
    final sharePositionOrigin = Rect.fromLTWH(0, 0, size.width, size.height / 2);

    // Resolve language if not explicitly provided
    String resolvedLang = 'te';
    if (langCode != null && langCode.trim().isNotEmpty) {
      resolvedLang = langCode.trim().toLowerCase();
    } else if (isTelugu != null) {
      resolvedLang = isTelugu ? 'te' : 'ml';
    } else {
      try {
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        resolvedLang = homeProvider.langCode.trim().toLowerCase();
      } catch (_) {
        try {
          final prefs = await SharedPreferences.getInstance();
          resolvedLang = (prefs.getString("selectedLanguageCode") ??
                  prefs.getString("selectedLanguage") ??
                  "te")
              .trim()
              .toLowerCase();
        } catch (_) {
          resolvedLang = 'te';
        }
      }
    }

    final bool effectiveIsTelugu = resolvedLang != 'ml';

    final shareText = getShareText(
      channelName: channelName,
      isTelugu: effectiveIsTelugu,
      langCode: resolvedLang,
    );

    AnalyticsService.instance.track(AnalyticsEventName.liveTvShare, properties: {
      'channel_id': channelName,
      'share_target': 'system_share',
      'share_url': liveShareUrl,
      'source': source,
      'language': resolvedLang,
    });

    try {
      await Share.share(
        shareText,
        subject: 'Watch $channelName Live 24x7',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('LiveTvShareHelper.shareLiveTv error: $e');
    }
  }
}
