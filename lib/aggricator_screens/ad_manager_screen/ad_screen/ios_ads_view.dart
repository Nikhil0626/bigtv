import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/globel_keys.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../individual_post_details/individual_post_view.dart';
import '../../loading_screen/ads_loading_screen.dart';
import '../../test_screens/ads_test_data.dart';
import 'google_ads_view.dart';

// class IosAdsWidgetScreen extends StatefulWidget {
//   final article;
//
//   const IosAdsWidgetScreen({super.key, required this.article});
//
//   @override
//   _IosAdsWidgetScreenState createState() => _IosAdsWidgetScreenState();
// }
//
// class _IosAdsWidgetScreenState extends State<IosAdsWidgetScreen> {
//   NativeAd? _adManagerNativeAd;
//   NativeAd? _adMobNativeAd;
//   AdManagerBannerAd? _bannerAd;
//   BannerAd? _bannerAd1;
//   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   bool _isBannerLoaded = false;
//   bool _isAdMObLoaded = false;
//   bool _isAdShown = false;
//   bool _adLoadFailed = false;
//
//   String? source = '';
//
//   DateTime? requestInitiated;
//   DateTime? responseReceived;
//   DateTime? adCreativeDownloaded;
//   DateTime? adRendered;
//   DateTime? impressionLogged;
//   Widget? _adWidget;
//
//   String? to = '';
//   String? from = '';
//
//   @override
//   void initState() {
//     super.initState();
//     source = "";
//     _adLoadFailed = true;
//     _isAdMObLoaded = false;
//     _loadAllAds(context);
//   }
//
//   void _loadAllAds(BuildContext context) {
//     log("ads loading quick...");
//
//     _loadAdManagerNativeAd(context);
//     _loadAdMobNativeAd(context);
//     _loadBannerAd(context);
//     _loadBannerAdMob(context);
//     _loadBannerAdMob1(context);
//   }
//
//   void _loadAdManagerNativeAd(BuildContext context) {
//     String? adUnitId = context.read<HomeProvider>().adManagerNativeId; // Replace with your logic
//
//     from = DateTime.now().toString();
//
//     _adManagerNativeAd = NativeAd(
//       adUnitId: adUnitId,
//       factoryId: 'adFactoryExample',
//       listener: NativeAdListener(
//         onAdImpression: (ad) async {
//           impressionLogged = DateTime.now();
//           await analytics.logEvent(
//             name: "onAdImpression",
//             parameters: {
//               "onAdImpression": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//           _logLatencyMetrics();
//         },
//         onAdClicked: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClicked",
//             parameters: {
//               "onAdClicked": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdClosed: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClosed",
//             parameters: {
//               "onAdClosed": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdOpened: (ad) async {
//           await analytics.logEvent(
//             name: "onAdOpened",
//             parameters: {
//               "onAdOpened": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdLoaded: (ad) {
//           source = "Adm_Native";
//           print('AdManager Native success: ${ad.responseInfo.toString()}');
//           _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           source = "Adm_Native_fail";
//           print('AdManager Native failed: $error');
//           _checkIfAllAdsFailed(error);
//         },
//       ),
//       request: AdRequest(),
//     )..load();
//   }
//
//   void _loadAdMobNativeAd(BuildContext context) {
//     String? adUnitId = context.read<HomeProvider>().adMobNativeId;
//     // String? adUnitId = "	ca-app-pub-3940256099942544/2247696110";
//
//     _adMobNativeAd = NativeAd(
//       adUnitId: adUnitId,
//       factoryId: 'adFactoryExample',
//       listener: NativeAdListener(
//         onAdImpression: (ad) async {
//           impressionLogged = DateTime.now();
//           await analytics.logEvent(
//             name: "onAdImpression",
//             parameters: {
//               "onAdImpression": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//           _logLatencyMetrics();
//         },
//         onAdClicked: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClicked",
//             parameters: {
//               "onAdClicked": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdClosed: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClosed",
//             parameters: {
//               "onAdClosed": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdOpened: (ad) async {
//           await analytics.logEvent(
//             name: "onAdOpened",
//             parameters: {
//               "onAdOpened": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdLoaded: (ad) {
//           Future.delayed(Duration(milliseconds: 500),(){
//             _isAdMObLoaded = true;
//           });
//
//           source = "Am_Native";
//           print('AdManager Native success: ${ad.responseInfo.toString()}');
//           _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           source = "Am_Native_fail";
//           print('AdMob Native failed: $error');
//           _checkIfAllAdsFailed(error);
//         },
//       ),
//       request: AdRequest(),
//     )..load();
//   }
//
//   void _loadBannerAd(BuildContext context) async {
//     String? adUnitId = context.read<HomeProvider>().adManagerBannerId; // Replace with your logic
//     // String? adUnitId = "/21775744923/example/adaptive-banner"; // Replace with your logic
//
//     _bannerAd = AdManagerBannerAd(
//       adUnitId: adUnitId,
//       request: const AdManagerAdRequest(),
//       sizes: <AdSize>[AdSize.mediumRectangle, AdSize.fluid, AdSize.largeBanner],
//       listener: AdManagerBannerAdListener(
//         onAdLoaded: (ad) {
//           _isBannerLoaded = true;
//           source = "Adm_banner";
//           print('AdManager Native success: ${ad.responseInfo.toString()}');
//           _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           source = "Adm_banner_fail";
//           print('Banner failed: $error');
//           _checkIfAllAdsFailed(error);
//         },
//         onAdImpression: (ad) async {
//           impressionLogged = DateTime.now();
//           await analytics.logEvent(
//             name: "onAdImpression",
//             parameters: {
//               "onAdImpression": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//           _logLatencyMetrics();
//         },
//         onAdClicked: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClicked",
//             parameters: {
//               "onAdClicked": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdClosed: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClosed",
//             parameters: {
//               "onAdClosed": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdOpened: (ad) async {
//           await analytics.logEvent(
//             name: "onAdOpened",
//             parameters: {
//               "onAdOpened": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//       ),
//     )..load();
//   }
//
//   void _loadBannerAdMob(BuildContext context) {
//     final adUnitId = context.read<HomeProvider>().adManagerBannerId;
//     // final adUnitId ="ca-app-pub-3940256099942544/6300978111";
//     requestInitiated = DateTime.now();
//     _bannerAd1 = BannerAd(
//       adUnitId: adUnitId,
//       size: AdSize.mediumRectangle,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           source = "Am_Banner";
//           responseReceived = DateTime.now();
//           _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           source = "Adm_banner";
//           _checkIfAllAdsFailed(error);
//         },
//         onAdImpression: (ad) async {
//           impressionLogged = DateTime.now();
//           await analytics.logEvent(
//             name: "onAdImpression",
//             parameters: {
//               "onAdImpression": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//           _logLatencyMetrics();
//         },
//         onAdClicked: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClicked",
//             parameters: {
//               "onAdClicked": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdClosed: (ad) async {
//           await analytics.logEvent(
//             name: "onAdClosed",
//             parameters: {
//               "onAdClosed": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//         onAdOpened: (ad) async {
//           await analytics.logEvent(
//             name: "onAdOpened",
//             parameters: {
//               "onAdOpened": true ? 1 : 0,
//               "createAt": DateTime.now().toString(),
//               "adResponse": "",
//             },
//           );
//         },
//       ),
//     )..load();
//   }
//
//
//
//
//
//   @override
//   void dispose() {
//     _adManagerNativeAd?.dispose();
//     _adMobNativeAd?.dispose();
//     _bannerAd?.dispose();
//     _bannerAd1?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return _adLoadFailed
//         ? AdsLoadingScreen()
//         : _isAdMObLoaded && _adWidget != null
//             ? _adWidget!
//             : _isBannerLoaded && _bannerAd != null
//                 ? Column(
//                     children: [
//                       SizedBox(
//                           height: 300,
//                           width: 250,
//                           child: AdWidget(
//                             ad: _bannerAd!,
//                           )),
//                       Expanded(child: _buildRecommendedNews(context)),
//                     ],
//                   )
//                 : _isBannerLoaded && _bannerAd1 != null
//                     ? Column(
//                         children: [
//                           SizedBox(height: 300, width: 250, child: AdWidget(ad: _bannerAd1!)),
//                           Expanded(child: _buildRecommendedNews(context)),
//                         ],
//                       )
//                     : _adWidget != null
//                         ? Column(
//                             children: [
//                               Expanded(flex: 1, child: Center(child: Container(color: Colors.teal.shade200, height: 250, width: 300, child: _adWidget!))),
//                               Expanded(flex: 1, child: _buildRecommendedNews(context)),
//                             ],
//                           )
//                         : Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: widget.article['adType'] == "rating card"
//                                     ? RateYourApp()
//                                     : widget.article['adType'] == "share card"
//                                         ? ShareYourApp()
//                                         : ShareYourApp(),
//                               ),
//                               Expanded(flex: 1, child: _buildRecommendedNews(context)),
//                             ],
//                           );
//
//   }
//
// }
//
// void _onAdLoaded(dynamic ad, Widget adWidget) async {
//   to = DateTime.now().toString();
//
//   if (_isAdShown) {
//     ad.dispose();
//     return;
//   }
//
//
//   if (ad != _adManagerNativeAd) {
//     _adManagerNativeAd?.dispose();
//     _adManagerNativeAd = null;
//   }
//   if (ad != _adMobNativeAd) {
//     _adMobNativeAd?.dispose();
//     _adMobNativeAd = null;
//   }
//   if (ad != _bannerAd) {
//     _bannerAd?.dispose();
//     _bannerAd = null;
//   }
//   if (ad != _bannerAd1) {
//     _bannerAd1?.dispose();
//     _bannerAd1 = null;
//   }
//
//
//   Future.delayed(Duration(milliseconds: 500),(){
//     setState(() {
//       _isAdShown = true;
//       _adWidget = adWidget;
//       _adLoadFailed = false;
//     });
//   });
//
//   // bool noAdUnits = (_adManagerNativeAd == null && _adMobNativeAd == null && _bannerAd == null && _bannerAd1 == null);
//   await analytics.logEvent(
//     name: "ads_success",
//     parameters: {
//       "adSource": source.toString(),
//       "sdkRequestStartTime": requestInitiated.toString(),
//       "sdkRequestReceivedTime": responseReceived.toString(),
//       "adsRenderingTime": "0",
//       "createAt": DateTime.now().toString(),
//       "adResponse": "",
//     },
//   );
// }
// void _checkIfAllAdsFailed(LoadAdError error) async {
//   Future.delayed(Duration(milliseconds: 500),(){
//     setState(() {
//       _adLoadFailed = false;
//     });
//   });
//
//   await analytics.logEvent(
//     name: "ads_failure",
//     parameters: {
//       "adSource": source.toString(),
//       "sdkRequestStartTime": requestInitiated.toString(),
//       "sdkRequestReceivedTime": responseReceived.toString(),
//       "adsRenderingTime": "0",
//       "createAt": DateTime.now().toString(),
//       "adResponse": error.responseInfo.toString(),
//     },
//   );
// }
//
// void _logLatencyMetrics() async {
//   if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
//     final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
//     final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
//     final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
//     final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
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
//         "latency_render": renderLatency.toString(),
//         "latency_total": totalLatency.toString(),
//         "createAt": DateTime.now().toString(),
//       },
//     );
//   }
// }

