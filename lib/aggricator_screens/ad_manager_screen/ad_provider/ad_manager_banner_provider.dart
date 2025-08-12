
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdManagerBannerProvider with ChangeNotifier {


  // final String adUnitId = '/22387492205,23277683599/id1631068092.Banner0.1747829228';
  final String adUnitId = '/6499/example/banner';


  final Map<int, AdManagerBannerAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};


  Future<void> loadAd(int index, AdSize size) async {
    try {
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