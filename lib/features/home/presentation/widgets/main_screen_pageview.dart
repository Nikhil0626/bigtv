import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'main_screen_byts_view.dart';

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
                  padding: EdgeInsets.zero,
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
                              context.read<VideoProvider>().pauseVideo();
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }
                              _handlePageChanged(value);

                              final adKeys = context.read<AdMobBannerProvider>().ads.length;

                              context.read<AdMobBannerProvider>().changePageIndex(value);

                              log(" Last Index of ads data $adKeys ----- $value --- ${adKeys * 5} ---${context.read<AdMobBannerProvider>().ads}");

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
                              return MainScreenBytView(
                                article: homeProvider.getAllPostList[index],
                                pageController: homeProvider.pageController!,
                                length: homeProvider.getAllPostList.length,
                                index: index,
                                aiTagName: "",
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (context.watch<HomeProvider>().isAiTagDataLoaded && widget.isAiTags == false && homeProvider.getAllPostList.isNotEmpty)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 3),
                    inactiveTrackColor: Colors.grey.shade300,
                    activeTrackColor: AppColorTokens.primaryRed,
                    thumbColor: AppColorTokens.primaryRed,
                    disabledActiveTrackColor: AppColorTokens.primaryRed,
                    disabledInactiveTrackColor: Colors.grey.shade300,
                    disabledThumbColor: AppColorTokens.primaryRed,
                  ),
                  child: Slider(
                    value: homeProvider.pageController!.hasClients ? (homeProvider.pageController!.page ?? 0) : 0,
                    min: 0,
                    max: (homeProvider.getAllPostList.length -1).toDouble(),
                    onChanged: null, // read-only slider
                  ),
                ),
            ],
          );
        },
      ),
    );
  }


  int _getNewsIndex(int builderIndex) {
    const adEvery = 5;
    final adsBefore = builderIndex ~/ (adEvery + 1);
    final newsIndex = builderIndex - adsBefore;
    if (newsIndex >= homeProvider!.getAllPostList.length) {
      return homeProvider!.getAllPostList.length - 1;
    }
    return newsIndex;
  }

  void _handlePageChanged(int value) {
    final adMobProvider = context.read<AdMobBannerProvider>();
    log("Last Index of Sticky ads data ${adMobProvider.adsBanner320x50}");
  }
}