// void _loadBannerAdMob1(BuildContext context) {
//   final adUnitId = context.read<HomeProvider>().adMobBannerId;
//   // final adUnitId ="ca-app-pub-3940256099942544/6300978111";
//   requestInitiated = DateTime.now();
//   _bannerAd1 = BannerAd(
//     adUnitId: adUnitId,
//     size: AdSize.largeBanner,
//     request: const AdRequest(),
//     listener: BannerAdListener(
//       onAdLoaded: (ad) {
//         source = "Am_Banner_small";
//         responseReceived = DateTime.now();
//         _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
//       },
//       onAdFailedToLoad: (ad, error) {
//         ad.dispose();
//         source = "Adm_banner";
//         _checkIfAllAdsFailed(error);
//       },
//       onAdImpression: (ad) async {
//         impressionLogged = DateTime.now();
//         await analytics.logEvent(
//           name: "onAdImpression",
//           parameters: {
//             "onAdImpression": true,
//             "createAt": DateTime.now().toString(),
//             "adResponse": "",
//           },
//         );
//         _logLatencyMetrics();
//       },
//       onAdClicked: (ad) async {
//         await analytics.logEvent(
//           name: "onAdClicked",
//           parameters: {
//             "onAdClicked": true,
//             "createAt": DateTime.now().toString(),
//             "adResponse": "",
//           },
//         );
//       },
//       onAdClosed: (ad) async {
//         await analytics.logEvent(
//           name: "onAdClosed",
//           parameters: {
//             "onAdClosed": true,
//             "createAt": DateTime.now().toString(),
//             "adResponse": "",
//           },
//         );
//       },
//       onAdOpened: (ad) async {
//         await analytics.logEvent(
//           name: "onAdOpened",
//           parameters: {
//             "onAdOpened": true,
//             "createAt": DateTime.now().toString(),
//             "adResponse": "",
//           },
//         );
//       },
//     ),
//   )..load();
// }

