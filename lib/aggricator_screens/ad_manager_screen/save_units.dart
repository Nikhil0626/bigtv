import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loading_screen/ads_loading_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider/home_provider.dart';
import '../individual_post_details/individual_post_view.dart';
import 'google_ads_view.dart';

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

  bool _isBannerLoaded = false;
  bool _isAdMObLoaded = false;
  bool _isAdShown = false;
  bool _adLoadFailed = false;
  bool _hasTriedLoadingAds = false;

  String? source = '';

  BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;

  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
  Widget? _adWidget;

  String? to = '';
  String? from = '';

  @override
  void initState() {
    super.initState();
    source="";
    bannerAdsLoading = BannerAdsLoading.loading;
    _loadAllAds(context);
  }

  void _loadAllAds(BuildContext context) {
    _hasTriedLoadingAds = true;
    log("ads loading quick...");
    _loadAdManagerNativeAd(context);
    _loadAdMobNativeAd(context);
    _loadBannerAd(context);
    _loadBannerAdMob(context);
    _loadBannerAdMob1(context);
  }

  void _loadAdManagerNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adManagerNativeId; // Replace with your logic


    from = DateTime.now().toString();

    _adManagerNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
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
        onAdLoaded: (ad) {
          source = "Adm_Native";
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          source = "Adm_Native_fail";
          print('AdManager Native failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadAdMobNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adMobNativeId;
    // String? adUnitId = "	ca-app-pub-3940256099942544/2247696110";


    _adMobNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
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
        onAdLoaded: (ad) {
          _isAdMObLoaded = true;
          source = "Am_Native";
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          source = "Am_Native_fail";
          print('AdMob Native failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadBannerAd(BuildContext context) async{
    String? adUnitId = context.read<HomeProvider>().adManagerBannerId; // Replace with your logic
    // String? adUnitId = "/21775744923/example/adaptive-banner"; // Replace with your logic

    _bannerAd = AdManagerBannerAd(
      adUnitId: adUnitId,
      request: const AdManagerAdRequest(),
      sizes: <AdSize>[AdSize.mediumRectangle,AdSize.fluid,AdSize.largeBanner],
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          source = "Adm_banner";
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {

          ad.dispose();
          source = "Adm_banner_fail";
          print('Banner failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
    )..load();
  }

  void _onAdLoaded(dynamic ad, Widget adWidget) async {
    to = DateTime.now().toString();


    if (_isAdShown) {
      ad.dispose();
      return;
    }

    setState(() {
      bannerAdsLoading = BannerAdsLoading.success;
      _isAdShown = true;
      // _shownAd = ad;
      _adWidget = adWidget;
      _adLoadFailed = false;
    });

    // Dispose other ads
    if (ad != _adManagerNativeAd) {
      _adManagerNativeAd?.dispose();
      _adManagerNativeAd = null;
    }
    if (ad != _adMobNativeAd) {
      _adMobNativeAd?.dispose();
      _adMobNativeAd = null;
    }
    if (ad != _bannerAd) {
      _bannerAd?.dispose();
      _bannerAd = null;
    }
 if (ad != _bannerAd1) {
      _bannerAd1?.dispose();
      _bannerAd1 = null;
    }

    bool noAdUnits = (_adManagerNativeAd == null && _adMobNativeAd == null && _bannerAd == null&& _bannerAd1 == null);

    if (noAdUnits) {
      setState(() {
        _adLoadFailed = true;
      });
    }


    EventRepo().addEvent({
      "adSource": source,
      "sdkRequestStartTime": requestInitiated.toString(),
      "sdkRequestReceivedTime": responseReceived.toString(),
      "adsRenderingTime": responseReceived!.difference(requestInitiated!).inMilliseconds.toString(),
      "createAt": DateTime.now().toString(),
      "adResponse": ad.responseInfo.toString(),
    }, "ads_success");
  }
  void _loadBannerAdMob(BuildContext context) {
    final adUnitId = context.read<HomeProvider>().adMobBannerId;
    // final adUnitId ="ca-app-pub-3940256099942544/6300978111";
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
          source = "Adm_banner";
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
  void _loadBannerAdMob1(BuildContext context) {
    final adUnitId = context.read<HomeProvider>().adMobBannerId;
    // final adUnitId ="ca-app-pub-3940256099942544/6300978111";
    requestInitiated = DateTime.now();
    _bannerAd1 = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          source = "Am_Banner_small";
          responseReceived = DateTime.now();
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          source = "Adm_banner";
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

  void _checkIfAllAdsFailed(LoadAdError error)async {

    bannerAdsLoading = BannerAdsLoading.fail;

    setState(() {
      _adLoadFailed = true;
    });
    EventRepo().addEvent({
      "adSource": source,
      "sdkRequestStartTime": requestInitiated.toString(),
      "sdkRequestReceivedTime": responseReceived.toString(),
      "adsRenderingTime": "0",
      "createAt": DateTime.now().toString(),
      "adResponse": error.responseInfo.toString(),
    }, "ads_failure");
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


    if (_adWidget != null) {
      return Scaffold(
        body: _isAdMObLoaded
            ? _adWidget!
            : Column(
          children: [
            Expanded(flex:1,child: Center(child: Container(color:Colors.teal.shade200,height: 250,width: 300, child: _adWidget!))),
            Expanded(flex:1, child: _buildRecommendedNews(context)),
          ],
        ),
      );
    }

    if (_isBannerLoaded && _bannerAd != null) {
      return Scaffold(
        body: Column(
          children: [
            SizedBox(height: 300,width: 250,child: AdWidget(ad: _bannerAd!,)),
            Expanded(child: _buildRecommendedNews(context)),
          ],
        ),
      );
    } if (_isBannerLoaded && _bannerAd1 != null) {
      return Scaffold(
        body: Column(
          children: [
            SizedBox(height: 300,width: 250,child: AdWidget(ad: _bannerAd1!)),
            Expanded(child: _buildRecommendedNews(context)),
          ],
        ),
      );
    }
    if (bannerAdsLoading == BannerAdsLoading.loading ) {
      return AdsLoadingScreen();
    }

    if (_adLoadFailed && bannerAdsLoading == BannerAdsLoading.fail) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: widget.article['adType'] == "rating card"
                    ? RateYourApp()
                    : widget.article['adType'] == "share card"
                    ? ShareYourApp()
                    : ShareYourApp(),
              ),
              Expanded(flex: 1, child: _buildRecommendedNews(context)),
            ],
          ),
        ),
      );
    }
    return Scaffold();
  }

  Widget _buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        Text("Recommended News ", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
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




