
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdManagerNativeProvider with ChangeNotifier {


  final String adUnitId = '/22387492205,23277683599/id1631068092.Banner0.1747829228';


  final Map<int, NativeAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
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
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}