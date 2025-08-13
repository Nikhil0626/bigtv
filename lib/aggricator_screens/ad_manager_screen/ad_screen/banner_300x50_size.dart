// import 'dart:developer';
//
// import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../loading_screen/Banner300x50Size_loading.dart';
// import '../../utils/app_enums.dart';
// import '../event_repo.dart';
// import '../home_screen/home_provider/home_provider.dart';
//
// class Banner300x50Size extends StatefulWidget {
//   const Banner300x50Size({super.key});
//
//   @override
//   State<Banner300x50Size> createState() => _Banner300x50SizeState();
// }
//
// class _Banner300x50SizeState extends State<Banner300x50Size> {
//   BannerAd? _bannerAd;
//   BannerAdsLoading _loadingState = BannerAdsLoading.loading;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBannerAd(context);
//   }
//
//   void _loadBannerAd(BuildContext context) async {
//     final AdSize customAdSize = AdSize(width: 320, height: 50);
//     String? from = DateTime.now().toString();
//
//     final ad = BannerAd(
//       adUnitId: context.read<HomeProvider>().adManagerBannerId,
//       size: customAdSize,
//       request: const AdManagerAdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) async {
//           final to = DateTime.now().toString();
//           setState(() {
//             _bannerAd = ad as BannerAd;
//             _loadingState = BannerAdsLoading.success;
//           });
//
//            EventRepo().addEvent({
//             "sdkRequestStartTime": from,
//             "sdkRequestReceivedTime": to,
//             "adsRenderingTime": DateTime.now().difference(DateTime.parse(to)).inMicroseconds.toString(),
//             "createAt": DateTime.now().toString(),
//             "adResponse": ad.responseInfo.toString(),
//           }, "ads_success");
//         },
//         onAdFailedToLoad: (ad, error) async {
//           final to = DateTime.now().toString();
//            EventRepo().addEvent({
//             "sdkRequestStartTime": from,
//             "sdkRequestReceivedTime": to,
//             "adsRenderingTime": "0",
//             "createAt": DateTime.now().toString(),
//             "adResponse": error.responseInfo.toString(),
//           }, "ads_failure");
//           ad.dispose();
//           setState(() {
//             _loadingState = BannerAdsLoading.fail;
//           });
//         },
//       ),
//     );
//
//     ad.load();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     switch (_loadingState) {
//       case BannerAdsLoading.loading:
//         return const Center(child: Banner300x50sizeLoading());
//       case BannerAdsLoading.success:
//         return SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: 50,
//           child: _bannerAd != null ? AdWidget(ad: _bannerAd!) : const SizedBox.shrink(),
//         );
//       case BannerAdsLoading.fail:
//         return const SizedBox.shrink();
//     }
//   }
// }

