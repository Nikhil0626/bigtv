import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/analytics_service.dart';
import '../../ad_manager_screen/ad_provider/banner_ads_provider.dart';
import '../home_provider/home_provider.dart';
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
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: PageView.builder(
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
}
