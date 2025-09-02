import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_colors.dart';

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
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;

  int lastIndex = 0;

  /// live ad units
  final String adMobBannerId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId;
  final String adManagerBannerId = mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerBannerId;
  final String adMobNativeId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobNativeId;
  final String adManagerNativeId = mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerNativeId;

  /// test ad units
  // final String adMobBannerId = "ca-app-pub-3940256099942544/6300978111";
  // final String adManagerBannerId = "/6499/example/banner";
  // final String adMobNativeId = "ca-app-pub-3940256099942544/2247696110";
  // final String adManagerNativeId = "/6499/example/native";

  int? getIndex() {
    int? lastKey = ads.keys.isNotEmpty ? ads.keys.last : null;
    return lastKey;
  }

  Future<void> loadAdMobBanner(int index, AdSize size) async {
    requestInitiated = DateTime.now();
    log(" Load AdMob Banner $adMobBannerId -- $index ");
    try {
      ads[index]?.dispose();
      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = BannerAd(
        adUnitId: adMobBannerId,
        size: size,
        request: AdRequest(
          keywords: ['vertical'], // Optional content URL for better targeting
          nonPersonalizedAds: false, // Set true if user opted out of personalized ads
          httpTimeoutMillis: 5000, // Optional: HTTP request timeout in milliseconds
        ),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            responseReceived = DateTime.now();

            latencyData
              ..responseReceived = DateTime.now()
              ..adCreativeDownloaded = DateTime.now()
              ..adRendered = DateTime.now();
            if (ad != null) {
              ads[index] = ad as BannerAd;
              adsLoaded[index] = true;
            }
            ads.removeWhere((key, value) => value == null);
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

      if (ad != null) {
        ads[index] = ad;
        await ad.load();
      }

      debugPrint('🔄 Started loading ad at index $index');
    } catch (e) {
      debugPrint('⚠️ Exception loading ad at $index: $e');
      adErrors[index] = 'Exception: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadAdManagerBanner(int index, AdSize size) async {
    log(" Load AdManager Banner $adManagerBannerId -- $index ");
    try {
      requestInitiated = DateTime.now();
      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adSizes[index] = size;
      adsLoaded[index] = false;
      adErrors.remove(index);

      final ad = AdManagerBannerAd(
        adUnitId: '/6499/example/banner', // ✅ Ad Manager test ad unit
        sizes: [AdSize.mediumRectangle], // ✅ Ad Manager expects a list
        request: AdManagerAdRequest(), // ✅ Correct request type
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            ads[index] = ad;
            adsLoaded[index] = true;
            ads.removeWhere((key, value) => value == null);
            adCreativeDownloaded = DateTime.now();
            responseReceived = DateTime.now();
            adRendered = DateTime.now();
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
          onAdImpression: (Ad ad) {
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);
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

  Future<void> loadAdMobNative(int index, AdSize mediumRectangle) async {
    log(" Load AdMob Native $adMobNativeId -- $index ");
    try {
      requestInitiated = DateTime.now();

      ads[index]?.dispose();

      final latencyData = AdLatencyData()..requestInitiated = DateTime.now();
      adLatencyData[index] = latencyData;
      adsLoaded[index] = false;
      adErrors.remove(index);
      final ad = NativeAd(
        adUnitId: adMobNativeId, // Use test ID: 'ca-app-pub-3940256099942544/2247696110'
        factoryId: "adFactoryExample",
        // nativeTemplateStyle: NativeTemplateStyle(
        //   templateType: TemplateType.medium,
        //   mainBackgroundColor: AppColors.cardBackgroundColor,
        //   cornerRadius: 10.0,
        //   callToActionTextStyle: NativeTemplateTextStyle(
        //     textColor: Colors.black,
        //     backgroundColor: AppColors.cardBackgroundColor,
        //     style: NativeTemplateFontStyle.monospace,
        //     size: 16.0,
        //   ),
        //   primaryTextStyle: NativeTemplateTextStyle(
        //     textColor: Colors.black,
        //     backgroundColor: AppColors.cardBackgroundColor,
        //     style: NativeTemplateFontStyle.italic,
        //     size: 16.0,
        //   ),
        //   secondaryTextStyle: NativeTemplateTextStyle(
        //     textColor: Colors.black,
        //     backgroundColor: AppColors.cardBackgroundColor,
        //     style: NativeTemplateFontStyle.bold,
        //     size: 16.0,
        //   ),
        //   tertiaryTextStyle: NativeTemplateTextStyle(
        //     textColor: Colors.black,
        //     backgroundColor: AppColors.cardBackgroundColor,
        //     style: NativeTemplateFontStyle.normal,
        //     size: 16.0,
        //   ),
        // ),

        request: AdRequest(),

        listener: NativeAdListener(onAdLoaded: (Ad ad) {
          latencyData
            ..responseReceived = DateTime.now()
            ..adCreativeDownloaded = DateTime.now()
            ..adRendered = DateTime.now();
          responseReceived = DateTime.now();
          if (ad != null) {
            ads[index] = ad as NativeAd;
            adsLoaded[index] = true;
          }
          ads.removeWhere((key, value) => value == null);
          debugPrint('✅ AdMobNative loaded at index $index');
          notifyListeners();
        }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
          latencyData.responseReceived = DateTime.now();
          ad.dispose();
          ads[index] = null;
          adsLoaded[index] = false;
          adErrors[index] = 'Failed: ${error.code} - ${error.message}';
          debugPrint('❌ AdMobNative Failed to load at index $index: ${error.message}');
          notifyListeners();
          ad.dispose();
        }, onAdImpression: (ad) {
          latencyData.adRendered = DateTime.now();
          adRendered = DateTime.now();
          impressionLogged = DateTime.now();
          _logLatencyMetrics(ad);
          notifyListeners();
        }),
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
      ads[index]?.dispose();

      adsLoaded[index] = false;
      adErrors.remove(index);
      NativeAdOptions nativeAdOptions = NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.portrait,
      );
      final NativeAd ad = NativeAd(
        adUnitId: adManagerNativeId,
        factoryId: "adFactoryExample",
        // nativeTemplateStyle: NativeTemplateStyle(
        //   templateType: TemplateType.medium,
        //   mainBackgroundColor: Colors.white,
        //   cornerRadius: 10.0,
        // ),
        nativeAdOptions: nativeAdOptions,
        request: const AdManagerAdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (ad != null) {
              ads[index] = ad as NativeAd;
              adsLoaded[index] = true;
            }

            debugPrint('✅ Ad Manager Native loaded at index $index');
            ads.removeWhere((key, value) => value == null);

            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            ads[index] = null;
            adsLoaded[index] = false;
            adErrors[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ Ad Manager Native failed at index $index: ${error.message}');
            notifyListeners();
          },
          onAdImpression: (ad) {},
        ),
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

  Future<void> loadAd320x50MobBanner(int index, AdSize size) async {
    try {
      adsBanner320x50[index]?.dispose();

      adsLoaded320x50[index] = false;
      adErrors320x50.remove(index);

      final ad = BannerAd(
        adUnitId: adMobBannerId,
        size: size,
        request: AdRequest(
          keywords: ['vertical'], // Optional content URL for better targeting
          nonPersonalizedAds: false, // Set true if user opted out of personalized ads
          httpTimeoutMillis: 5000, // Optional: HTTP request timeout in milliseconds
        ),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            responseReceived = DateTime.now();

            if (ad != null) {
              adsBanner320x50[index] = ad as BannerAd;
              adsLoaded320x50[index] = true;
            }
            ads.removeWhere((key, value) => value == null);
            debugPrint('✅ 320x50 Ad loaded successfully at index $index');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {

            ad.dispose();
            adsBanner320x50[index] = null;
            adsLoaded320x50[index] = false;
            adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ 320x50 Ad failed at index $index: ${error.message}');
            loadAd320x50ManagerBanner(autoupdate!,size);
            notifyListeners();
          },
          onAdImpression: (ad) {
            adRendered = DateTime.now();
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);

            notifyListeners();
          },
        ),
      );
      if (ad != null) {
        adsBanner320x50[index] = ad;
        await ad.load();
      }
      debugPrint('🔄 320x50 Started loading ad at index $index');
    } catch (e) {
      debugPrint('⚠️ 320x50 Exception loading ad at index $index: $e');
      adErrors320x50[index] = 'Exception: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadAd320x50ManagerBanner(int index, AdSize size) async {
    try {
      adsBanner320x50[index]?.dispose();

      adsLoaded320x50[index] = false;
      adErrors320x50.remove(index);

      final ad = AdManagerBannerAd(
        adUnitId: '/6499/example/banner', // ✅ Ad Manager test ad unit
        sizes: [AdSize.banner], // ✅ Ad Manager expects a list
        request: AdManagerAdRequest(), // ✅ Correct request type
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            responseReceived = DateTime.now();

            if (ad != null) {
              adsBanner320x50[index] = ad as BannerAd;
              adsLoaded320x50[index] = true;
            }
            ads.removeWhere((key, value) => value == null);
            debugPrint('✅  320x50 Ad loaded successfully at index $index');
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            adsBanner320x50[index] = null;
            adsLoaded320x50[index] = false;
            adErrors320x50[index] = 'Failed: ${error.code} - ${error.message}';
            debugPrint('❌ 320x50 Ad failed at index $index: ${error.message}');
            autoBannerCall();
            notifyListeners();
          },
          onAdImpression: (ad) {
            adRendered = DateTime.now();
            impressionLogged = DateTime.now();
            _logLatencyMetrics(ad);

            notifyListeners();
          },
        ),
      );
      if (ad != null) {
        adsBanner320x50[index] = ad;
        await ad.load();
      }
      debugPrint('🔄 320x50 Started loading ad at index $index');
    } catch (e) {
      debugPrint('⚠️ 320x50 Exception loading ad at index $index: $e');
      adErrors320x50[index] = 'Exception: ${e.toString()}';
      notifyListeners();
    }
  }

  int? autoupdate;

  Future<void> autoBannerCall() async {
    autoupdate = (adsBanner320x50.length) + 1;
    Future.delayed(Duration(seconds: 30), () {
      loadAd320x50MobBanner(autoupdate!, AdSize.banner);
    });
    if (autoupdate == adsBanner320x50.length) {

    } else {
      // loadAd320x50MobBanner(autoupdate!, AdSize.banner);
    }
  }

  void _logLatencyMetrics(Ad ad) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? userId = preferences.getString("userId");
    // if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
    //   final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
    //   final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
    //   // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
    //   // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
    //   final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
    //   final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
    //   final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
    //   final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
    //
    //   mainNavigatorKey.currentContext!
    //       .read<HomeProvider>()
    //       .sendDataToads({
    //     "ad_source": 'AdMobBanner',
    //     "user_id":userId.toString(),
    //     "sdk_ready_time": sdkReadyLatency.toString(),
    //     "creative_download": creativeDownloadLatency.toString(),
    //     "render_time": renderLatency.toString(),
    //     "total_time": totalLatency.toString(),
    //     "data": "${ad.responseInfo}",
    //   });
    // }
  }

  void adsLoad() {
    loadAdMobBanner(1, AdSize.mediumRectangle);
    loadAdManagerBanner(2, AdSize.mediumRectangle);
    loadAdMobNative(3, AdSize.mediumRectangle);
    loadAdManagerNative(4, AdSize.mediumRectangle);
  }
}

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}
