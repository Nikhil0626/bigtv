
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/recommended_news.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../individual_post_details/individual_post_view.dart';
import '../../test_screens/ads_test_data.dart';
import '../rate_your_app.dart';
import '../share_app.dart';

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



  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  return Column(
    children: [
      Expanded(
        child: widget.article['adType'] == "rating card" ? RateYourApp() : ShareYourApp(),
      ),
      Expanded(child: RecommendedNews(rList: widget.article['homepage'] ??[],),)
    ],
  );
  }

}
