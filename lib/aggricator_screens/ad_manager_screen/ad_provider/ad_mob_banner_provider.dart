// import 'dart:developer';
// import 'dart:io';
//
// import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
// import 'package:chotanews/globel_keys/globel_keys.dart';
// import 'package:cron/cron.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../utils/app_colors.dart';
//
// class AdMobBannerProvider with ChangeNotifier {
//   final Map<int, dynamic> ads = {};
//   final Map<int, dynamic> adsBanner320x50 = {};
//   final Map<int, bool> adsLoaded = {};
//   final Map<int, bool> adsLoaded320x50 = {};
//   final Map<int, AdLatencyData> adLatencyData = {};
//   final Map<int, AdSize> adSizes = {};
//   final Map<int, String> adErrors = {};
//   final Map<int, String> adErrors320x50 = {};
//   DateTime? requestInitiated;
//   DateTime? responseReceived;
//   DateTime? adCreativeDownloaded;
//   DateTime? adRendered;
//   DateTime? impressionLogged;
//
//   int lastIndex = 0;
//
//   int currentPageIndex = 0;
//
//   void changePageIndex(val) {
//     currentPageIndex = val;
//     notifyListeners();
//   }
//
//   /// live ad units
//   final String adMobBannerId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId;
//   final String adManagerBannerId = mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId;
//   final String adMobNativeId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId;
//   final String adManagerNativeId = mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId;
//
//   /// test ad units
//   // final String adMobBannerId = "ca-app-pub-3940256099942544/6300978111";
//   // final String adManagerBannerId = "/6499/example/banner";
//   // final String adMobNativeId = "ca-app-pub-3940256099942544/2247696110";
//   // final String adManagerNativeId = "/6499/example/native";
//
//   int? getIndex() {
//     int? lastKey = ads.keys.isNotEmpty ? ads.keys.last : null;
//     return lastKey;
//   }
//
//   Future<void> loadAdMobBanner(int index, AdSize size) async {
//     requestInitiated = DateTime.now();
//     try {
//       ads[index]?.dispose();
//       final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
//       adLatencyData[index] = latencyData;
//       adSizes[index] = size;
//       adsLoaded[index] = false;
//       adErrors.remove(index);
//
//       final ad = BannerAd(
//         adUnitId:" mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId",
//         // adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId,
//         size: size,
//         request: AdRequest(
//           keywords: ['vertical'], // Optional content URL for better targeting
//           nonPersonalizedAds: false, // Set true if user opted out of personalized ads
//           httpTimeoutMillis: 5000, // Optional: HTTP request timeout in milliseconds
//         ),
//         listener: BannerAdListener(
//           onAdLoaded: (ad) {
//             source = "Mob Banner";
//             responseReceived = DateTime.now();
//
//             latencyData
//               ..responseReceived = DateTime.now()
//               ..adCreativeDownloaded = DateTime.now()
//               ..adRendered = DateTime.now();
//             if (ad != null) {
//               ads[index] = ad as BannerAd;
//               adsLoaded[index] = true;
//             }
//             ads.removeWhere((key, value) => value == null);
//             debugPrint('✅ Ad loaded successfully at index $index');
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             latencyData.responseReceived = DateTime.now();
//             ad.dispose();
//             ads[index] = null;
//             adsLoaded[index] = false;
//             adErrors[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ Ad failed at index $index: ${error.message}');
//             notifyListeners();
//           },
//           onAdImpression: (ad) {
//             adRendered = DateTime.now();
//             impressionLogged = DateTime.now();
//             _logLatencyMetrics(ad);
//
//             latencyData.adRendered = DateTime.now();
//             notifyListeners();
//           },
//         ),
//       );
//
//       if (ad != null) {
//         debugPrint('🔄 ⚠️index $index');
//         ads[index] = ad;
//         await ad.load();
//       }
//
//       debugPrint('🔄 Started loading ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ Exception loading ad at $index: $e');
//       adErrors[index] = 'Exception: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadAdManagerBanner(int index, AdSize size) async {
//     log(" Load AdManager Banner $adManagerBannerId -- $index ");
//     try {
//       requestInitiated = DateTime.now();
//       ads[index]?.dispose();
//
//       final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
//       adLatencyData[index] = latencyData;
//       adSizes[index] = size;
//       adsLoaded[index] = false;
//       adErrors.remove(index);
//
//       final ad = AdManagerBannerAd(
//         adUnitId: "mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId", // ✅ Ad Manager test ad unit
//         // adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId, // ✅ Ad Manager test ad unit
//         sizes: [AdSize.mediumRectangle], // ✅ Ad Manager expects a list
//         request: AdManagerAdRequest(), // ✅ Correct request type
//         listener: AdManagerBannerAdListener(
//           onAdLoaded: (ad) {
//             source = "Manager Banner";
//             ads[index] = ad;
//             adsLoaded[index] = true;
//             ads.removeWhere((key, value) => value == null);
//             adCreativeDownloaded = DateTime.now();
//             responseReceived = DateTime.now();
//             adRendered = DateTime.now();
//             debugPrint('✅ Ad loaded at $index (${size.width}x${size.height})');
//
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             ads[index] = null;
//             adsLoaded[index] = false;
//             adErrors[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ Ad failed at $index: ${error.message}');
//             notifyListeners();
//           },
//           onAdImpression: (Ad ad) {
//             impressionLogged = DateTime.now();
//             _logLatencyMetrics(ad);
//           },
//         ),
//       );
//
//       ads[index] = ad;
//       await ad.load();
//       debugPrint('🔄 Started loading ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ Exception loading ad at $index: $e');
//       adErrors[index] = 'Exception: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadAdMobNative(int index, AdSize mediumRectangle) async {
//     log(" Load AdMob Native ${ mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId} -- $index ");
//     try {
//       requestInitiated = DateTime.now();
//
//       ads[index]?.dispose();
//
//       final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
//       adLatencyData[index] = latencyData;
//       adsLoaded[index] = false;
//       adErrors.remove(index);
//       final ad = NativeAd(
//         adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId,
//         nativeAdOptions: NativeAdOptions(
//           mediaAspectRatio: MediaAspectRatio.any,
//         ),
//         factoryId: 'adFactoryExample',
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             responseReceived = DateTime.now();
//             adCreativeDownloaded = DateTime.now();
//             adRendered = DateTime.now();
//             if (ad != null) {
//               ads[index] = ad as NativeAd;
//               adsLoaded[index] = true;
//             }
//             ads.removeWhere((key, value) => value == null);
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             ads[index] = null;
//             adsLoaded[index] = false;
//             adErrors[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ Ad failed at $index: ${error.message}');
//             notifyListeners();
//           },
//           onAdImpression: (ad) async {
//
//           },
//         ),
//         request: AdRequest(),
//       );
//
//
//       if (ad != null) {
//         ads[index] = ad;
//         await ad.load();
//       }
//
//       debugPrint('🔄 Started loading native template ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ Exception loading native ad at $index: $e');
//       adErrors[index] = 'Exception: $e';
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadAdManagerNative(int index, AdSize size) async {
//     try {
//       ads[index]?.dispose();
//
//       adsLoaded[index] = false;
//       adErrors.remove(index);
//       NativeAdOptions nativeAdOptions = NativeAdOptions(
//         mediaAspectRatio: MediaAspectRatio.any,
//       );
//       final ad = NativeAd(
//         adUnitId: "/22387492205,23277683599/com.chotanews.Banner1.1747894381",
//         // adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId,
//         nativeAdOptions: nativeAdOptions,
//         factoryId: 'adFactoryExample',
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             responseReceived = DateTime.now();
//             adCreativeDownloaded = DateTime.now();
//             adRendered = DateTime.now();
//             if (ad != null) {
//               ads[index] = ad as NativeAd;
//               adsLoaded[index] = true;
//             }
//             ads.removeWhere((key, value) => value == null);
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             ads[index] = null;
//             adsLoaded[index] = false;
//             adErrors[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ Ad failed at $index: ${error.message}');
//             notifyListeners();
//           },
//           onAdImpression: (ad) async {
//
//           },
//         ),
//         request: AdRequest(),
//       );
//       if (ad != null) {
//         ads[index] = ad;
//         await ad.load();
//       }
//       debugPrint('🔄 Started loading ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ Exception loading ad at index $index: $e');
//       adErrors[index] = 'Exception: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadAd320x50MobBanner(int index, AdSize size) async {
//     try {
//       log("Mob Banner 320x50 -- ${DateTime.now().second.toString()}");
//       adsBanner320x50[index]?.dispose();
//
//       adsLoaded320x50[index] = false;
//       adErrors320x50.remove(index);
//
//       final ad = BannerAd(
//         // adUnitId: "ca-app-pub-3940256099942544/6300978111",
//         adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobStickBannerId, // Make sure this is a AdMob unit ID (starts with ca-app-pub-)
//         size: size,
//         request: AdRequest(),
//         listener: BannerAdListener(
//           onAdLoaded: (ad) {
//             source = "Mob Banner 320x50";
//             responseReceived = DateTime.now();
//             adsBanner320x50[index] = ad as BannerAd;
//             adsLoaded320x50[index] = true;
//             debugPrint('✅ AdMob 320x50 Ad loaded successfully at index $index');
//             ads.removeWhere((key, value) => value == null);
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             adsBanner320x50.remove(index);
//             adsLoaded320x50[index] = false;
//             adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ AdMob 320x50 Ad failed at index Nikhil $index: ${error.message}');
//
//             // Fallback to Ad Manager
//             loadAd320x50ManagerBanner(index, size);
//             notifyListeners();
//           },
//           onAdImpression: (ad) {
//             adRendered = DateTime.now();
//             impressionLogged = DateTime.now();
//             _logLatencyMetrics(ad);
//             notifyListeners();
//           },
//         ),
//       );
//
//       await ad.load();
//       debugPrint('🔄 AdMob 320x50 Started loading ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ AdMob 320x50 Exception loading ad at index $index: $e');
//       adErrors320x50[index] = 'Exception: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadAd320x50ManagerBanner(int index, AdSize size) async {
//     try {
//       // Dispose both types of ads
//       adsBanner320x50[index]?.dispose();
//
//       adsLoaded320x50[index] = false;
//       adErrors320x50.remove(index);
//
//       final ad = AdManagerBannerAd(
//         // adUnitId: "	/21775744923/example/fixed-size-banner",
//         adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerStickBannerId, // Make sure this is an Ad Manager unit ID (/...)
//         sizes: [size],
//         request: AdManagerAdRequest(),
//         listener: AdManagerBannerAdListener(
//           onAdLoaded: (ad) {
//             source = "Manager Banner 320x50";
//             responseReceived = DateTime.now();
//             adsBanner320x50[index] = ad as AdManagerBannerAd;
//             adsLoaded320x50[index] = true;
//             debugPrint('✅ Ad Manager 320x50 Ad loaded successfully at index $index');
//             ads.removeWhere((key, value) => value == null);
//             notifyListeners();
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             adsBanner320x50.remove(index);
//             adsLoaded320x50[index] = false;
//             adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
//             debugPrint('❌ Ad Manager 320x50 Ad failed at index siva1 $index: ${error.message}');
//             // autoBannerCall();
//             notifyListeners();
//           },
//           onAdImpression: (ad) {
//             adRendered = DateTime.now();
//             impressionLogged = DateTime.now();
//             _logLatencyMetrics(ad);
//             notifyListeners();
//           },
//         ),
//       );
//
//       await ad.load();
//       debugPrint('🔄 Ad Manager 320x50 Started loading ad at index $index');
//     } catch (e) {
//       debugPrint('⚠️ Ad Manager 320x50 Exception loading ad at index $index: $e');
//       adErrors320x50[index] = 'Exception: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//
//
//   // int? autoupdate;
//   // Cron? _cron;
//   //
//   // Future<void> autoBannerCall() async {
//   //   autoupdate = (adsBanner320x50.length) + 1;
//   //
//   //   // If already closed, create a new instance
//   //   _cron ??= Cron();
//   //
//   //   _cron!.schedule(Schedule.parse('*/30 * * * * *'), () async {
//   //     log("loadBothAdsInParallel");
//   //     loadAd320x50MobBanner(autoupdate!, AdSize.banner);
//   //   });
//   // }
//   //
//   // void cronClose() async {
//   //   await _cron?.close();
//   //   _cron = null; // allow restart
//   // }
//
//   String? source = "";
//
//   void _logLatencyMetrics(Ad ad) async {
//     final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? userId = preferences.getString("userId");
//     final requestLatency = responseReceived?.difference(requestInitiated!).inMilliseconds;
//     final loadLatency = adCreativeDownloaded?.difference(responseReceived!).inMilliseconds;
//     // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
//     // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
//     final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
//     final creativeDownloadLatency = adCreativeDownloaded?.difference(responseReceived!).inMilliseconds;
//     // final renderLatency = adRendered!.difference(adCreativeDownloaded).inMilliseconds;
//     final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
//
//
//     mainNavigatorKey.currentContext!.read<HomeProvider>().sendDataToads({
//       "ad_source": source.toString(),
//       "user_id": userId.toString(),
//       "sdk_ready_time": sdkReadyLatency.toString(),
//       "creative_download": creativeDownloadLatency.toString(),
//       // "render_time": renderLatency.toString(),
//       "total_time": totalLatency.toString(),
//       "data": "${ad.responseInfo}",
//     });
//     await analytics.logEvent(
//       name: "ad_latency_metrics",
//       parameters: {
//         "adSource": source.toString(),
//         "requestInitiated": requestInitiated.toString(),
//         "responseReceived": responseReceived.toString(),
//         "adCreativeDownloaded": adCreativeDownloaded.toString(),
//         "adRendered": adRendered.toString(),
//         "impressionLogged": impressionLogged.toString(),
//         "latency_request": requestLatency.toString(),
//         "latency_load": loadLatency.toString(),
//         // "latency_render": renderLatency.toString(),
//         "latency_total": totalLatency.toString(),
//         "createAt": DateTime.now().toString(),
//       },
//     );
//     // }
//   }
//
//   void adsLoad() {
//     loadAdMobBanner(1, AdSize.mediumRectangle);
//     loadAdManagerBanner(2, AdSize.mediumRectangle);
//     loadAdMobNative(3, AdSize.mediumRectangle);
//     loadAdManagerNative(4, AdSize.mediumRectangle);
//   }
//   void adsDispose() {
//     // _cron.close();
//     ads.clear();
//     adsBanner320x50.clear();
//   }
//
// }
//
//
// class AdLatencyData {
//   DateTime? requestInitiated;
//   DateTime? responseReceived;
//   DateTime? adCreativeDownloaded;
//   DateTime? adRendered;
// }

import 'dart:developer';
import 'dart:io';
import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/base_service.dart';
import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class AdMobBannerProvider with ChangeNotifier {
  final Map<int, dynamic> ads = {};
  final Map<int, dynamic> adsBanner320x50 = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, bool> adsLoaded320x50 = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, AdSize> adSizes = {};
  final Map<int, String> adErrors = {};
  final Map<int, String> adErrors320x50 = {};
  DateTime? requestInitiated;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? responseReceived;
  DateTime? impressionLogged;

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
      requestInitiated = DateTime.now();

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
            responseReceived = DateTime.now();
            adCreativeDownloaded = DateTime.now();
            adRendered = DateTime.now();
            if (ad != null) {
              ads[index] = ad as NativeAd;
              adsLoaded[index] = true;
            }
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


      if (ad != null) {
        ads[index] = ad;
        await ad.load();
      }

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

      adsLoaded[index] = false;
      adErrors.remove(index);
      NativeAdOptions nativeAdOptions = NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.any,
      );
      final ad = NativeAd(
        // adUnitId: "/22387492205,23277683599/com.chotanews.Banner1.1747894381",
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId,
        nativeAdOptions: nativeAdOptions,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            responseReceived = DateTime.now();
            adCreativeDownloaded = DateTime.now();
            adRendered = DateTime.now();
            if (ad != null) {
              ads[index] = ad as NativeAd;
              adsLoaded[index] = true;
            }
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
      if (ad != null) {
        ads[index] = ad;
        await ad.load();
      }
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
        // adUnitId: "ca-app-pub-3940256099942544/6300978111",
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
        // adUnitId: "	/21775744923/example/fixed-size-banner",
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

      debugPrint("[AdMob] Requesting 320x50 banner at index $index with size: $size");

      final ad = BannerAd(
        // adUnitId: "ca-app-pub-3940256099942544/6300978111",
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adMobStickBannerId,
        size: size,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("[AdMob] 320x50 ad loaded at index $index");
            source = "AdMob 320x50 Banner";
            adLatencyData[index] = (AdLatencyData()
              ..requestInitiated = DateTime.now()
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now());

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
            // loadAd320x50ManagerBanner(autoupdate!, size); // ✅ fallback
          },
          onAdImpression: (ad) {
            debugPrint("[AdMob] Impression logged at index $index");
            adLatencyData[index]?.impressionLogged = DateTime.now();
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

      debugPrint("[AdManager 320x50] Requesting banner at index $index with size: $size");

      final ad = AdManagerBannerAd(
        adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerStickBannerId,
        // adUnitId: "	/21775744923/example/fixed-size-banner",
        sizes: [size],
        request: AdManagerAdRequest(),
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("[AdManager 320x50] Ad loaded at index $index");
            source = "AdManager 320x50 Banner";
            adLatencyData[index] = (AdLatencyData()
              ..requestInitiated = DateTime.now()
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now());

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
            adLatencyData[index]?.impressionLogged = DateTime.now();
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
    SharedPreferences sp = await SharedPreferences.getInstance();
    log("error ads imple $error");
    final latency = adLatencyData[index];

    final sdkReadyLatency = (latency?.responseReceived != null && latency?.requestInitiated != null) ? latency?.responseReceived!.difference(latency.requestInitiated!).inMilliseconds : null;

    final renderLatency = (latency?.adRendered != null && latency?.adCreativeDownloaded != null) ? latency?.adRendered!.difference(latency.adCreativeDownloaded!).inMilliseconds : null;
    sendDataToads({
      "event": "AdFailure",
      "source": sources.toString(),
      "platform": Platform.isIOS ? "ios" : "android",
      "adResponse": error.toString(),
      "deviceId": sp.getString("deviceId"),
      "timestamp": DateTime.now().toString(),
    });
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
    // EventRepo().addEvent(, "");
  }

  void adSuccess(Ad ad, int index, sources) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sendDataToads({
      "event": "AdSuccess",
      "source": sources.toString(),
      "platform": Platform.isIOS ? "ios" : "android",
      "adResponse": "success",
      "deviceId": sp.getString("deviceId"),
      "timestamp": DateTime.now().toString(),
    });
  }

  void _logLatencyMetrics(Ad ad, int index, sources) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
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

  Future sendDataToads(body) async {
    log("test post data $body");
    try {
      Response response = await BaseService().makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.test, method: RequestType.post, body: body);
      return response.data;
    } on DioException catch (e, st) {
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    } catch (e, st) {
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    }
  }





  void adsLoad() {
    loadAdMobBanner(1, AdSize.mediumRectangle);
    loadAdManagerBanner(2, AdSize.mediumRectangle);
    loadAdMobNative(3, AdSize.mediumRectangle);
    loadAdManagerNative(4, AdSize.mediumRectangle);
  }

  void adsDispose() {
    ads.clear();
    // adsBanner320x50.clear();
  }
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
}
