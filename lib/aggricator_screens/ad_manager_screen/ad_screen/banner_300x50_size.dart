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
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
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
  BannerAd? _adManagerBanner;
  BannerAd? _displayedAd;
  BannerAdsLoading _loadingState = BannerAdsLoading.loading;
  bool _adMobFailed = false;
  bool _adManagerFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBothAdsInParallel();
  }

  void _loadBothAdsInParallel() {
    _loadAdManagerBanner();
    _loadAdMobBanner();
  }

  void _loadAdMobBanner() {
    final fromTime = DateTime.now().toString();
    log(context.read<HomeProvider>().adMobBannerId);
    _adMobBanner = BannerAd(
      adUnitId: context.read<HomeProvider>().adMobBannerId,
      // adUnitId: "/6499/example/banner",
      size: AdSize(width: 320, height: 50),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdClosed: _logAdEvent("onAdClosed"),
        onAdOpened: _logAdEvent("onAdOpened"),
        onAdImpression: _logAdEvent("onAdImpression"),
        onAdClicked: _logAdEvent("onAdClicked"),
        onAdLoaded: (ad) => _handleAdLoaded(ad as BannerAd, "AdMob", fromTime),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adMobFailed = true;
          _handleAdFailed("AdMob", error.responseInfo?.toString() ?? 'No info', fromTime);
        },
      ),
    )..load();
  }

  void _loadAdManagerBanner() {
    final fromTime = DateTime.now().toString();
    log(context.read<HomeProvider>().adManagerBannerId);
    _adManagerBanner = BannerAd(
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      // adUnitId: "/6499/example/banner",
      size: AdSize.banner,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdClosed: _logAdEvent("onAdClosed"),
        onAdOpened: _logAdEvent("onAdOpened"),
        onAdImpression: _logAdEvent("onAdImpression"),
        onAdClicked: _logAdEvent("onAdClicked"),
        onAdLoaded: (ad) => _handleAdLoaded(ad as BannerAd, "AdManager", fromTime),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adManagerFailed = true;
          _handleAdFailed("AdManager", error.responseInfo?.toString() ?? 'No info', fromTime);
        },
      ),
    )..load();
  }

  _logAdEvent(String eventType) => (ad) {
        EventRepo().addEvent({
          eventType: true,
          "createAt": DateTime.now().toString(),
          "adResponse": ad.toString(),
        }, eventType);
      };

  void _handleAdLoaded(BannerAd ad, String source, String fromTime) {
    if (_displayedAd == null && mounted) {
      final toTime = DateTime.now().toString();

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

      EventRepo().addEvent({
        "sdkRequestStartTime": fromTime.toString(),
        "sdkRequestReceivedTime": toTime.toString(),
        "adsRenderingTime": DateTime.now().difference(DateTime.parse(toTime)).inMicroseconds.toString(),
        "createAt": DateTime.now().toString(),
        "adSource": source,
        "adResponse": ad.responseInfo.toString(),
      }, "ads_success");
    } else {
      ad.dispose();
    }
  }

  void _handleAdFailed(String source, String response, String fromTime) {
    final toTime = DateTime.now().toString();

    EventRepo().addEvent({
      "sdkRequestStartTime": fromTime.toString(),
      "sdkRequestReceivedTime": toTime.toString(),
      "adsRenderingTime": "0",
      "createAt": DateTime.now().toString(),
      "adSource": source,
      "adResponse": response.toString(),
    }, "ads_failure");

    if (_adMobFailed && _adManagerFailed && _displayedAd == null) {
      setState(() {
        _loadingState = BannerAdsLoading.fail;
      });
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
