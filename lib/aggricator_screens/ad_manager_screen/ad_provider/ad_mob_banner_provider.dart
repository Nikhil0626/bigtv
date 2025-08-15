import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AdMobBannerProvider with ChangeNotifier {
  final Map<int, BannerAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
  final String adUnitId =  mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId;
  void loadAds(int index) {

    // Clear existing ads first
    ads.forEach((index, ad) => ad?.dispose());
    ads.clear();
    adsLoaded.clear();
    adLatencyData.clear();
    adSizes.clear();
    adErrors.clear();

    // Load ads for first 20 items (adjust as needed)
    // for (int i = 0; i < 50; i++) {
    //   if ((i + 1) % 4 == 0) {
        loadAd(index, AdSize.mediumRectangle);
    //   }
    //   else if ((i + 1) % 2 == 0) {
    //     loadAd(i, AdSize.banner);
    //   }
    // }
    notifyListeners();
  }

  Future<void> loadAd(int index, AdSize size) async {
    requestInitiated = DateTime.now();
    log(" ad id show $adUnitId");
    try {
      // Clean up existing ad at this index
      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = BannerAd(
        adUnitId:adUnitId,
        size: size,
        request: AdRequest(
          keywords: ['vertical', 'horizontal','news', 'sports'], // List of targeting keywords
          contentUrl: 'https://www.example.com', // Optional content URL for better targeting
          nonPersonalizedAds: false, // Set true if user opted out of personalized ads
          extras: <String, String>{ // Additional parameters as key-value pairs
            'npa': '1', // Non-personalized ads (same as above)
            'color_bg': '#FFFFFF', // Example custom parameter for some ad networks
          },
          httpTimeoutMillis: 5000, // Optional: HTTP request timeout in milliseconds
        ),


        listener: BannerAdListener(
          onAdLoaded: (ad) {
            responseReceived = DateTime.now();

            latencyData
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now();

            ads[index] = ad as BannerAd;
            adsLoaded[index] = true;
            debugPrint('✅ Ad loaded successfully at index $index');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            latencyData.responseReceived = DateTime.now();
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at index $index: ${error.message}');
            notifyListeners();

            // Retry after delay if needed
            if (error.code != 3) { // Don't retry for invalid request errors
              Future.delayed(Duration(seconds: 5), () => loadAd(index, size));
            }
          },
          onAdImpression: (ad) {
            adRendered = DateTime.now();
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);

            latencyData.adRendered = DateTime.now();
            notifyListeners();
          },
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
      // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
      final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;

      mainNavigatorKey.currentContext!
          .read<HomeProvider>()
          .sendDataToads({
        "ad_source": 'AdMobBanner',
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