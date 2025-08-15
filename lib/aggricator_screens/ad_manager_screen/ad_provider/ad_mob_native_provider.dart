import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdMobNativeProvider with ChangeNotifier {
  final Map<int, NativeAd?> nativeAds = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, String> adErrors = {};
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
  final String adUnitId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId;

  Future<void> loadAd(int index, AdSize mediumRectangle) async {
    log(" ad id show $adUnitId");
    try {
      requestInitiated = DateTime.now();

      nativeAds[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = NativeAd(
        adUnitId: adUnitId, // Replace with your own
        factoryId: "adFactoryExample",
        request: AdRequest(
          keywords: ['vertical','horizontal', 'news', 'sports'], // List of targeting keywords
          contentUrl: 'https://www.example.com', // Optional content URL for better targeting
          nonPersonalizedAds: false, // Set true if user opted out of personalized ads
          extras: <String, String>{ // Additional parameters as key-value pairs
            'npa': '1', // Non-personalized ads (same as above)
            'color_bg': '#FFFFFF', // Example custom parameter for some ad networks
          },
          httpTimeoutMillis: 5000, // Optional: HTTP request timeout in milliseconds
        ),

        listener: NativeAdListener(
          onAdLoaded: (ad) {
            latencyData
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now();
            responseReceived = DateTime.now();

            nativeAds[index] = ad as NativeAd;
            adsLoaded[index] = true;
            debugPrint('✅ Native template ad loaded at index $index');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            latencyData.responseReceived = DateTime.now();
            ad.dispose();
            nativeAds[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Failed to load native ad at index $index: ${error.message}');
            notifyListeners();

            if (error.code != 3) {
              Future.delayed(
                const Duration(seconds: 5),
                () => loadAd(index, mediumRectangle),
              );
            }
          },
          onAdImpression: (ad) {
            latencyData.adRendered = DateTime.now();
            adRendered = DateTime.now();
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);
            notifyListeners();
          },
        ),
      );

      nativeAds[index] = ad;
      await ad.load();
      debugPrint('🔄 Started loading native template ad at index $index');
    } catch (e) {
      debugPrint('⚠️ Exception loading native ad at $index: $e');
      adErrors[index] = 'Exception: $e';
      notifyListeners();
    }
  }

  void _logLatencyMetrics(Ad ad) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
      final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
      final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;

      mainNavigatorKey.currentContext!.read<HomeProvider>().sendDataToads({
        "ad_source": "AdMobNative",
        "user_id": userId.toString(),
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