class IosAdsWidgetScreen extends StatefulWidget {
  final article;

  const IosAdsWidgetScreen({super.key, required this.article});

  @override
  _IosAdsWidgetScreenState createState() => _IosAdsWidgetScreenState();
}

class _IosAdsWidgetScreenState extends State<IosAdsWidgetScreen> {
  NativeAd? _adManagerNativeAd;
  NativeAd? _adMobNativeAd;
  AdManagerBannerAd? _bannerAd;
  BannerAd? _bannerAd1;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Widget? _adWidget;

  String adDisplayState = 'loading'; // 'loading', 'adReady', 'fallback'
  String source = ''; // 'loading', 'adReady', 'fallback'

  DateTime? impressionLogged;

  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;

  @override
  void initState() {
    super.initState();
    _loadAllAds(context);
  }

  void _loadAllAds(BuildContext context) {
    requestInitiated = DateTime.now();
    _loadAdManagerNativeAd(context);
    _loadAdMobNativeAd(context);
    _loadBannerAd(context);
    _loadBannerAdMob(context);
  }


  void _onAdLoaded(Ad ad, Widget adWidget) {
    if (adDisplayState != 'adReady') {
      Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _adWidget = adWidget;
        adDisplayState = 'adReady';
      });
      });
    }
  }

  void _checkIfAllAdsFailed(LoadAdError error) {
    Future.delayed(Duration(milliseconds: 800), () {
      if (_adWidget == null && mounted) {
        setState(() {
          adDisplayState = 'fallback';
        });
      }
    });
  }

  void _loadAdManagerNativeAd(BuildContext context) {
    requestInitiated = DateTime.now();
    final adUnitId = context.read<HomeProvider>().adManagerNativeId;
    // _adManagerNativeAd = NativeAd(
    //   adUnitId: adUnitId,
    //   factoryId: 'adFactoryExample',
    //   listener: NativeAdListener(
    //       onAdLoaded: (ad) {
    //         print("AdManager native loaded");
    //         _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
    //       },
    //       onAdFailedToLoad: (ad, error) {
    //         print("AdManager native failed: $error");
    //         ad.dispose();
    //         _checkIfAllAdsFailed(error);
    //       },
    //   ),
    //   request: AdManagerAdRequest(), // ✅ Required for GAM ads
    // )..load();


    _adManagerNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          source ="Native Manager";
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) async {
          impressionLogged = DateTime.now();
          await _logEvent("onAdImpression");
          _logLatencyMetrics(ad);
        },
        onAdClicked: (ad) async => await _logEvent("onAdClicked"),
        onAdClosed: (ad) async => await _logEvent("onAdClosed"),
        onAdOpened: (ad) async => await _logEvent("onAdOpened"),
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadAdMobNativeAd(BuildContext context) {
    requestInitiated = DateTime.now();
    final adUnitId = context.read<HomeProvider>().adMobNativeId;
    // String? adUnitId = "ca-app-pub-3940256099942544/2247696110";
    _adMobNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          source ="Native Mob";
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) async {
          impressionLogged = DateTime.now();
          await _logEvent("onAdImpression");
          _logLatencyMetrics( ad);
        },
        onAdClicked: (ad) async => await _logEvent("onAdClicked"),
        onAdClosed: (ad) async => await _logEvent("onAdClosed"),
        onAdOpened: (ad) async => await _logEvent("onAdOpened"),
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadBannerAd(BuildContext context) {
    requestInitiated = DateTime.now();
    final adUnitId = context.read<HomeProvider>().adManagerBannerId;
    // final adUnitId = "/6499/example/banner";

    _bannerAd = AdManagerBannerAd(
      adUnitId: adUnitId,
      request: const AdManagerAdRequest(),
      sizes: [AdSize.mediumRectangle],
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          source ="Banner Manager";
          _onAdLoaded(ad, AdWidget(ad: ad as AdManagerBannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) async {
          impressionLogged = DateTime.now();
          await _logEvent("onAdImpression");
          _logLatencyMetrics( ad);
        },
        onAdClicked: (ad) async => await _logEvent("onAdClicked"),
        onAdClosed: (ad) async => await _logEvent("onAdClosed"),
        onAdOpened: (ad) async => await _logEvent("onAdOpened"),
      ),
    )..load();
  }

  void _loadBannerAdMob(BuildContext context) {
    requestInitiated = DateTime.now();
    final adUnitId = context.read<HomeProvider>().adMobBannerId;

    _bannerAd1 = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          source ="Banner MOb";
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) async {
          impressionLogged = DateTime.now();
          await _logEvent("onAdImpression");
          _logLatencyMetrics( ad);
        },
        onAdClicked: (ad) async => await _logEvent("onAdClicked"),
        onAdClosed: (ad) async => await _logEvent("onAdClosed"),
        onAdOpened: (ad) async => await _logEvent("onAdOpened"),
      ),
    )..load();
  }

  Future<void> _logEvent(String name) async {
    await analytics.logEvent(name: name, parameters: {
      "event": name,
      "timestamp": DateTime.now().toString(),
    });
  }

  void _logLatencyMetrics(Ad ad) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    log(    "ad_source : $source",);
    final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
    final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
    // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
    // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
    final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
    final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
    final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
    final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;

    mainNavigatorKey.currentContext!
        .read<HomeProvider>()
        .sendDataToads({
      "sdk_ready_time": sdkReadyLatency.toString(),
      "creative_download": creativeDownloadLatency.toString(),
      "render_time": renderLatency.toString(),
      "total_time": totalLatency.toString(),
      "data": "${ad.responseInfo}",
    });
      await analytics.logEvent(
        name: "ad_latency_metrics",
        parameters: {
          "adSource": source.toString(),
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
    // }
  }

  @override
  void dispose() {
    _adManagerNativeAd?.dispose();
    _adMobNativeAd?.dispose();
    _bannerAd?.dispose();
    _bannerAd1?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (adDisplayState == 'loading') {
      return AdsLoadingScreen();
    } else if (adDisplayState == 'adReady' && _adWidget != null) {
      return Column(
        children: [
          Expanded(flex: 1, child: Center(child: Container(color: Colors.teal.shade200, height: 250, width: 300, child: _adWidget!))),
          Expanded(flex: 1, child: buildRecommendedNews(context)),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: widget.article['adType'] == "rating card" ? RateYourApp() : ShareYourApp(),
          ),
          Expanded(child: buildRecommendedNews(context)),
        ],
      );
    }
  }

  Widget buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdsTestData(),));
            },
            child: Text("Show ads response click here", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor))),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final post = widget.article["homepage"]![index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndividualPostView1(
                        postId: post['id'].toString(),
                        isComeFrom: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.wColor,
                    border: Border.all(width: 2, color: AppColors.wColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post['image_url'].toString(),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.borderColor.withOpacity(.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                              child: Icon(Icons.image, size: 30, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      width(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post["title"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor),
                            ),
                            height(height: 2),
                            Row(
                              children: [
                                index == 0
                                    ? SvgPicture.asset("assets/svg/like.svg", height: 16, width: 16)
                                    : index == 2
                                        ? SvgPicture.asset("assets/svg/share.svg", height: 16, width: 16)
                                        : SvgPicture.asset("assets/svg/eye.svg", height: 16, width: 16),
                                width(width: 6),
                                Text(
                                  index == 0
                                      ? "టాప్ లైక్స్"
                                      : index == 2
                                          ? "టాప్ షేర్‌డ్"
                                          : "టాప్ వ్యూడ్",
                                  style: fontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
