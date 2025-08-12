import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobNativeProvider with ChangeNotifier {

  final Map<int, NativeAd?> nativeAds = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, String> adErrors = {};

  // final String adUnitId =  'ca-app-pub-2405357352181832/7643871122';
  final String adUnitId =  'ca-app-pub-3940256099942544/2247696110';
  Future<void> loadAd(int index, AdSize mediumRectangle) async {
    try {
    
      nativeAds[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = NativeAd(
        adUnitId: adUnitId, // Replace with your own
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium, // 300×250
          mainBackgroundColor: const Color(0xFFFFFFFF),
          cornerRadius: 12,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFFFFFFFF),
            backgroundColor: const Color(0xFF1E88E5),
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF000000),
            backgroundColor: null,
            style: NativeTemplateFontStyle.bold,
            size: 14.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF555555),
            backgroundColor: null,
            style: NativeTemplateFontStyle.normal,
            size: 12.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF777777),
            backgroundColor: null,
            style: NativeTemplateFontStyle.italic,
            size: 12.0,
          ),
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            latencyData
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now();

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
                    () => loadAd(index,mediumRectangle),
              );
            }
          },
          onAdImpression: (ad) {
            latencyData.adRendered = DateTime.now();
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
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}


 