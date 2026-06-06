import 'dart:developer';
import 'dart:io';
import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdMobBannerProvider with ChangeNotifier {
  final Map<int, dynamic> ads = {};
  final Map<int, dynamic> adsBanner320x50 = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, bool> adsLoaded320x50 = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
  final Map<int, String> adErrors320x50 = {};

  int currentPageIndex = 0;
  String? source = "";

  void changePageIndex(int val) {
    currentPageIndex = val;
    notifyListeners();
  }

  Future<void> loadAdMobNative(int index, AdSize mediumRectangle) async {
    log(" Load AdMob Native ${ mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId} -- $index ");
    try {
      debugPrint("AdMobNative ${mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId}");

      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adsLoaded[index] = false;
      adErrors.remove(index);
      final ad = NativeAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId,
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.any,
        ),
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();
            ads[index] = ad as NativeAd;
            adsLoaded[index] = true;
            ads.removeWhere((key, value) => value == null);
            notifyListeners();
            adSuccess(ad, index, "AdMob Native");
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at $index: ${error.message}');
            notifyListeners();

            _checkIfAllAdsFailed(error, index, "AdMob Native");
          },
          onAdImpression: (ad) async {
            _logLatencyMetrics(ad, index, "AdMob Native");
          },
        ),
        request: AdRequest(),
      );


      ads[index] = ad;
      await ad.load();

      debugPrint('🔄 Started loading native template ad at index $index');
    } catch (e) {
      debugPrint('⚠️ Exception loading native ad at $index: $e');
      adErrors[index] = 'Exception: $e';
      notifyListeners();
    }
  }

  Future<void> loadAdManagerNative(int index, AdSize size) async {
    try {
      debugPrint("AdMangerNative ${mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId}");

      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adsLoaded[index] = false;
      adErrors.remove(index);
      NativeAdOptions nativeAdOptions = NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.any,
      );
      final ad = NativeAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId,
        nativeAdOptions: nativeAdOptions,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();
            ads[index] = ad as NativeAd;
            adsLoaded[index] = true;
            ads.removeWhere((key, value) => value == null);
            notifyListeners();
            adSuccess(ad, index, "AdManager Native");
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad failed at $index: ${error.message}');
            notifyListeners();
            _checkIfAllAdsFailed(error, index, "AdManager Native");
          },
          onAdImpression: (ad) async {
            _logLatencyMetrics(ad, index, "AdManager Native");
          },
        ),
        request: AdRequest(),
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

  Future<void> loadAdMobBanner(int index, AdSize size) async {
    try {
      debugPrint("AdMobBanner ${mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId}");

      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;

      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = BannerAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId,
        size: size,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            source = "AdMob Banner";
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();

            ads[index] = ad as BannerAd;
            adsLoaded[index] = true;
            ads.removeWhere((key, value) => value == null);
            notifyListeners();
            adSuccess(ad, index, "AdMob Banner");
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';

            _checkIfAllAdsFailed(error, index, "AdMob Banner");
          },
          onAdImpression: (ad) {
            latencyData.impressionLogged = DateTime.now();
            _logLatencyMetrics(ad, index, "AdMob Banner");
          },
          onAdClicked: (ad) async => await _logEvent("onAdClicked"),
          onAdClosed: (ad) async => await _logEvent("onAdClosed"),
          onAdOpened: (ad) async => await _logEvent("onAdOpened"),
        ),
      );

      ads[index] = ad;
      await ad.load();
    } catch (e) {
      adErrors[index] = 'Exception: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadAdManagerBanner(int index, AdSize size) async {
    try {
      debugPrint("AdMangerBanner ${mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId}");
      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;

      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);


      final ad = AdManagerBannerAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId,
        sizes: [size],
        request: AdManagerAdRequest(),
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            source = "AdManager Banner";
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();

            ads[index] = ad;
            adsLoaded[index] = true;
            ads.removeWhere((key, value) => value == null);
            notifyListeners();
            adSuccess(ad, index, "AdManager Banner");
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            _checkIfAllAdsFailed(error, index, "AdManager Banner");
          },
          onAdImpression: (ad) {
            latencyData.impressionLogged = DateTime.now();
            _logLatencyMetrics(ad, index, "AdManager Banner");
          },
          onAdClicked: (ad) async {
            await _logEvent("onAdClicked");
          },
          onAdClosed: (ad) async {
            await _logEvent("onAdClosed");
          },
          onAdOpened: (ad) async {
            await _logEvent("onAdOpened");
          },
        ),
      );

      ads[index] = ad;
      await ad.load();
    } catch (e) {
      adErrors[index] = 'Exception: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadAd320x50MobBanner(int index, AdSize size) async {
    try {
      debugPrint("[AdMob] Disposing existing 320x50 ad at index ${mainNavigatorKey.currentContext!.read<HomeProvider>().adMobStickBannerId}");
      adsBanner320x50[index]?.dispose();
      adsLoaded320x50[index] = false;
      adErrors320x50.remove(index);

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;

      debugPrint("[AdMob] Requesting 320x50 banner at index $index with size: $size");

      final ad = BannerAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobStickBannerId,
        size: size,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("[AdMob] 320x50 ad loaded at index $index");
            source = "AdMob 320x50 Banner";
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();

            adsBanner320x50[index] = ad as BannerAd;
            adsLoaded320x50[index] = true;
            adsBanner320x50.removeWhere((key, value) => value == null);
            notifyListeners();
            adSuccess(ad, index, "AdMob 320x50 Banner");
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint("[AdMob] 320x50 ad failed at index $index: ${error.code} - ${error.message}");
            ad.dispose();
            adsBanner320x50.remove(index);
            adsLoaded320x50[index] = false;
            adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
            adsBanner320x50.removeWhere((key, value) => value == null);
            _checkIfAllAdsFailed(error, index, "AdMob 320x50 Banner");
          },
          onAdImpression: (ad) {
            debugPrint("[AdMob] Impression logged at index $index");
            latencyData.impressionLogged = DateTime.now();
            _logLatencyMetrics(ad, index, "AdMob 320x50 Banner");
          },
          onAdClicked: (ad) async {
            debugPrint("[AdMob] Ad clicked at index $index");
            await _logEvent("onAdClicked");
          },
          onAdClosed: (ad) async {
            debugPrint("[AdMob] Ad closed at index $index");
            await _logEvent("onAdClosed");
          },
          onAdOpened: (ad) async {
            debugPrint("[AdMob] Ad opened at index $index");
            await _logEvent("onAdOpened");
          },
        ),
      );
      await ad.load();
      debugPrint("[AdMob] Ad load initiated at index $index");
    } catch (e) {
      debugPrint("[AdMob] Exception at index $index: $e");
      adErrors320x50[index] = 'Exception: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }


  Future<void> loadAd320x50ManagerBanner(int index, AdSize size) async {
    try {
      debugPrint("[AdManager 320x50] Disposing existing ad at index ${mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerStickBannerId}");
      adsBanner320x50[index]?.dispose();
      adsLoaded320x50[index] = false;
      adErrors320x50.remove(index);

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;

      debugPrint("[AdManager 320x50] Requesting banner at index $index with size: $size");

      final ad = AdManagerBannerAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerStickBannerId,
        sizes: [size],
        request: AdManagerAdRequest(),
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("[AdManager 320x50] Ad loaded at index $index");
            source = "AdManager 320x50 Banner";
            latencyData.responseReceived = DateTime.now();
            latencyData.adCreativeDownloaded = DateTime.now();
            latencyData.adRendered = DateTime.now();

            adsBanner320x50[index] = ad as AdManagerBannerAd;
            adsLoaded320x50[index] = true;
            adsBanner320x50.removeWhere((key, value) => value == null);

            notifyListeners();
            adSuccess(ad, index, "AdManager 320x50 Banner");
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint("[AdManager 320x50] Failed to load at index $index: ${error.code} - ${error.message}");
            ad.dispose();
            adsBanner320x50.remove(index);
            adsLoaded320x50[index] = false;
            adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
            adsBanner320x50.removeWhere((key, value) => value == null);

            debugPrint("[AdManager 320x50] Falling back to AdMob at index $index");
            loadAd320x50MobBanner(index, AdSize.banner);

            _checkIfAllAdsFailed(error, index, "AdManager 320x50 Banner");
          },
          onAdImpression: (ad) {
            debugPrint("[AdManager 320x50] Impression logged at index $index");
            latencyData.impressionLogged = DateTime.now();
            _logLatencyMetrics(ad, index, "AdManager 320x50 Banner");
          },
          onAdClicked: (ad) async {
            debugPrint("[AdManager 320x50] Ad clicked at index $index");
            await _logEvent("onAdClicked");
          },
          onAdClosed: (ad) async {
            debugPrint("[AdManager 320x50] Ad closed at index $index");
            await _logEvent("onAdClosed");
          },
          onAdOpened: (ad) async {
            debugPrint("[AdManager 320x50] Ad opened at index $index");
            await _logEvent("onAdOpened");
          },
        ),
      );

      await ad.load();
      debugPrint("[AdManager 320x50] Load initiated at index $index");
    } catch (e) {
      debugPrint("[AdManager 320x50] Exception at index $index: $e");
      adErrors320x50[index] = 'Exception: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }


  Future<void> _logEvent(String name) async {
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: {
      "event": name,
      "platform": Platform.isIOS ? "ios" : "android",
      "timestamp": DateTime.now().toString(),
    });
  }

  Future<void> _checkIfAllAdsFailed(error, index, sources) async {
    log("error ads imple $error");
    final latency = adLatencyData[index];

    final sdkReadyLatency = (latency?.responseReceived != null && latency?.requestInitiated != null) ? latency?.responseReceived!.difference(latency.requestInitiated!).inMilliseconds : null;

    final renderLatency = (latency?.adRendered != null && latency?.adCreativeDownloaded != null) ? latency?.adRendered!.difference(latency.adCreativeDownloaded!).inMilliseconds : null;

    await FirebaseAnalytics.instance.logEvent(
      name: "ads_failure",
      parameters: {
        "adSource": sources.toString(),
        "sdkRequestStartTime": sdkReadyLatency.toString(),
        "sdkRequestReceivedTime": renderLatency.toString(),
        "adsRenderingTime": "0",
        "platform": Platform.isIOS ? "ios" : "android",
        "createAt": DateTime.now().toString(),
        "adResponse": error.toString(),
      },
    );
  }

  void adSuccess(Ad ad, int index, sources) async {
    // Analytics logic here if needed
  }

  void _logLatencyMetrics(Ad ad, int index, sources) async {
    final analytics = FirebaseAnalytics.instance;
    final latency = adLatencyData[index];

    if (latency == null) {
      return;
    }

    final sdkReadyLatency = (latency.responseReceived != null && latency.requestInitiated != null) ? latency.responseReceived!.difference(latency.requestInitiated!).inMilliseconds : null;

    final creativeDownloadLatency =
        (latency.adCreativeDownloaded != null && latency.responseReceived != null) ? latency.adCreativeDownloaded!.difference(latency.responseReceived!).inMilliseconds : null;

    final renderLatency = (latency.adRendered != null && latency.adCreativeDownloaded != null) ? latency.adRendered!.difference(latency.adCreativeDownloaded!).inMilliseconds : null;

    final totalLatency = (latency.impressionLogged != null && latency.requestInitiated != null) ? latency.impressionLogged!.difference(latency.requestInitiated!).inMilliseconds : null;

    await analytics.logEvent(
      name: "ads_success",
      parameters: {
        "adSource": sources.toString(),
        "sdkRequestStartTime": sdkReadyLatency?.toString() ?? "",
        "sdkRequestReceivedTime": creativeDownloadLatency.toString(),
        "adsRenderingTime": renderLatency?.toString() ?? "",
        "createAt": DateTime.now().toString(),
        "adResponse": "success",
        "platform": Platform.isIOS ? "ios" : "android",
      },
    );
    await analytics.logEvent(
      name: "ad_latency_metrics",
      parameters: {
        "adSource": sources ?? "unknown",
        "requestInitiated": latency.requestInitiated?.toIso8601String() ?? "",
        "responseReceived": latency.responseReceived?.toIso8601String() ?? "",
        "adCreativeDownloaded": latency.adCreativeDownloaded?.toIso8601String() ?? "",
        "adRendered": latency.adRendered?.toIso8601String() ?? "",
        "impressionLogged": latency.impressionLogged?.toIso8601String() ?? "",
        "latency_request": sdkReadyLatency?.toString() ?? "",
        "latency_load": creativeDownloadLatency?.toString() ?? "",
        "latency_render": renderLatency?.toString() ?? "",
        "latency_total": totalLatency?.toString() ?? "",
        "createdAt": DateTime.now().toIso8601String(),
        "platform": Platform.isIOS ? "ios" : "android",
      },
    );
  }

  void adsLoad() {
    loadAdMobBanner(1, AdSize.mediumRectangle);
    loadAdManagerBanner(2, AdSize.mediumRectangle);
    loadAdMobNative(3, AdSize.mediumRectangle);
    loadAdManagerNative(4, AdSize.mediumRectangle);
  }

  void adsDispose() {
    ads.clear();
  }
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
}
