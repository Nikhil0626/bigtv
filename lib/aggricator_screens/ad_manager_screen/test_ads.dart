import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
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

class FullScreenNativeAd extends StatefulWidget {
  final article;

  const FullScreenNativeAd({super.key, required this.article});

  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  NativeAd? _adManagerNativeAd;
  NativeAd? _adMobNativeAd;
  BannerAd? _bannerAd;

  bool _isBannerLoaded = false;
  bool _isAdMObLoaded = false;
  bool _isAdShown = false;
  bool _adLoadFailed = false;
  bool _hasTriedLoadingAds = false;

  dynamic _shownAd;
  Widget? _adWidget;

  String? to = '';
  String? from = '';
  BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;

  @override
  void initState() {
    super.initState();
    bannerAdsLoading = BannerAdsLoading.loading;
    _loadAllAds(context);
  }

  void _loadAllAds(BuildContext context) {
    _hasTriedLoadingAds = true;
    log("ads loading quick...");
    _loadAdManagerNativeAd(context);
    _loadAdMobNativeAd(context);
    _loadBannerAd(context);
  }

  void _loadAdManagerNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adManagerNativeId; // Replace with your logic


    from = DateTime.now().toString();

    _adManagerNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('AdManager Native failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadAdMobNativeAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adMobNativeId;


    _adMobNativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isAdMObLoaded = true;
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('AdMob Native failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadBannerAd(BuildContext context) {
    String? adUnitId = context.read<HomeProvider>().adManagerBannerId; // Replace with your logic

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize(width: 300, height: 250),
      request: AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          print('AdManager Native success: ${ad.responseInfo.toString()}');
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {

          ad.dispose();
          print('Banner failed: $error');
          _checkIfAllAdsFailed(error);
        },
      ),
    )..load();
  }

  void _onAdLoaded(dynamic ad, Widget adWidget) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? userId= sharedPreferences.getString("userId");
    String? deviceId= sharedPreferences.getString("deviceId");
    to = DateTime.now().toString();

    Map<String, dynamic> newEvent = {
      'key': 'ads_success',
      'metadata': {
        "sdkRequestStartTime":from,
        "sdkRequestReceivedTime":to,
        "adsRenderingTime":DateTime.now().difference(DateTime.parse(to!)).inMilliseconds,
        "createAt":DateTime.now(),
        "adResponse":ad.responseInfo.toString(),
      },
      'userId': userId,
      'deviceId': deviceId,
    };
    print("All Events: ${newEvent}");
    await EventRepo().addEvent(newEvent).then((value) {  final box = Hive.box('events');

      final allEvents = box.values.toList();
      print("All Events:");
      for (var e in allEvents) {
        log("$e");
      }// adds the event to the list
    },);

    if (_isAdShown) {
      ad.dispose();
      return;
    }

    setState(() {
      bannerAdsLoading = BannerAdsLoading.success;
      _isAdShown = true;
      _shownAd = ad;
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

    bool noAdUnits = (_adManagerNativeAd == null && _adMobNativeAd == null && _bannerAd == null);

    if (noAdUnits) {
      setState(() {
        _adLoadFailed = true;
      });
    }
  }

  void _checkIfAllAdsFailed(LoadAdError error)async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? userId= sharedPreferences.getString("userId");
    String? deviceId= sharedPreferences.getString("deviceId");
    Map<String, dynamic> newEvent = {
      'key': 'ads_fail',
      'metadata': {
        "sdkRequestStartTime":from,
        "sdkRequestReceivedTime":to,
        "adsRenderingTime":0,
        "createAt":DateTime.now(),
        "adResponse":error.responseInfo.toString(),
      },
      'userId': userId,
      'deviceId': deviceId,
    };
    print("All Events: ${newEvent}");
    await EventRepo().addEvent(newEvent);
    bannerAdsLoading = BannerAdsLoading.fail;

    setState(() {
      _adLoadFailed = true;
    });
  }

  @override
  void dispose() {
    _adManagerNativeAd?.dispose();
    _adMobNativeAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    if (_adWidget != null) {
      return Scaffold(
        body: _isAdMObLoaded
            ? _adWidget!
            : Column(
                children: [
                  Expanded(flex: 1, child: _adWidget!),
                  Expanded(flex: 1, child: _buildRecommendedNews(context)),
                ],
              ),
      );
    }

    if (_isBannerLoaded && _bannerAd != null) {
      return Scaffold(
        body: Column(
          children: [
            AdWidget(ad: _bannerAd!),
            Expanded(child: _buildRecommendedNews(context)),
          ],
        ),
      );
    }
    if (bannerAdsLoading == BannerAdsLoading.loading) {
      return AdsLoadingScreen();
    }
    return Scaffold();
  }

  Widget _buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        Text("Recommended News", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
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

class GAMBannerAdWidget extends StatefulWidget {
  const GAMBannerAdWidget({super.key});

  @override
  State<GAMBannerAdWidget> createState() => _GAMBannerAdWidgetState();
}

class _GAMBannerAdWidgetState extends State<GAMBannerAdWidget> {
  late AdManagerBannerAd _ad;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _ad = AdManagerBannerAd(
      adUnitId: '/6499/example/banner', // ✅ Replace with your GAM banner ad unit
      sizes: [AdSize.mediumRectangle],
      request: AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );

    _ad.load();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isAdLoaded
          ? Container(
              width: _ad.sizes[0].width.toDouble(),
              height: _ad.sizes[0].height.toDouble(),
              child: AdWidget(ad: _ad),
            )
          : const CircularProgressIndicator(),
    );
  }
}

class BannerAds extends StatefulWidget {
  final article;

  const BannerAds({super.key, required this.article});

  @override
  _BannerAdsState createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;

  @override
  void initState() {
    super.initState();
    loadBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can safely access context or ancestors here if needed.
  }

  @override
  void dispose() {
    // Ensure the banner ad is disposed only if it is loaded
    if (_isAdLoaded) {
      _bannerAd.dispose();
    }
    super.dispose();
  }

  void loadBannerAd() {
    bannerAdsLoading = BannerAdsLoading.loading;
    setState(() {});
    final AdSize customAdSize = AdSize(width: 300, height: 250);
    _bannerAd = BannerAd(
      adUnitId: context.read<HomeProvider>().adManagerBannerId, // Dummy test Ad Unit ID (valid test ID from Google)
      // adUnitId: '/21775744923/example/fixed-size-bannerpppp', // Dummy test Ad Unit ID (valid test ID from Google)
      size: customAdSize,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          bannerAdsLoading = BannerAdsLoading.success;
          _isAdLoaded = true;
        });
        print('Banner ad loaded.');
      }, onAdFailedToLoad: (ad, error) {
        bannerAdsLoading = BannerAdsLoading.fail;
        ad.dispose();
        setState(() {});
      }),
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: bannerAdsLoading == BannerAdsLoading.loading
            ? Center(
                child: BannerAdsLoadingScreen(),
              )
            : bannerAdsLoading == BannerAdsLoading.success
                ? AdWidget(ad: _bannerAd)
                : widget.article['adType'] == "rating card"
                    ? RateYourApp()
                    : widget.article['adType'] == "share card"
                        ? ShareYourApp()
                        : ShareYourApp(),
      ),
    );
  }
}