// import 'dart:developer';
// import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../loading_screen/Banner300x50Size_loading.dart';
// import '../../utils/app_enums.dart';
// import '../event_repo.dart';
// import '../home_screen/home_provider/home_provider.dart';
//
// class Banner300x50Size extends StatefulWidget {
//   const Banner300x50Size({super.key});
//
//   @override
//   State<Banner300x50Size> createState() => _Banner300x50SizeState();
// }
//
// class _Banner300x50SizeState extends State<Banner300x50Size> {
//   BannerAd? _adMobBanner;
//   BannerAd? _adManagerBanner;
//   BannerAd? _displayedAd;
//   BannerAdsLoading _loadingState = BannerAdsLoading.loading;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBothAdsInParallel();
//   }
//
//   void _loadBothAdsInParallel() {
//     _loadAdManagerBanner();
//     _loadAdMobBanner();
//
//   }
//
//   void _loadAdMobBanner() {
//     final fromTime = DateTime.now().toString();
//
//     _adMobBanner = BannerAd(
//       adUnitId: context.read<HomeProvider>().adMobBannerId, // Replace with your AdMob Unit ID
//       size: AdSize.banner,
//       request: const AdRequest(nonPersonalizedAds: true),
//       listener: BannerAdListener(
//         onAdClosed: (ad) {
//           EventRepo().addEvent( {
//             "onAdClosed":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdClosed");
//         },
//         onAdOpened: (ad) {
//           EventRepo().addEvent( {
//             "onAdOpened":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdOpened");
//         },
//         onAdImpression: (ad) {
//           EventRepo().addEvent( {
//             "onAdImpression":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdImpression");
//         },
//         onAdClicked:  (ad) {
//           EventRepo().addEvent( {
//             "onAdClicked":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdClicked");
//         },
//         onAdLoaded: (ad) {
//           _handleAdLoaded(ad as BannerAd, "AdMob", fromTime);
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _handleAdFailed("AdMob", error.responseInfo?.toString() ?? 'No info', fromTime);
//         },
//       ),
//     )..load();
//   }
//
//   void _loadAdManagerBanner() {
//     final fromTime = DateTime.now().toString();
//
//     _adManagerBanner = BannerAd(
//       adUnitId: context.read<HomeProvider>().adManagerBannerId,
//       size: AdSize.banner,
//       request: const AdManagerAdRequest(),
//       listener: BannerAdListener(
//         onAdClosed: (ad) {
//           EventRepo().addEvent( {
//             "onAdClosed":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdClosed");
//         },
//         onAdOpened: (ad) {
//           EventRepo().addEvent( {
//             "onAdOpened":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdOpened");
//         },
//         onAdImpression: (ad) {
//           EventRepo().addEvent( {
//             "onAdImpression":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdImpression");
//         },
//         onAdClicked:  (ad) {
//           EventRepo().addEvent( {
//             "onAdClicked":true,
//             "createAt":DateTime.now().toString(),
//             "adResponse":ad.toString(),
//           },"onAdClicked");
//         },
//         onAdLoaded: (ad) {
//           _handleAdLoaded(ad as BannerAd, "AdManager", fromTime);
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _handleAdFailed("AdManager", error.responseInfo?.toString() ?? 'No info', fromTime);
//         },
//       ),
//     )..load();
//   }
//
//   void _handleAdLoaded(BannerAd ad, String source, String fromTime) {
//     if (_displayedAd == null && mounted) {
//       final toTime = DateTime.now().toString();
//
//       setState(() {
//         _displayedAd = ad;
//         _loadingState = BannerAdsLoading.success;
//       });
//
//       // Dispose the other one if it's still pending
//       if (source == "AdMob") {
//         _adManagerBanner?.dispose();
//       } else {
//         _adMobBanner?.dispose();
//       }
//
//       EventRepo().addEvent({
//         "sdkRequestStartTime": fromTime,
//         "sdkRequestReceivedTime": toTime,
//         "adsRenderingTime": DateTime.now().difference(DateTime.parse(toTime)).inMicroseconds.toString(),
//         "createAt": DateTime.now().toString(),
//         "adSource": source,
//         "adResponse": ad.responseInfo.toString(),
//       }, "ads_success");
//     } else {
//       // Dispose if another ad already loaded
//       ad.dispose();
//     }
//   }
//
//   void _handleAdFailed(String source, String response, String fromTime) {
//     final toTime = DateTime.now().toString();
//
//     EventRepo().addEvent({
//       "sdkRequestStartTime": fromTime,
//       "sdkRequestReceivedTime": toTime,
//       "adsRenderingTime": "0",
//       "createAt": DateTime.now().toString(),
//       "adSource": source,
//       "adResponse": response,
//     }, "ads_failure");
//
//     // If both failed
//     if (_adMobBanner == null && _adManagerBanner == null && _displayedAd == null) {
//       setState(() {
//         _loadingState = BannerAdsLoading.fail;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _adMobBanner?.dispose();
//     _adManagerBanner?.dispose();
//     _displayedAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     switch (_loadingState) {
//       case BannerAdsLoading.loading:
//         return const Center(child: Banner300x50sizeLoading());
//       case BannerAdsLoading.success:
//         return SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: 50,
//           child: _displayedAd != null ? AdWidget(ad: _displayedAd!) : const SizedBox.shrink(),
//         );
//       case BannerAdsLoading.fail:
//         return const SizedBox.shrink();
//     }
//   }
// }
//

import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../globel_keys/globel_keys.dart';
import '../../../utils/app_enums.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../loading_screen/Banner300x50Size_loading.dart';

class Banner300x50Size extends StatefulWidget {
  const Banner300x50Size({super.key});

  @override
  State<Banner300x50Size> createState() => _Banner300x50SizeState();
}

class _Banner300x50SizeState extends State<Banner300x50Size> {
  BannerAd? _adMobBanner;
  AdManagerBannerAd? _adManagerBanner;
  BannerAd? _displayedAd;
  BannerAdsLoading _loadingState = BannerAdsLoading.loading;
  bool _adMobFailed = false;
  bool _adManagerFailed = false;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int count = 0;

  DateTime? impressionLogged;
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;

  @override
  void initState() {
    super.initState();
    count = 0;
    _loadBothAdsInParallel();
  }

  void _loadBothAdsInParallel() {
    _loadAdManagerBanner();
  }

  void _loadAdMobBanner() {
    final fromTime = DateTime.now().toString();
    final adUnitId = context.read<HomeProvider>().adMobBannerId;

    log('AdMob Banner Ad Unit ID: $adUnitId');

    _adMobBanner = BannerAd(
      adUnitId: adUnitId, // Use real AdMob ID in production
      size: AdSize.banner,
      request: const AdRequest(),

      listener: BannerAdListener(

        onAdLoaded: (Ad ad) {
          _handleAdLoaded(ad as BannerAd, "AdMob", fromTime);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _adMobFailed = true;
          count += 1;

          _handleAdFailed("AdMob", error.message, fromTime);

          if (count < 6) {
            Future.delayed(
              const Duration(seconds: 5),
                  () {
                _loadAdManagerBanner();
              },
            );
          }
        },
        onAdOpened: (Ad ad) {
          _logAdEvent("onAdOpened", "");
        },
        onAdClosed: (Ad ad) {
          _logAdEvent("onAdClosed", "");
        },
        onAdImpression: (Ad ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics(ad);
          _logAdEvent("onAdImpression", "");
        },
        onAdClicked: (Ad ad) {
          _logAdEvent("onAdClicked", "");
        },
      ),
    )..load();
  }

