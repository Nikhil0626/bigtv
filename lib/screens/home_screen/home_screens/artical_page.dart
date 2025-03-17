import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/main.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/home_screen/home_screens/standard_post_view.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/date_format.dart';
import '../../../utils/fold_models.dart';
import '../first_card_home_feeds.dart';
import '../post_bottom_actions.dart';
import '../../videos_main/video_views/gallery_screen.dart';
import '../../videos_main/video_views/video_preview.dart';
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
              color: Colors.blue,
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
                          child: widget.article.type == "addMob"
                              ? GoogleAdsView()
                              : widget.article.type == "Image"
                              ? SizedBox(
                            width:
                            MediaQuery.of(context).size.width,
                            height:
                            MediaQuery.of(context).size.height,
                            child: Image.network(
                              fit: BoxFit.cover,
                              widget.article.imageUrl.url ?? "",
                            ),
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
