import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../services/analytics_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';
import '../individual_post_details/individual_post_view.dart';


class FullScreenNativeAd extends StatefulWidget {
  final article;

  const FullScreenNativeAd({super.key,required this.article});
  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  NativeAd? _nativeAd;
   BannerAd? _bannerAd;
  bool _isNativeAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isAdMobNativeLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
    // loadAdMobNativeAd();
    // _loadBannerAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(

      adUnitId: '/21775744923/example/nativeee', // Test Ad Unit ID
      factoryId: 'adFactoryExample', // Your registered factory ID
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
            print('Native ad is loaded, ${ad.responseInfo.toString()}');
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load native ad: $error');
          _loadBannerAd();

        },
      ),
      request: AdRequest(),
    )..load();
  }
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: '/21775744923/example/fixed-size-banneree', // Dummy test Ad Unit ID (valid test ID from Google)
      size: AdSize(width: 300, height: 250),
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isBannerAdLoaded = true;
            });
            print('Banner ad loaded.');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            print('Failed to load native ad: $error');
            loadAdMobNativeAd();
          }
      ),
    )..load();
  }

  void loadAdMobNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-2405357352181832/9820571770', // Test Ad Unit ID
      factoryId: 'adFactoryExample', // Your registered factory ID
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdMobNativeLoading = true;
            print('Native ad is loaded, ${ad.responseInfo.toString()}');
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // _loadBannerAd();
          print('Failed to load native ad: $error');
        },
      ),
      request: AdRequest(),
    )..load();

    // _nativeAd = NativeAd(
    //   adUnitId: Platform.isIOS ? "ca-app-pub-2405357352181832/7643871122" : 'ca-app-pub-2405357352181832/9820571770', // Your Ad Unit ID
    //   request: const AdRequest(),
    //   listener: NativeAdListener(
    //     onAdLoaded: (ad) {
    //       if (mounted) {
    //         print('Ad failed to load: $ad');
    //         setState(() {
    //           _isAdMobNativeLoading = true;
    //         });
    //       }
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //       if (mounted) {
    //         setState(() {
    //           _isAdMobNativeLoading = false;
    //           _nativeAd = null;
    //          context.read<HomeProvider>().getSurveyData();
    //         });
    //       }
    //       print('Ad failed to load: $error');
    //     },
    //   ),
    //   nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
    // )
    //   ..load();
    // if (_nativeAd != null) {
    //   AnalyticsService.logEvent2("ads_available");
    // }
    // setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isNativeAdLoaded
          ? AdWidget(ad: _nativeAd!)
          :_isAdMobNativeLoading?AdWidget(ad: _nativeAd!)
          :_isBannerAdLoaded?Column(
            children: [
              Expanded(child: AdWidget(ad: _bannerAd!)),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    children: [
                      Text(
                        "Recommended News",
                        maxLines: 1,
                        style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor),
                      ),
                      // height(height: 10),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: ListView.builder(
                            itemCount: 3,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IndividualPostView1(postId: widget.article["isHomeScreen"]![index]['id'].toString(),isComeFrom: true,),
                                      ));
                                },
                                child: Center(
                                  child: Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.wColor,
                                      border: Border.all(width: 2, color: AppColors.wColor),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.article["isHomeScreen"]![index]['image_url'].toString(),
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.borderColor.withOpacity(.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 30,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        width(width: 10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${widget.article["isHomeScreen"][index]["title"]}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: fontStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              height(height: 2),
                                              Row(
                                                children: [
                                                  index==0?SvgPicture.asset("assets/svg/like.svg",height: 16,width: 16,): index==2?SvgPicture.asset("assets/svg/share.svg",height: 16,width: 16,):SvgPicture.asset("assets/svg/eye.svg",height: 16,width: 16,),
                                                  width(width: 6),
                                                  Text(
                                                    index ==0?"టాప్ లైక్స్":index == 2?"టాప్ షేర్‌డ్": "టాప్ వ్యూడ్",
                                                    style: fontStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
          : Center(
        child: CircularProgressIndicator(),
      ),
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


class banner extends StatefulWidget {
  @override
  _bannerState createState() => _bannerState();
}

class _bannerState extends State<banner> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
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
    final AdSize customAdSize = AdSize(width: 300, height: 250);
    _bannerAd = BannerAd(
      adUnitId: '/21775744923/example/fixed-size-banner', // Dummy test Ad Unit ID (valid test ID from Google)
      size: customAdSize,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Banner ad loaded.');
        },
          onAdFailedToLoad: (ad, error) {
            print('Failed to load banner ad: $error');
            print('Response info: ${ad.adUnitId}');
            ad.dispose();
          }
      ),
    );
    _bannerAd.load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isAdLoaded? // Only display the ad when it is loaded
          AdWidget(ad: _bannerAd):SizedBox(),
      ),
    );
  }
}


