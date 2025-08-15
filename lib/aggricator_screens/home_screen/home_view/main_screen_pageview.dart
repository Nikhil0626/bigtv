import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_native_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../services/analytics_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_no_data.dart';
import '../../../utils/app_spaces.dart';
import '../../ad_manager_screen/ad_provider/ad_manager_banner_provider.dart';
import '../../ad_manager_screen/ad_provider/ad_manager_native_provider.dart';
import '../../ad_manager_screen/ad_provider/banner_ads_provider.dart';
import '../../ad_manager_screen/ad_screen/google_ads_view.dart';
import '../../individual_post_details/individual_post_view.dart';
import '../home_provider/home_provider.dart';
import 'main_screen_byts_view.dart';

///This widgets help in stopping the build
class MainScreenPageView extends StatefulWidget {
  final int startIndex;
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const MainScreenPageView({super.key, this.startIndex = 0, this.isAiTags = false, this.tagName = "", this.tagId = ""});

  @override
  _MainScreenPageViewState createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {
  DateTime? _pageStartTime;

  int autoIndex = 0;
  final Gradient rainbowGradient = LinearGradient(
    colors: [
      Colors.blue,
      Colors.teal,
      Colors.red,
    ],
  );
  HomeProvider? homeProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    autoIndex = 0;
    super.initState();
    homeProvider?.pageController?.addListener(homeProvider!.scrollListener);
    _pageStartTime = DateTime.now();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer5<HomeProvider, AdMobBannerProvider, AdManagerBannerProvider, AdMobNativeProvider, AdManagerNativeProvider>(
        builder: (_, homeProvider, adMobBannerProvider, adManagerBannerProvider, adMobNativeProvider, adManagerNativeProvider, __) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: context.read<HomeProvider>().getAllPostList.isEmpty
                        ? Center(
                            child: AppNoData(),
                          )
                        : PageView.builder(
                            physics: const ClampingScrollPhysics(parent: BouncingScrollPhysics()),
                            controller: homeProvider.pageController!,
                            scrollDirection: Axis.vertical,
                            itemCount: homeProvider.getAllPostList.length,
                            onPageChanged: (value) {
                              BannerAdsProvider().disposeAllAds();
                              log("IndividualPostView  $autoIndex--- $value");
                              if (homeProvider.isBottomEnable) {
                                homeProvider.pageChange(isValue: false);
                              }

                                if ((value + 3) % 5 == 0) {
                                  final position = value + 3; // Convert to 1-based index

                                  if (position % 20 == 5) {
                                    /// Ad Mob Banner
                                  adMobBannerProvider.loadAd(value, AdSize.mediumRectangle);
                                  } else if (position % 20 == 10) {
                                    /// Ad Manager Banner
                                    adManagerBannerProvider.loadAd(value, AdSize.mediumRectangle);
                                  } else if (position % 20 == 15) {
                                    /// Ad Manager Native
                                    adManagerBannerProvider.loadAd(value, AdSize.mediumRectangle);
                                  } else if (position % 20 == 0) {
                                    /// Ad Mob Native
                                    adManagerBannerProvider.loadAd(value, AdSize.mediumRectangle);
                                  }
                                }
                              if (homeProvider.getAllPostList.length == value + 1 && homeProvider.isAiTagDataLoaded) {
                                Future.delayed(
                                  Duration(milliseconds: 2000),
                                  () {
                                    log("IndividualPostView dddd $autoIndex--- $value ==== ");
                                    homeProvider.aiTagDataLoaded(false);
                                    homeProvider.setSelectedTagId(0);
                                    homeProvider.getAllPost(postIds: "0");
                                  },
                                );
                              }

                              context.read<HomeProvider>().flipEvent('news', homeProvider.getAllPostList[value]['id'], value > autoIndex ? true : false);
                              autoIndex = value;

                              final now = DateTime.now();
                              final duration = now.difference(_pageStartTime ?? now);

                              AnalyticsService().trackArticleReadingTime(duration, homeProvider.getAllPostList[value]['id']);

                              setState(() {
                                _pageStartTime = now;
                              });
                            },
                            itemBuilder: (context, index) {
                              if ((index + 1) % 5 == 0) {
                                final position = index + 1; // Convert to 1-based index

                                if (position % 20 == 5) {
                                  if (adMobBannerProvider.adsLoaded[index] == true) {
                                    final ad = adMobBannerProvider.ads[index];
                                    if (ad != null) {
                                      return Container(
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                              child: SizedBox(
                                                height: 250,
                                                width: 300,
                                                child: AdWidget(ad: ad),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: ShareYourApp(),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                    ],
                                  );
                                }
                                else if (position % 20 == 10) {
                                  if (adManagerBannerProvider.adsLoaded[index] == true) {
                                    final ad = adManagerBannerProvider.ads[index];
                                    if (ad != null) {
                                      return Container(
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                              child: SizedBox(
                                                height: 250,
                                                width: 300,
                                                child: AdWidget(ad: ad),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: RateYourApp(),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                    ],
                                  );
                                }
                                else if (position % 20 == 15) {
                                  if (adMobNativeProvider.adsLoaded[index] == true) {
                                    final ad = adMobNativeProvider.nativeAds[index];
                                    if (ad != null) {
                                      return AdWidget(ad: ad);
                                    }
                                  }
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: ShareYourApp(),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                    ],
                                  );
                                }
                                else if (position % 20 == 0) {
                                  if (adManagerNativeProvider.adsLoaded[index] == true) {
                                    final ad = adManagerNativeProvider.ads[index];
                                    if (ad != null) {
                                      return AdWidget(ad: ad);
                                    }
                                  }
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: RateYourApp(),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: buildRecommendedNews(context, homeProvider)),
                                    ],
                                  );
                                }
                              }

                              return Container(
                                color: Colors.white,
                                child: MainScreenBytView(
                                  article: homeProvider.getAllPostList[index],
                                  pageController: homeProvider.pageController!,
                                  length: homeProvider.getAllPostList.length,
                                  index: index,
                                  aiTagName: "",
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (context.watch<HomeProvider>().isAiTagDataLoaded && widget.isAiTags == false)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 3),
                    inactiveTrackColor: Colors.transparent,
                    activeTrackColor: Colors.white,
                    thumbColor: Colors.white,
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return rainbowGradient.createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Slider(
                      value: homeProvider.pageController!.hasClients ? (homeProvider.pageController!.page ?? 0) : 0,
                      min: 0,
                      max: (homeProvider.getAllPostList.length - 1).toDouble(),
                      onChanged: null, // read-only slider
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildRecommendedNews(BuildContext context, HomeProvider homeProvider) {
    log("nikhil ${homeProvider.getRecommendedPostList.length}");
    return Column(
      children: [
        InkWell(
        //     // onTap: () {
        //     //   Navigator.push(
        //     //       context,
        //     //       MaterialPageRoute(
        //     //         builder: (context) => AdsTestData(),
        //     //       ));
        //     // },
            child: Text("Recommended News", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor))),
        height(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: homeProvider.getRecommendedPostList.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final post = homeProvider.getRecommendedPostList[index];
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
