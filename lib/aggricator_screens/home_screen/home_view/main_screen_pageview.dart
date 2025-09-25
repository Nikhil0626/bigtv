import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../services/analytics_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_no_data.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/keep_alive_page.dart';
import '../../ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
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
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
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
                            // add ads count
                            onPageChanged: (value) {
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }
                              _handlePageChanged(value);

                              final adKeys = context.read<AdMobBannerProvider>().ads.length;

                              context.read<AdMobBannerProvider>().changePageIndex(value);

                              log(" Last Index of ads data $adKeys ----- $value --- ${adKeys * 5} ---${context.read<AdMobBannerProvider>().ads}");

                              if (value == (adKeys * 5)) {
                                int? lastKey = context.read<AdMobBannerProvider>().ads.keys.isNotEmpty ? context.read<AdMobBannerProvider>().ads.keys.last : adKeys;

                                context.read<AdMobBannerProvider>().loadAdMobBanner(lastKey + 1, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdManagerBanner(lastKey + 2, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdMobNative(lastKey + 3, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdManagerNative(lastKey + 4, AdSize.mediumRectangle);
                              } else if (value == 3 && context.read<AdMobBannerProvider>().ads.isEmpty) {
                                int? lastKey = 0;
                                context.read<AdMobBannerProvider>().loadAdMobBanner(lastKey + 1, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdManagerBanner(lastKey + 2, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdMobNative(lastKey + 3, AdSize.mediumRectangle);
                                context.read<AdMobBannerProvider>().loadAdManagerNative(lastKey + 4, AdSize.mediumRectangle);
                              }

                              // your other logic (pageChange, flipEvent, reading time etc.)
                              if (homeProvider.isBottomEnable) {
                                homeProvider.pageChange(isValue: false);
                              }
                              if (homeProvider.getAllPostList.length == value + 1 && homeProvider.isAiTagDataLoaded) {
                                Future.delayed(const Duration(milliseconds: 2000), () {
                                  homeProvider.aiTagDataLoaded(false);
                                  homeProvider.setSelectedTagId(0);
                                  homeProvider.getAllPost(postIds: "0");
                                });
                              }

                              context.read<HomeProvider>().flipEvent(
                                    'news',
                                    homeProvider.getAllPostList[_getNewsIndex(value)]['id'],
                                    value > autoIndex ? true : false,
                                  );
                              autoIndex = value;

                              final now = DateTime.now();
                              final duration = now.difference(_pageStartTime ?? now);
                              AnalyticsService().trackArticleReadingTime(duration, homeProvider.getAllPostList[_getNewsIndex(value)]['id']);

                              setState(() {
                                _pageStartTime = now;
                              });
                            },
                            itemBuilder: (context, index) {
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

  Widget _buildArticle(int index, HomeProvider homeProvider) {
    final newsIndex = _getNewsIndex(index); // adjust for ads
    return Container(
      color: Colors.white,
      child: MainScreenBytView(
        article: homeProvider.getAllPostList[newsIndex],
        pageController: homeProvider.pageController!,
        length: homeProvider.getAllPostList.length,
        index: newsIndex,
        aiTagName: "",
      ),
    );
  }

// int _getNewsIndex(int builderIndex) {
//   const adEvery = 5;
//   final adsBefore = builderIndex ~/ (adEvery + 1);
//   return builderIndex - adsBefore;
// }
  int _getNewsIndex(int builderIndex) {
    const adEvery = 5;
    final adsBefore = builderIndex ~/ (adEvery + 1);
    final newsIndex = builderIndex - adsBefore;

    // ✅ Prevent out of range
    if (newsIndex >= homeProvider!.getAllPostList.length) {
      return homeProvider!.getAllPostList.length - 1;
    }
    return newsIndex;
  }

  Widget buildRecommendedNews(BuildContext context, HomeProvider homeProvider) {
    return Column(
      children: [
        Text("Recommended News", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
        height(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: homeProvider.getRecommendedPostList.length > 3 ? 3 : homeProvider.getRecommendedPostList.length,
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

  void _handlePageChanged(int value) {

    final adMobProvider = context.read<AdMobBannerProvider>();
    final adStickyKeys = adMobProvider.adsBanner320x50.length;

    adMobProvider.changePageIndex(value);

    log("Last Index of Sticky ads data $adStickyKeys ----- $value --- ${adStickyKeys * 4} --- ${adMobProvider.adsBanner320x50}");

    if (value == (adStickyKeys * 3)) {
      int? lastStickyKey = adMobProvider.adsBanner320x50.keys.isNotEmpty
          ? adMobProvider.adsBanner320x50.keys.last
          : adStickyKeys;

      adMobProvider.loadAd320x50ManagerBanner(lastStickyKey + 1, AdSize.banner);
      adMobProvider.loadAd320x50ManagerBanner(lastStickyKey + 2, AdSize.banner);
    }

    else if (value == 1 && adMobProvider.adsBanner320x50.isNotEmpty) {
      int? lastStickyKey = 0;
      adMobProvider.loadAd320x50ManagerBanner(lastStickyKey + 1, AdSize.banner);
      adMobProvider.loadAd320x50ManagerBanner(lastStickyKey + 2, AdSize.banner);

    }
  }
}





