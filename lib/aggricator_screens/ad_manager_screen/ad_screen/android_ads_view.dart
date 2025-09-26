import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../ad_provider/ad_mob_banner_provider.dart';
import '../recommended_news.dart';
import 'ios_ads_view.dart';

class AndroidAdsView extends StatelessWidget {
  final dynamic article;
  final int index;

  const AndroidAdsView({super.key, required this.article, required this.index});

  @override
  Widget build(BuildContext context) {
    final adsList = context.watch<AdMobBannerProvider>().ads.values.toList();
    int adIndex = ((index + 1) ~/ 5) - 1;

    log("rdtrdtydyydfydydyyd  $adsList --- $adIndex");
    return (adsList[adIndex] is BannerAd || adsList[adIndex] is AdManagerBannerAd)
        ? Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: 250,
                width: 300,
                alignment: Alignment.center,
                child: AdWidget(ad: adsList[adIndex]!),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: RecommendedNews(
              rList: article['homepage'] ?? [],
            ),
          ),
        ],
      ),
    )
        : adsList[adIndex] is NativeAd
        ? Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AdWidget(ad: adsList[adIndex]!),
    )
        : IosAdsWidgetScreen(
      article: article,
    );
  }
}

//   @override
//   _AndroidAdsViewState createState() => _AndroidAdsViewState();
// }
//
// class _AndroidAdsViewState extends State<AndroidAdsView> {
//
//
// }

// NativeAd? _adManagerNativeAd;
// NativeAd? _adMobNativeAd;
// BannerAd? _bannerAd;
//
// bool _isBannerLoaded = false;
// bool _isAdMobBannerLoaded = false;
// bool _isAdMObLoaded = false;
// bool _isAdShown = false;
// bool _adLoadFailed = false;
// bool _hasTriedLoadingAds = false;
//
// dynamic _shownAd;
// Widget? _adWidget;
//
// String? to = '';
// String? from = '';
// BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;
//
// @override
// void initState() {
//   super.initState();
//   bannerAdsLoading = BannerAdsLoading.loading;
//   _loadAllAds(context);
// }
//
// void _loadAllAds(BuildContext context) {
//   _hasTriedLoadingAds = true;
//   log("ads loading quick...");
//   _loadAdManagerNativeAd(context);
//   _loadAdMobNativeAd(context);
//   _loadBannerAd(context);
//   _loadBannerAdMob(context);
// }
//
// void _loadAdManagerNativeAd(BuildContext context) {
//   String? adUnitId = context.read<HomeProvider>().adManagerNativeId; // Replace with your logic
//
//
//   from = DateTime.now().toString();
//
//   _adManagerNativeAd = NativeAd(
//     adUnitId: adUnitId,
//     factoryId: 'adFactoryExample',
//     listener: NativeAdListener(
//       onAdClosed: (ad) {
//         EventRepo().addEvent( {
//           "onAdClosed":true,
//           "createAt":DateTime.now().toString(),
//           "adResponse":ad.toString(),
//         },"onAdClosed");
//       },
//       onAdOpened: (ad) {
//         EventRepo().addEvent( {
//           "onAdOpened":true,
//           "createAt":DateTime.now().toString(),
//           "adResponse":ad.toString(),
//         },"onAdOpened");
//       },
//       onAdImpression: (ad) {
//         EventRepo().addEvent( {
//           "onAdImpression":true,
//           "createAt":DateTime.now().toString(),
//           "adResponse":ad.toString(),
//         },"onAdImpression");
//       },
//       onAdClicked:  (ad) {
//         EventRepo().addEvent( {
//           "onAdClicked":true,
//           "createAt":DateTime.now().toString(),
//           "adResponse":ad.toString(),
//         },"onAdClicked");
//       },
//       onAdLoaded: (ad) {
//         print('AdManager Native success: ${ad.responseInfo.toString()}');
//         _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
//       },
//       onAdFailedToLoad: (ad, error) {
//         ad.dispose();
//         print('AdManager Native failed: $error');
//         _checkIfAllAdsFailed(error);
//       },
//     ),
//     request: AdRequest(),
//   )..load();
// }
//
// void _loadAdMobNativeAd(BuildContext context) {
//   String? adUnitId = context.read<HomeProvider>().adMobNativeId;
//
//   _adMobNativeAd = NativeAd(
//       adUnitId:adUnitId,
//       listener: NativeAdListener(
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
//                 _isAdMObLoaded = true;
//                 print('AdManager Native success: ${ad.responseInfo.toString()}');
//                 _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
//         },
//         onAdFailedToLoad: (ad, error) {
//                 ad.dispose();
//                 print('AdMob Native failed: $error');
//                 _checkIfAllAdsFailed(error);
//         },
//       ),
//       request: const AdRequest(),
//       // Styling
//       nativeTemplateStyle: NativeTemplateStyle(
//         // Required: Choose a template.
//           templateType: TemplateType.medium,
//           // Optional: Customize the ad's style.
//           mainBackgroundColor: AppColors.cardBackgroundColor,
//           cornerRadius: 10.0,
//           callToActionTextStyle: NativeTemplateTextStyle(
//               textColor: Colors.black,
//               backgroundColor:AppColors.cardBackgroundColor,
//               style: NativeTemplateFontStyle.monospace,
//               size: 16.0),
//           primaryTextStyle: NativeTemplateTextStyle(
//               textColor: Colors.black,
//               backgroundColor: AppColors.cardBackgroundColor,
//               style: NativeTemplateFontStyle.italic,
//               size: 16.0),
//           secondaryTextStyle: NativeTemplateTextStyle(
//               textColor: Colors.black,
//               backgroundColor: AppColors.cardBackgroundColor,
//               style: NativeTemplateFontStyle.bold,
//               size: 16.0),
//           tertiaryTextStyle: NativeTemplateTextStyle(
//               textColor: Colors.black,
//               backgroundColor: AppColors.cardBackgroundColor,
//               style: NativeTemplateFontStyle.normal,
//               size: 16.0)))
//     ..load();
//
//   // _adMobNativeAd = NativeAd(
//   //   adUnitId: adUnitId,
//   //   factoryId: 'adFactoryExample',
//   //   listener: NativeAdListener(
//   //     onAdLoaded: (ad) {
//   //       _isAdMObLoaded = true;
//   //       print('AdManager Native success: ${ad.responseInfo.toString()}');
//   //       _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
//   //     },
//   //     onAdFailedToLoad: (ad, error) {
//   //       ad.dispose();
//   //       print('AdMob Native failed: $error');
//   //       _checkIfAllAdsFailed(error);
//   //     },
//   //   ),
//   //   request: AdRequest(),
//   // )..load();
// }
//
