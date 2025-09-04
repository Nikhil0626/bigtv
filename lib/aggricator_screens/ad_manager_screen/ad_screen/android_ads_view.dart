import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../individual_post_details/individual_post_view.dart';
import '../../loading_screen/ads_loading_screen.dart';
import '../../test_screens/ads_test_data.dart';
import 'google_ads_view.dart';

class FullScreenNativeAd extends StatefulWidget {
  final dynamic article;

  const FullScreenNativeAd({super.key, required this.article});

  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.article['adType'] == "rating card" ? RateYourApp() : ShareYourApp(),
          ),
        ),
        Expanded(child: _buildRecommendedNews(context)),
      ],
    );
  }

  Widget _buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdsTestData(),
                  ));
            },
            child: Text("Recommended News", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor))),
        height(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            physics: const NeverScrollableScrollPhysics(),
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
                            color: AppColors.borderColor.withOpacity(.2),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, size: 30, color: Colors.white),
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
