import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';

class AdManagerNativeProvider with ChangeNotifier {
  final String adUnitId = '/22387492205,23277683599/com.chotanews.Native1.1747720256';

  final Map<int, NativeAd?> ads = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};

  final Map<int, DateTime?> requestInitiatedMap = {};
  final Map<int, DateTime?> responseReceivedMap = {};
  final Map<int, DateTime?> adCreativeDownloadedMap = {};
  final Map<int, DateTime?> adRenderedMap = {};
  final Map<int, DateTime?> impressionLoggedMap = {};

  /// Load multiple ads if needed
  void loadAds(List<int> indexes) {
    for (var index in indexes) {
      loadAd(index, AdSize.mediumRectangle);
    }
  }

  /// Load a single ad at given index
  Future<void> loadAd(int index, AdSize size) async {
    try {
      requestInitiatedMap[index] = DateTime.now();

      // Dispose old ad if exists
      ads[index]?.dispose();

      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final NativeAd ad = NativeAd(
        adUnitId: adUnitId,
        factoryId: 'adFactoryExample',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            ads[index] = ad as NativeAd;
            adsLoaded[index] = true;
            responseReceivedMap[index] = DateTime.now();
            adCreativeDownloadedMap[index] = DateTime.now();
            adRenderedMap[index] = DateTime.now();
            debugPrint('✅ Ad loaded at index $index (${size.width}x${size.height})');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at index $index: ${error.message}');
            notifyListeners();
          },
          onAdImpression: (ad) {
            impressionLoggedMap[index] = DateTime.now();
            // _logLatencyMetrics(index, ad);
          },
        ),
      );

      ads[index] = ad;
      await ad.load();
      debugPrint('🔄 Started loading ad at index $index');
    } catch (e) {
      debugPrint('⚠️ Exception loading ad at index $index: $e');
      adErrors[index] = 'Exception: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _logLatencyMetrics(int index, Ad ad) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");

    final requestInitiated = requestInitiatedMap[index];
    final responseReceived = responseReceivedMap[index];
    final adCreativeDownloaded = adCreativeDownloadedMap[index];
    final adRendered = adRenderedMap[index];
    final impressionLogged = impressionLoggedMap[index];

    if (requestInitiated != null &&
        responseReceived != null &&
        adCreativeDownloaded != null &&
        adRendered != null &&
        impressionLogged != null) {
      final sdkReadyLatency = responseReceived.difference(requestInitiated).inMilliseconds;
      final creativeDownloadLatency = adCreativeDownloaded.difference(responseReceived).inMilliseconds;
      final renderLatency = adRendered.difference(adCreativeDownloaded).inMilliseconds;
      final totalLatency = impressionLogged.difference(requestInitiated).inMilliseconds;

      mainNavigatorKey.currentContext!.read<HomeProvider>().sendDataToads({
        "ad_source": "AdManagerNativeProvider",
        "user_id": userId.toString(),
        "sdk_ready_time": sdkReadyLatency.toString(),
        "creative_download": creativeDownloadLatency.toString(),
        "render_time": renderLatency.toString(),
        "total_time": totalLatency.toString(),
        "data": "${ad.responseInfo}",
      });
    }
  }

  void disposeAllAds() {
    ads.forEach((_, ad) => ad?.dispose());
    ads.clear();
    adsLoaded.clear();
    adSizes.clear();
    adErrors.clear();
  }
}
 