
import 'dart:async';
import 'dart:ui';

import 'package:chotanews/main.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/home_screen/home_screens/standard_post_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../videos_main/video_views/gallery_screen.dart';
import 'google_ads_view.dart';

typedef FlipBack = void Function({bool backToTop});

class ArticlePage extends StatefulWidget {
  final article;

  final FlipBack? flipBack;

  final double height;

  const ArticlePage(
      {super.key, required this.article, this.flipBack, required this.height});

  @override
  ArticlePageState createState() {
    return ArticlePageState();
  }
}

class ArticlePageState extends State<ArticlePage> {
  final ScreenshotController screenshotController = ScreenshotController();
  int topSpace = 0;
  int bottomSpace = 0;
  String? displayFeatures;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    topSpace =
        (MediaQuery.of(mainNavigatorKey.currentContext!).padding.top).toInt() +
            (MediaQuery.of(mainNavigatorKey.currentContext!).padding.bottom)
                .toInt();
  }

  bool isFoldableDevice(BuildContext context) {
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    return displayFeatures.any((feature) =>
    feature.type == DisplayFeatureType.hinge ||
        feature.type == DisplayFeatureType.fold);
  }

  @override
  Widget build(BuildContext context) {
    bool isFoldable = isFoldableDevice(context);
    return Consumer<FlipProvider>(builder: (context, flipProvider, __) {
      return Container(
        color: widget.article.subType == "BigBlackStandard"
            ? Colors.black
            : Colors.white,
        height: widget.height - topSpace,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
            onWillPop: () {
              return Future(() {
                if (widget.flipBack == null) return true;
                widget.flipBack!();
                return false;
              });
            },
            child: Container(
              height: widget.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (widget.article.type == "Image") {
                          if (await canLaunchUrl(
                              Uri.parse(widget.article.content.toString()))) {
                            await launchUrl(
                                Uri.parse(widget.article.content.toString()));
                          } else {
                            throw 'Could not launch ${Uri.parse(widget.article.content.toString())}';
                          }
                        }
                        flipProvider.isShowTopBottomChange(
                            flipProvider.isShowTopBottomView);
                      },
                      child: Screenshot(
                          controller: screenshotController,
                          child: widget.article.type == "GoogleAds"
                              ? GoogleAdsView( article: widget.article, flipProvider: flipProvider,screenshotController: screenshotController, isFoldable: isFoldable,)
                              : widget.article.type == "Image"
                              ? Image.network(
                            width:
                            MediaQuery.of(context).size.width,
                            height:
                            MediaQuery.of(context).size.height,
                            fit: BoxFit.cover,
                            widget.article.imageUrl.url ?? "",
                          )
                              : widget.article.type == "Gallery"
                              ? FullPageCarousel(
                            isHome: true,
                            imageUrls:
                            widget.article.gallery ?? [],
                            postDetails: widget.article,
                          )
                              : StandardPostView(
                            screenshotController:screenshotController,
                            flipProvider: flipProvider,
                            article: widget.article,
                            isFoldable: isFoldable,
                          )),
                    ),
                  ),
                  // Container(
                  //   color: AppColors.borderColor,
                  //   height: 1,
                  // ),
                  // PostBottomActions(
                  //     postType: widget.article.subType,
                  //     flipProvider: flipProvider,
                  //     article: widget.article,
                  //     screenshotController: screenshotController),
                  // height(height: 2),
                ],
              ),
            )),
      );
    });
  }

  bool isLike = false;
}
