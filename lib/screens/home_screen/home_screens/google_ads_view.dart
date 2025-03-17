import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/home_screen/home_screens/standard_post_view.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:screenshot/screenshot.dart';

import '../../../utils/app_colors.dart';

class GoogleAdsView extends StatefulWidget {
  final HomeScreenModel article;
  final ScreenshotController screenshotController;
  final FlipProvider flipProvider;
  final isFoldable;
  const GoogleAdsView( {super.key,required this.article,required this.screenshotController,required this.flipProvider, required this.isFoldable});

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
      adUnitId: 'ca-app-pub-2405357352181832/9820571770', // Your Ad Unit ID
      // factoryId: 'listTile',
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
      nativeTemplateStyle:
      NativeTemplateStyle(templateType: TemplateType.medium),
    )..load();
    if(_nativeAd != null){
      AnalyticsService.logEvent2("ads_available", );
    }
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child:!_isAdLoaded || _nativeAd == null?ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adjust radius as needed
                child:Image.asset("assets/playstore.png")): AdWidget(ad: _nativeAd!),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Text("Recommended New`s",
                  maxLines: 2
                  ,style: fontStyle(fontSize: 14,fontWeight: FontWeight.w700,color: AppColors.borderColor),),
                height(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.article.homepage!.length,
                    itemBuilder:(context, index) {
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  StandardPostView(article: widget.article.homepage![index], screenshotController:widget.screenshotController,
                            flipProvider: widget.flipProvider,
                            isFoldable: widget.isFoldable,
                            isAds: true,
                          ),));
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 15),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 2,color: AppColors.borderColor),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8), // Adjust radius as needed
                                    child: CachedNetworkImage(
                                      imageUrl: widget.article.homepage![index].imageUrl!.url,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderColor.withOpacity(.2),
                                          borderRadius: BorderRadius.circular(8), // Same radius here
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8), // Ensure consistency
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
                                  )
                                  ,
                                  width(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${widget.article.homepage![index].title}",
                                          maxLines: 2
                                          ,style: fontStyle(fontSize: 14,fontWeight: FontWeight.w700,color: AppColors.borderColor),),
                                        Row(
                                          children: [
                                            Icon(Icons.shortcut_sharp,color: Colors.greenAccent,),
                                            width(width: 6),
                                            Text("టాప్ స్టోరీస్",style: fontStyle(fontSize: 12,fontWeight: FontWeight.w400,color: AppColors.borderColor),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )

                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } ,),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    log("hello siva ads close");
    _nativeAd?.dispose(); // Null check before disposing
    super.dispose();
  }
}