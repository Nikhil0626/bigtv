
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:chotanews/main.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/home_screen/home_screens/in_app_web_view.dart';
import 'package:chotanews/screens/home_screen/home_screens/standard_post_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../services/image_to_pdf_helper.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/commant_screen.dart';
import '../../Auth_module/auth_provider/auth_provider.dart';
import '../../videos_main/video_views/gallery_screen.dart';
import '../botton_actions.dart';
import '../home_repo/event_repo.dart';
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
                          child:
                          widget.article.type == "WebView"
                              ?SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: InAppWebViewScreen(webUrl: flipProvider.webUrl.toString(), title: '',)):
                          widget.article.type == "GoogleAds"
                              ? GoogleAdsView( article: widget.article, flipProvider: flipProvider,
                            screenshotController: screenshotController, isFoldable: isFoldable,)
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
                  if(widget.article.type == "Gallery" ||  widget.article.type == "Image")
                  Container(
                    color: Colors.transparent,
                    height: 45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          color: AppColors.borderColor,
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              Consumer<FlipProvider>(
                                  builder: (_, flipProvider, __) {
                                    return BottomActions(
                                      postType: widget.article.subType ?? "",
                                      icon: flipProvider.isLikeList.contains(
                                          widget.article.id.toString())
                                          ? "assets/svg/like_full.svg"
                                          : "assets/svg/like.svg",
                                      label: 'లైక్',
                                      isLike: flipProvider.isLikeList
                                          .contains(
                                          widget.article.id.toString()),
                                      onTap: () {
                                        log("Like");
                                        flipProvider
                                            .isLikePost(widget.article);
                                      },
                                    );
                                  }),
                              width(width: 20),
                              BottomActions(
                                postType: widget.article.subType ?? "",
                                icon: "assets/svg/comment.svg",
                                label: 'కామెంట్',
                                onTap: () {
                                  context
                                      .read<AuthProvider>()
                                      .sendEvent("CommentPage");
                                  EventRepo().sendEvent({
                                    "key": "comments",
                                    "data": {
                                      "device_id":
                                      "${GlobalVariables().deviceId}",
                                      "userId": context
                                          .read<FlipProvider>()
                                          .userId ??
                                          "",
                                      "postId":
                                      widget.article.id.toString(),
                                    }
                                  });
                                  log("Comment --- ${context.read<AuthProvider>().loginType}");
                                  showComments(context, widget.article);
                                  EventRepo().sendEvent({
                                    "key": "comments",
                                    "data": {
                                      "deviceId": GlobalVariables()
                                          .deviceId
                                          .toString(),
                                      "openTime":
                                      DateTime.now().toString()
                                    }
                                  });
                                },
                              ),
                              Spacer(),
                              BottomActions(
                                postType: widget.article.subType ?? "",
                                icon: "assets/svg/share.svg",
                                label: 'షేర్',
                                onTap: () {
                                  EventRepo().sendEvent({
                                    "key": "share_via_articles",
                                    "data": {
                                      "device_id":
                                      "${GlobalVariables().deviceId}",
                                      "userId": context
                                          .read<FlipProvider>()
                                          .userId ??
                                          "",
                                      "postId":
                                      widget.article.id.toString(),
                                      "isWhatAppShare": false,
                                    }
                                  });

                                  sendShareDetails(
                                      context.read<FlipProvider>().userId,
                                      widget.article.id,
                                      widget.article.content.toString());
                                  if (widget.article.type == "Standard" ||
                                      widget.article.type == "Image") {
                                    takeScreenshotAndShare(widget.article, screenshotController);
                                  } else if (widget.article.type ==
                                      "Gallery") {
                                    createAndSharePdf(
                                        context, widget.article);
                                  }
                                },
                              ),
                              width(width: 20),
                                InkWell(
                                  onTap: () {
                                    log("Refresh");
                                    EventRepo().sendEvent({
                                      "key": "reload",
                                      "data": {
                                        "device_id":
                                        "${GlobalVariables().deviceId}",
                                        "userId":
                                        GlobalVariables().userId ??
                                            "",
                                      }
                                    });
                                    flipProvider
                                        .getArticles(refresh: true);
                                  },
                                  child: flipProvider.isRefresh
                                      ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: AppLoadingScreen())
                                      : SvgPicture.asset(
                                    "assets/svg/reload.svg",
                                    height: 22,
                                    width: 22,
                                    color: widget.article.subType ==
                                        "BigBlackStandard"
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }

  bool isLike = false;
}
