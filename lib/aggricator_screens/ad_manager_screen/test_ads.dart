
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../individual_post_details/individual_post_view.dart';
import 'google_ads_view.dart';


class FullScreenNativeAd extends StatefulWidget {
  final article;

  const FullScreenNativeAd({super.key,required this.article});
  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  NativeAd? _adManagerNativeAd;
  NativeAd? _adMobNativeAd;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  bool _isAdShown = false;
  dynamic _shownAd; // Can be NativeAd or BannerAd
  Widget? _adWidget;

  @override
  void initState() {
    super.initState();
    _loadAllAds(context);
  }

  void _loadAllAds(BuildContext context) {

    print("bhduighderkifherifhiraeugfhrieuhgui");
    _loadAdManagerNativeAd(context);
    // _loadAdMobNativeAd(context);
    _loadBannerAd(context);
  }

  void _loadAdManagerNativeAd(BuildContext context) async{
    SharedPreferences sp =await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    _adManagerNativeAd = NativeAd(
      adUnitId: context.read<HomeProvider>().adManagerNativeId,
      // adUnitId: context.read<HomeProvider>().adManagerNativeId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {

          EventRepo().sendEvent({
            "key": "ads_available",
            "data": {
              "user_id":userId,
              "nameOfAdsType":"AdManagerNativeAd",
              "error":error.toString(),
              "adUnitId":ad.adUnitId.toString(),
              "ad":ad.responseInfo.toString()
            }
          });

          ad.dispose();
          print('AdManager Native failed: $error');
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadAdMobNativeAd(BuildContext context) async{
    SharedPreferences sp =await SharedPreferences.getInstance();

    String? userId = sp.getString("userId");
    _adMobNativeAd = NativeAd(
      adUnitId: context.read<HomeProvider>().adMobNativeId,
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _onAdLoaded(ad, AdWidget(ad: ad as NativeAd));
        },
        onAdFailedToLoad: (ad, error) {

          EventRepo().sendEvent({
            "key": "ads_available",
            "data": {
              "user_id":userId,
              "nameOfAdsType":"AdMobNativeAd",
              "error":error.toString(),
              "adUnitId":ad.adUnitId.toString(),
              "ad":ad.responseInfo.toString()
            }
          });
          ad.dispose();
          print('AdMob Native failed: $error');
        },
      ),
      request: AdRequest(),
    )..load();
  }

  void _loadBannerAd(BuildContext context) async{
    SharedPreferences sp =await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    _bannerAd = BannerAd(
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      size: AdSize(width: 300, height: 250),
      request: AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          _onAdLoaded(ad, AdWidget(ad: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          EventRepo().sendEvent({
            "key": "ads_available",
            "data": {
              "user_id":userId,
              "nameOfAdsType":"AdManagerBannerAd",
              "error":error.toString(),
              "adUnitId":ad.adUnitId.toString(),
              "ad":ad.responseInfo.toString()
            }
          });
          ad.dispose();
          print('Banner failed: $error');
        },
      ),
    )..load();
  }

  void _onAdLoaded(dynamic ad, Widget adWidget) {
    if (_isAdShown) {
      ad.dispose(); // Don't need it
      return;
    }

    setState(() {
      _isAdShown = true;
      _shownAd = ad;
      _adWidget = adWidget;
    });

    // Dispose all other ads
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
    if (_adWidget != null) {
      return Scaffold(body: Column(
        children: [
          Text("Native Ads"),
          _adWidget!,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildRecommendedNews(context),
            ),
          ),
        ],
      ));
    }

    if (_isBannerLoaded && _bannerAd != null) {
      return Scaffold(
        body: Column(
          children: [
            Text("Banner Ads"),
            AdWidget(ad: _bannerAd!),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildRecommendedNews(context),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(children: [
        Text("No Ads"),
        Expanded(
          flex: 1,
          child:widget.article['adType']=="rating card"?RateYourApp():widget.article['adType']=="share card"?ShareYourApp():ShareYourApp(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildRecommendedNews(context),
          ),
        ),
      ],)
    );
  }
  Widget _buildRecommendedNews(BuildContext context) {
    return Column(
      children: [
        Text(
          "Recommended News",
          style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor),
        ),
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
                                  index == 0 ? "టాప్ లైక్స్" : index == 2 ? "టాప్ షేర్‌డ్" : "టాప్ వ్యూడ్",
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
      adUnitId:  context.read<HomeProvider>().adManagerBannerId, // Dummy test Ad Unit ID (valid test ID from Google)
      // adUnitId: '/21775744923/example/fixed-size-banner', // Dummy test Ad Unit ID (valid test ID from Google)
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


