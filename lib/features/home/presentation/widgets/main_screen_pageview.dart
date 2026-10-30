import 'dart:async';
import 'dart:ui';

import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/analytics_service.dart' as legacy_analytics;
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'main_screen_byts_view.dart';
import 'tag_video_grid_view_widget.dart';

import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/services/translation_service.dart';

class MainScreenPageView extends StatefulWidget {
  final int startIndex;
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const MainScreenPageView({super.key, this.startIndex = 0, this.isAiTags = false, this.tagName = "", this.tagId = ""});

  @override
  State<MainScreenPageView> createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {
  DateTime? _pageStartTime;
  int _lastTrackedIndex = -1;
  Timer? _progressTimer25;
  Timer? _progressTimer50;
  Timer? _progressTimer75;

  void _scheduleProgressTrackers(dynamic articleId) {
    _progressTimer25?.cancel();
    _progressTimer50?.cancel();
    _progressTimer75?.cancel();

    _progressTimer25 = Timer(const Duration(seconds: 4), () {
      AnalyticsService.instance.track(AnalyticsEventName.articleReadProgress, properties: {
        'article_id': articleId,
        'progress_percent': 25,
      });
    });
    _progressTimer50 = Timer(const Duration(seconds: 8), () {
      AnalyticsService.instance.track(AnalyticsEventName.articleReadProgress, properties: {
        'article_id': articleId,
        'progress_percent': 50,
      });
    });
    _progressTimer75 = Timer(const Duration(seconds: 15), () {
      AnalyticsService.instance.track(AnalyticsEventName.articleReadProgress, properties: {
        'article_id': articleId,
        'progress_percent': 75,
      });
    });
  }

  void _cancelProgressTrackers() {
    _progressTimer25?.cancel();
    _progressTimer50?.cancel();
    _progressTimer75?.cancel();
  }

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
    homeProvider?.setCurrentPageIndex(widget.startIndex);
    homeProvider?.pageController?.addListener(homeProvider!.scrollListener);
    homeProvider?.pageController?.addListener(() {
      final page = homeProvider?.pageController?.page;
      if (page != null) {
        final roundPage = page.round();
        if (roundPage != homeProvider?.currentPageIndex) {
          homeProvider?.setCurrentPageIndex(roundPage);
        }
      }
    });
    _pageStartTime = DateTime.now();
    _lastTrackedIndex = widget.startIndex;
    if (homeProvider?.isEnglishMode == true) {
      TranslationService().preloadArticles(homeProvider?.getAllPostList ?? [], widget.startIndex, ahead: 5);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (homeProvider?.getAllPostList.isNotEmpty ?? false)) {
        final list = homeProvider!.getAllPostList;
        final idx = widget.startIndex < list.length ? widget.startIndex : 0;
        final article = list[idx];
        AnalyticsService.instance.track(AnalyticsEventName.articleOpen, properties: {
          'article_id': article['id'],
          'article_category': article['category_name'] ?? article['category'] ?? '',
          'language': article['language'] ?? 'te',
          'source_screen': 'home',
          'position': idx,
        });
        AnalyticsService.instance.track(AnalyticsEventName.articleReadStart, properties: {
          'article_id': article['id'],
        });
        if (article['isReporter'] == 1) {
          AnalyticsService.instance.track(AnalyticsEventName.reporterContentOpen, properties: {
            'reporter_id': article['reportedBy'] ?? article['reporterId'] ?? article['author'] ?? 'unknown',
            'content_id': article['id'],
            'content_type': 'article',
          });
        }
        _scheduleProgressTrackers(article['id']);
      }
    });
  }

  @override
  void dispose() {
    _cancelProgressTrackers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.isAiTagDataLoaded && homeProvider.liveTvVideosEnable) {
            return TagVideoGridViewWidget(
              videos: homeProvider.tagVideosList,
              isLoading: homeProvider.isTagVideosLoading,
              tagTitle: homeProvider.currentTagTitle.isNotEmpty
                  ? homeProvider.currentTagTitle
                  : (homeProvider.currentTagSlug.isNotEmpty ? homeProvider.currentTagSlug : widget.tagName),
              tagThumbnailUrl: homeProvider.currentTagThumbnailUrl,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: homeProvider.getAllPostList.isEmpty
                      ? Center(
                          child: (homeProvider.isHomeLoading ||
                                  homeProvider.hasPendingDeepLink ||
                                  homeProvider.isRoutingDeepLink ||
                                  homeProvider.isComeFromLinkOrNotification ||
                                  !homeProvider.isInitialHomeLoaded)
                              ? const HomeShimmer()
                              : widget.isAiTags
                                  ? const AppNoData()
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const AppNoData(),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColorTokens.primaryRed,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        homeProvider.getAllPostList = [];
                                        homeProvider.getAllPost();
                                      },
                                      icon: const Icon(Icons.refresh, color: Colors.white),
                                      label: const Text(
                                        "Reload",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is UserScrollNotification &&
                                notification.direction != ScrollDirection.idle) {
                              if (homeProvider.isBottomEnable) {
                                homeProvider.pageChange(isValue: false);
                              }
                            } else if (notification is ScrollUpdateNotification &&
                                notification.dragDetails != null) {
                              if (homeProvider.isBottomEnable) {
                                homeProvider.pageChange(isValue: false);
                              }
                            }
                            return false;
                          },
                          child: PageView.builder(
                            physics: MediaQuery.of(context).orientation == Orientation.landscape
                                ? const NeverScrollableScrollPhysics()
                                : const ClampingScrollPhysics(parent: BouncingScrollPhysics()),
                            controller: homeProvider.pageController!,
                            scrollDirection: Axis.vertical,
                            itemCount: homeProvider.getAllPostList.length,
                            onPageChanged: (value) {
                              if (homeProvider.isBottomEnable) {
                                homeProvider.pageChange(isValue: false);
                              }
                              context.read<VideoProvider>().pauseVideo();
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }

                              if (homeProvider.isEnglishMode) {
                                TranslationService().preloadArticles(homeProvider.getAllPostList, value, ahead: 5);
                              }

                              homeProvider.setCurrentPageIndex(value);
                              if (homeProvider.getAllPostList.length == value + 1 && homeProvider.isAiTagDataLoaded) {
                                Future.delayed(const Duration(milliseconds: 2000), () {
                                  homeProvider.aiTagDataLoaded(false);
                                  homeProvider.setSelectedTagId(0);
                                  homeProvider.getAllPost(postIds: "0");
                                });
                              }

                              context.read<HomeProvider>().flipEvent(
                                    'news',
                                    homeProvider.getAllPostList[value]['id'],
                                    value > autoIndex ? true : false,
                                  );
                              autoIndex = value;

                              final now = DateTime.now();
                              final duration = now.difference(_pageStartTime ?? now);
                              legacy_analytics.AnalyticsService().trackArticleReadingTime(duration, homeProvider.getAllPostList[value]['id']);

                              if (_lastTrackedIndex >= 0 && _lastTrackedIndex < homeProvider.getAllPostList.length) {
                                final prevArticle = homeProvider.getAllPostList[_lastTrackedIndex];
                                AnalyticsService.instance.track(AnalyticsEventName.articleReadComplete, properties: {
                                  'article_id': prevArticle['id'],
                                  'read_duration_seconds': duration.inSeconds,
                                });
                              }

                              _cancelProgressTrackers();
                              if (value >= 0 && value < homeProvider.getAllPostList.length) {
                                final currentArticle = homeProvider.getAllPostList[value];
                                AnalyticsService.instance.track(AnalyticsEventName.articleOpen, properties: {
                                  'article_id': currentArticle['id'],
                                  'article_category': currentArticle['category_name'] ?? currentArticle['category'] ?? '',
                                  'language': currentArticle['language'] ?? 'te',
                                  'source_screen': 'home',
                                  'position': value,
                                });
                                AnalyticsService.instance.track(AnalyticsEventName.articleReadStart, properties: {
                                  'article_id': currentArticle['id'],
                                });
                                if (currentArticle['isReporter'] == 1) {
                                  AnalyticsService.instance.track(AnalyticsEventName.reporterContentOpen, properties: {
                                    'reporter_id': currentArticle['reportedBy'] ?? currentArticle['reporterId'] ?? currentArticle['author'] ?? 'unknown',
                                    'content_id': currentArticle['id'],
                                    'content_type': 'article',
                                  });
                                }
                                _scheduleProgressTrackers(currentArticle['id']);
                                _lastTrackedIndex = value;
                              }

                              _pageStartTime = now;
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
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 3),
                    inactiveTrackColor: Colors.transparent,
                    activeTrackColor: Colors.red,
                    thumbColor: Colors.red,
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
}
