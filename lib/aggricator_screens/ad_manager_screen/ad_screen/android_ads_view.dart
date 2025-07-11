import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../individual_post_details/individual_post_view.dart';
import '../../loading_screen/ads_loading_screen.dart';
import 'google_ads_view.dart';

class FullScreenNativeAd extends StatefulWidget {
  final dynamic article;

  const FullScreenNativeAd({super.key, required this.article});

  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  NativeAd? _adManagerNativeAd;
  NativeAd? _adMobNativeAd;
  BannerAd? _bannerAd;
  BannerAd? _bannerAd1;
  Widget? _adWidget;
  String? source = '';

  bool _adDisplayed = false;
  int _failCount = 0;
  bool _hasTriedLoadingAds = false;
  BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;

  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;

  @override
  void initState() {
    super.initState();
    bannerAdsLoading = BannerAdsLoading.loading;
    _loadAllAds(context);
  }

  void _loadAllAds(BuildContext context) {
    _hasTriedLoadingAds = true;
    _loadAdManagerNativeAd(context);
    _loadAdMobNativeAd(context);
    _loadBannerAd(context);
    _loadBannerAdMob(context);
  }

  void _loadAdManagerNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adManagerNativeId;
    requestInitiated = DateTime.now();

    _adManagerNativeAd = NativeAd(
      adUnitId: adUnitId,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          source = "Adm_Native";
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics();
          EventRepo().addEvent({
            "onAdImpression": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdImpression");
        },
        onAdClicked: (ad) {
          EventRepo().addEvent({
            "onAdClicked": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClicked");
        },
        onAdClosed: (ad) {
          EventRepo().addEvent({
            "onAdClosed": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClosed");
        },
        onAdOpened: (ad) {
          EventRepo().addEvent({
            "onAdOpened": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdOpened");
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadAdMobNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adMobNativeId;
    requestInitiated = DateTime.now();

    _adMobNativeAd = NativeAd(
      adUnitId: adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          source = "Am_Native";
          responseReceived = DateTime.now();
          adCreativeDownloaded = DateTime.now();
          adRendered = DateTime.now();
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics();
          EventRepo().addEvent({
            "onAdImpression": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdImpression");
        },
        onAdClicked: (ad) {
          EventRepo().addEvent({
            "onAdClicked": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClicked");
        },
        onAdClosed: (ad) {
          EventRepo().addEvent({
            "onAdClosed": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClosed");
        },
        onAdOpened: (ad) {
          EventRepo().addEvent({
            "onAdOpened": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdOpened");
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.cardBackgroundColor,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: AppColors.cardBackgroundColor,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: AppColors.cardBackgroundColor,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: AppColors.cardBackgroundColor,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: AppColors.cardBackgroundColor,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    )..load();
  }

  void _loadBannerAd(BuildContext context) {
    final adUnitId = context.read<HomeProvider>().adManagerBannerId;
    requestInitiated = DateTime.now();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          source = "Adm_Banner";
          responseReceived = DateTime.now();
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics();
          EventRepo().addEvent({
            "onAdImpression": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdImpression");
        },
        onAdClicked: (ad) {
          EventRepo().addEvent({
            "onAdClicked": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClicked");
        },
        onAdClosed: (ad) {
          EventRepo().addEvent({
            "onAdClosed": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClosed");
        },
        onAdOpened: (ad) {
          EventRepo().addEvent({
            "onAdOpened": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdOpened");
        },
      ),
    )..load();
  }

  void _loadBannerAdMob(BuildContext context) {
    final adUnitId = context.read<HomeProvider>().adMobBannerId;
    requestInitiated = DateTime.now();
    _bannerAd1 = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          source = "Am_Banner";
          responseReceived = DateTime.now();
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _checkIfAllAdsFailed(error);
        },
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencyMetrics();
          EventRepo().addEvent({
            "onAdImpression": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdImpression");
        },
        onAdClicked: (ad) {
          EventRepo().addEvent({
            "onAdClicked": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClicked");
        },
        onAdClosed: (ad) {
          EventRepo().addEvent({
            "onAdClosed": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdClosed");
        },
        onAdOpened: (ad) {
          EventRepo().addEvent({
            "onAdOpened": true,
            "createAt": DateTime.now().toString(),
            "adResponse": ad.toString(),
          }, "onAdOpened");
        },
      ),
    )..load();
  }

  bool adsEmptyCheck( input,) {
    if (input == null) return false;

    if (input is Iterable || input is Map || input is String) {
      return input.isNotEmpty;
    }

    return true; // For objects or primitives
  }

  void _onAdLoaded(dynamic ad, Widget adWidget) {
    if (_adDisplayed) {
      ad.dispose();
      return;
    }
    // if(adsEmptyCheck(ad.responseInfo.adResponse.loadedAdapterResponseInfo) && adsEmptyCheck(ad.responseInfo.adResponse.adapterResponses))

    _adDisplayed = true;
    _failCount = 0;
    final wrappedAdWidget = Container(
      key: UniqueKey(),
      child: adWidget,
    );
    setState(() {
      bannerAdsLoading = BannerAdsLoading.success;
      _adWidget = wrappedAdWidget;
      _hasTriedLoadingAds = false;
    });
    EventRepo().addEvent({
      "adSource": source,
      "sdkRequestStartTime": requestInitiated.toString(),
      "sdkRequestReceivedTime": responseReceived.toString(),
      "adsRenderingTime": responseReceived!.difference(requestInitiated!).inMilliseconds.toString(),
      "createAt": DateTime.now().toString(),
      "adResponse": ad.responseInfo.toString(),
    }, "ads_success");
    _disposeOtherAds(except: ad);
  }

  void _checkIfAllAdsFailed(LoadAdError error) {
    _failCount++;
    if (_adDisplayed) return;
    if (_failCount >= 4) {
      setState(() {
        bannerAdsLoading = BannerAdsLoading.fail;
        _hasTriedLoadingAds = false;
      });
    }
    EventRepo().addEvent({
      "adSource": source,
      "sdkRequestStartTime": requestInitiated.toString(),
      "sdkRequestReceivedTime": responseReceived.toString(),
      "adsRenderingTime": "0",
      "createAt": DateTime.now().toString(),
      "adResponse": error.responseInfo.toString(),
    }, "ads_failure");
  }

  void _disposeOtherAds({required dynamic except}) {
    if (_adManagerNativeAd != null && _adManagerNativeAd != except) _adManagerNativeAd?.dispose();
    if (_adMobNativeAd != null && _adMobNativeAd != except) _adMobNativeAd?.dispose();
    if (_bannerAd != null && _bannerAd != except) _bannerAd?.dispose();
    if (_bannerAd1 != null && _bannerAd1 != except) _bannerAd1?.dispose();
  }

  void _logLatencyMetrics() {
    if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
      final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
      EventRepo().addEvent({
        "adSource": source,
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
      }, "ad_latency_metrics");
    }
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
    if (bannerAdsLoading == BannerAdsLoading.loading || _hasTriedLoadingAds) {
      return AdsLoadingScreen();
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: _adWidget != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      ShareYourApp(),
                      Container(
                        color: Platform.isIOS ? Colors.transparent : Colors.white,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: _bannerAd != null
                            ? Container(
                                color: Platform.isIOS ? Colors.transparent : Colors.white,
                                alignment: Alignment.center,
                                width: _bannerAd!.size.width.toDouble(),
                                height: _bannerAd!.size.height.toDouble(),
                                child: _adWidget)
                            : _bannerAd1 != null
                                ? Container(
                                    color: Platform.isIOS ? Colors.transparent : Colors.white,
                                    alignment: Alignment.center,
                                    width: _bannerAd!.size.width.toDouble(),
                                    height: _bannerAd!.size.height.toDouble(),
                                    child: _adWidget)
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: _adWidget,
                                  ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.article['adType'] == "rating card" ? RateYourApp() : ShareYourApp(),
                  ),
          ),
          height(height: 6),
          Expanded(flex: 1, child: _buildRecommendedNews(context)),
        ],
      ),
    );
  }

  Widget _buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        Text("Recommended News ", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
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