  void _loadAdManagerBanner() {
    final fromTime = DateTime.now().toString();

    log(context.read<HomeProvider>().adManagerBannerId);

    // Dispose the previous ad if exists
    _adManagerBanner?.dispose();

    _adManagerBanner = AdManagerBannerAd(

      // adUnitId: "/6499/example/banner", // Replace with your real ad unit in production
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      sizes:[AdSize.banner],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdClosed: (ad) {
          ad.dispose();
          _logAdEvent("onAdClosed", "");
        },
        onAdOpened: (ad) => _logAdEvent("onAdOpened", ""),
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics(ad);
          _logAdEvent("onAdImpression", "");
        },
        onAdClicked: (ad) => _logAdEvent("onAdClicked", ""),
        onAdLoaded: (ad) {
          _handleAdLoaded(ad , "AdManager", fromTime);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adManagerFailed = true;
          _handleAdFailed("AdManager", error.responseInfo?.toString() ?? 'No info', fromTime);
          Future.delayed(
            const Duration(seconds: 5),
                () {
              log("Hello count increase $count");
              _loadAdMobBanner(); // fallback
            },
          );
        },
      ),
    )..load();
  }


  Future<void> _logAdEvent(eventType, ads) async {
    await analytics.logEvent(
      name: "$eventType",
      parameters: {
        "${eventType}": true ? 1 : 0,
        "createAt": DateTime.now().toString(),
        "adResponse": ads.toString(),
      },
    );
  }

  void _handleAdLoaded( ad, String source, String fromTime) async {
    if (_displayedAd == null && mounted) {
      final toTime = DateTime.now().toString();
      context.read<HomeProvider>().isBannerAdLoaded(true);
      setState(() {
        _displayedAd = ad;
        _loadingState = BannerAdsLoading.success;
      });

      // Dispose the other one
      if (source == "AdMob") {
        _adManagerBanner?.dispose();
        _adManagerBanner = null;
      } else {
        _adMobBanner?.dispose();
        _adMobBanner = null;
      }

      await analytics.logEvent(
        name: 'ads_success',
        parameters: {
          "sdkRequestStartTime": fromTime.toString(),
          "sdkRequestReceivedTime": toTime.toString(),
          "adsRenderingTime": DateTime.now().difference(DateTime.parse(toTime)).inMicroseconds.toString(),
          "createAt": DateTime.now().toString(),
          "adSource": source,
          "adResponse": "",
        },
      );
    } else {
      ad.dispose();
    }
  }

  void _handleAdFailed(String source, String response, String fromTime) async {
    final toTime = DateTime.now().toString();

    await analytics.logEvent(
      name: 'ads_failure',
      parameters: {
        "sdkRequestStartTime": fromTime.toString(),
        "sdkRequestReceivedTime": toTime.toString(),
        "adsRenderingTime": "0",
        "createAt": DateTime.now().toString(),
        "adSource": source,
        "adResponse": response.toString(),
      },
    );

    if (_adMobFailed && _adManagerFailed && _displayedAd == null) {
      setState(() {
        _loadingState = BannerAdsLoading.fail;
      });
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

      mainNavigatorKey.currentContext!
          .read<HomeProvider>()
          .sendDataToads({
        "ad_source": "banner320X50",
        "user_id":userId.toString(),
        "sdk_ready_time": sdkReadyLatency.toString(),
        "creative_download": creativeDownloadLatency.toString(),
        "render_time": renderLatency.toString(),
        "total_time": totalLatency.toString(),
        "data": "${ad.responseInfo}",
      });

     await analytics.logEvent(
        name: "ad_latency_metrics",
        parameters: {
          "adSource": "Banner 320x50",
          "requestInitiated": requestInitiated.toString(),
          "responseReceived": responseReceived.toString(),
          "adCreativeDownloaded": adCreativeDownloaded.toString(),
          "adRendered": adRendered.toString(),
          "impressionLogged": impressionLogged.toString(),
          "latency_request": requestLatency.toString(),
          "latency_load": loadLatency.toString(),
          "latency_render": renderLatency.toString(),
          "latency_total": totalLatency.toString(),
          "createAt": DateTime.now().toString(),
        },
      );
    }
  }


  @override
  void dispose() {
    _adMobBanner?.dispose();
    _adManagerBanner?.dispose();
    _displayedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingState) {
      case BannerAdsLoading.loading:
        return const Center(child: Banner300x50sizeLoading());
      case BannerAdsLoading.success:
        return Center(child: SizedBox(width: 320, height: 50, child: _displayedAd != null ? Center(child: AdWidget(ad: _displayedAd!)) : const SizedBox.shrink()));
      case BannerAdsLoading.fail:
        return const SizedBox.shrink();
    }
  }
}
