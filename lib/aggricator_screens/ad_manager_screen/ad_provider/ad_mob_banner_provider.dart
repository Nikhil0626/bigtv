import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdMobBannerProvider with ChangeNotifier {
  final Map<int, BannerAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};

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
    try {
      // Clean up existing ad at this index
      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = BannerAd(
        adUnitId: 'ca-app-pub-2405357352181832/9414144917',
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
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
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}