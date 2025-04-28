import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/home_screen/home_screens/standard_post_view.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../aggricator_screens/settings_screen/settings_view/feedback_view.dart';
import '../../../utils/app_colors.dart';

class GoogleAdsView extends StatefulWidget {
  final article;
  final HomeProvider flipProvider;
  final isFoldable;
  bool isList;

  GoogleAdsView({
    super.key,
    required this.article,
    required this.flipProvider,
    required this.isFoldable,
    this.isList = false,
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
    loadAd();
  }

  void loadAd() {
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
              context.read<HomeProvider>().getSurveyData();
            });
          }
          print('Ad failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
    )
      ..load();
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
          child: !_isAdLoaded || _nativeAd == null
              ?widget.article['adType']=="rating card"?RateYourApp():widget.article['adType']=="share card"?ShareYourApp():ShareYourApp()
              : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: AdWidget(ad: _nativeAd!),
          ),
        ),
        if (widget.isList)
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
                                    builder: (context) => IndividualPostView1(postId: widget.article["homepage"]![index]['id'].toString(),isComeFrom: true,),
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
                                        imageUrl: widget.article["homepage"]![index]['image_url'].toString(),
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
                                            "${widget.article["homepage"][index]["title"]}",
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
    );
  }

  @override
  void dispose() {
    log("hello siva ads close");
    _nativeAd?.dispose();
    super.dispose();
  }
}


class RateYourApp extends StatelessWidget {
  const RateYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rate your experience\nwith chota news?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            height(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) =>
                    Icon(
                      Icons.star,
                      color: AppColors.ratingColor,
                      size: 40,
                    ),
              ),
            ),
            height(height: 4.h),
            Text(
              'Awesome, liked it',
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            height(height: 6.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}


class SurveyCards extends StatefulWidget {
  const SurveyCards({super.key});

  @override
  State<SurveyCards> createState() => _SurveyCardsState();
}

class _SurveyCardsState extends State<SurveyCards> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return Container(
          height: 330.h,
          child: Column(
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
              Expanded(

                  child: ListView.builder(
                    itemCount: homeProvider.getAllSurveyDataList.length,
                    itemBuilder: (context, index) {
                return Container(height: 30,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(width: 1, color: AppColors.borderColor)),
                    child: Text(
                        'Are liking our app?',
                        textAlign: TextAlign.center,
                        style: newAppFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        )));
              },))
            ],
          ),
        );
      }
    );
  }
}


class ShareYourApp extends StatelessWidget {
  const ShareYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Are you liking our app?',
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
                  onPressed: () {
                    Share.share("Check out this app: https://play.google.com/store/apps/details?id=com.chotanews");
                  },
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
      ),
    );
  }
}
