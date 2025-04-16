import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../utils/app_colors.dart';
class GoogleAdsView extends StatefulWidget {
  final article;
  final HomeProvider flipProvider;
  final isFoldable;

  const GoogleAdsView({
    super.key,
    required this.article,
    required this.flipProvider,
    required this.isFoldable,
  });
  @override
  State<GoogleAdsView> createState() => _GoogleAdsViewState();
}
class _GoogleAdsViewState extends State<GoogleAdsView> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }
  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: Platform.isIOS ? "ca-app-pub-2405357352181832/7643871122" : 'ca-app-pub-2405357352181832/9820571770', // Your Ad Unit ID
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _nativeAd = null;
            });
          }
          print('Ad failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
    )..load();
    if (_nativeAd != null) {
      AnalyticsService.logEvent2("ads_available");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: !_isAdLoaded || _nativeAd == null
                ? ClipRRect(
                    child: Card(
                      color: AppColors.adsBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: 300.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'Are liking our app?',
                                textAlign: TextAlign.center,
                                style: newAppFont(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            height(height: 4.h),
                            Text(
                              "Share the ChotaNewsApp_\nStay updated,with your \n friends & family!",
                              style: newAppFont(fontSize: 16, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            height(height: 12.h),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Share App'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : AdWidget(ad: _nativeAd!),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Text(
                  "Recommended News",
                  maxLines: 2,
                  style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor),
                ),
                height(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.article['homepage'].length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => StandardPostView(
                          //         article: widget.article.homepage![index],
                          //         screenshotController:
                          //             widget.screenshotController,
                          //         flipProvider: widget.flipProvider,
                          //         isFoldable: widget.isFoldable,
                          //         isAds: true,
                          //       ),
                          //     ));
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
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
                                      imageUrl: widget.article["homepage"]![index]['image_url'].toString(),
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
                                        height: 50,
                                        width: 50,
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
                                          "${widget.article["homepage"][index]["title"]}",
                                          maxLines: 2,
                                          style: fontStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.shortcut_sharp,
                                              color: Colors.greenAccent,
                                            ),
                                            width(width: 6),
                                            Text(
                                              "టాప్ స్టోరీస్",
                                              style: fontStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.borderColor,
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    log("hello siva ads close");
    _nativeAd?.dispose();
    super.dispose();
  }
}
