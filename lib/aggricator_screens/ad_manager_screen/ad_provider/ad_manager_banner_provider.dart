
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_screen/home_provider/home_provider.dart';
import 'package:provider/provider.dart';

class AdManagerBannerProvider with ChangeNotifier {


  final String adUnitId = '/22387492205,23277683599/id1631068092.Banner0.1747829228';
  ///
  // final String adUnitId = '/6499/example/banner';

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final Map<int, AdManagerBannerAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
  DateTime? impressionLogged;
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;

  Future<void> loadAd(int index, AdSize size) async {
    try {
      requestInitiated = DateTime.now();
      // Clean up existing ad at this index
      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = AdManagerBannerAd(
        adUnitId: adUnitId,
        sizes: [size],
        request: const AdManagerAdRequest(),
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            ads[index] = ad as AdManagerBannerAd;
            adsLoaded[index] = true;
            adCreativeDownloaded = DateTime.now();
            responseReceived = DateTime.now();
            adRendered = DateTime.now();
            debugPrint('✅ Ad loaded at $index (${size.width}x${size.height})');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at $index: ${error.message}');
            notifyListeners();
          },
            onAdImpression: (Ad ad) {
              impressionLogged = DateTime.now();
              _logLatencyMetrics(ad);
            }
        ),
      );

      ads[index] = ad;
      await ad.load();
      debugPrint('🔄 Started loading ad at index $index');
    } catch (e) {
      debugPrint('⚠️ Exception loading ad at $index: $e');
      adErrors[index] = 'Exception: ${e.toString()}';
      notifyListeners();
    }
  }

  void _logLatencyMetrics(Ad ad) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
      final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
      final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;

      mainNavigatorKey.currentContext!.read<HomeProvider>()
          .sendDataToads({
        "ad_source": "AdManagerBanner",
        "user_id":userId.toString(),
        "sdk_ready_time": sdkReadyLatency.toString(),
        "creative_download": creativeDownloadLatency.toString(),
        "render_time": renderLatency.toString(),
        "total_time": totalLatency.toString(),
        "data": "${ad.responseInfo}",
      });
    }
  }
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}