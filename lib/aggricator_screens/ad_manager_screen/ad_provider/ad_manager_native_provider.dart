
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_screen/home_provider/home_provider.dart';
import 'package:provider/provider.dart';

class AdManagerNativeProvider with ChangeNotifier {


  final String adUnitId = '/22387492205,23277683599/id1631068092.Banner0.1747829228';


  final Map<int, NativeAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
  DateTime? impressionLogged;
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  //
  // void loadAds(int index) {
  //   ads.forEach((index, ad) => ad?.dispose());
  //   ads.clear();
  //   adsLoaded.clear();
  //   adLatencyData.clear();
  //   adSizes.clear();
  //   adErrors.clear();
  //
  //   // for (int i = 0; i < 50; i++) {
  //   //   if ((i + 1) % 4 == 0) {
  //       loadAd(index, AdSize.mediumRectangle);
  //     // }
  //     // else if ((i + 1) % 2 == 0) {
  //     //   loadAd(i, AdSize.banner);
  //     // }
  //   // }
  //   notifyListeners();
  // }

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

      String? adUnitId = "/21775744923/example/native";
      // String? adUnitId = "/22387492205,23277683599/id1631068092.Native1.1747829152";

     NativeAd ad = NativeAd(
        adUnitId: adUnitId,
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: Colors.white,
          cornerRadius: 10.0,
          tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              backgroundColor: Colors.transparent,
              style: NativeTemplateFontStyle.normal,
              size: 8.0,
              ),
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black,
            backgroundColor: Colors.blue,

            style: NativeTemplateFontStyle.monospace,
            size: 16.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black,
            backgroundColor: Colors.white,
            style: NativeTemplateFontStyle.bold,
            size: 8.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black,
            backgroundColor: Colors.white,
            style: NativeTemplateFontStyle.bold,
            size: 8.0,
          ),
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            ads[index] = ad as NativeAd;
            adsLoaded[index] = true;
            responseReceived = DateTime.now();
            adCreativeDownloaded = DateTime.now();
            adRendered = DateTime.now();
            debugPrint('✅ Ad loaded at $index (${size.width}x${size.height})');
            notifyListeners();
          },

          onAdFailedToLoad: (ad, error) {
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at $index: ${error.message}');
            notifyListeners();
          },
          onAdImpression: (ad) async {
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);
          },
        ),
        request: AdRequest(),
      )..load();

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
        "ad_source": "AdManagerNativeProvider",
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