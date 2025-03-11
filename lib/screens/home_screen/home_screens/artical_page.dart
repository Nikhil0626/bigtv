import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/main.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
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
    log("bottom --- ${MediaQuery.of(mainNavigatorKey.currentContext!).padding.bottom}  top --- ${MediaQuery.of(mainNavigatorKey.currentContext!).padding.top}");
    _loadAd();


  }
  bool isFoldableDevice(BuildContext context) {
    final displayFeatures = MediaQuery.of(context).displayFeatures;

    // Check if there is a hinge or fold
    return displayFeatures.any((feature) =>
    feature.type == DisplayFeatureType.hinge ||
        feature.type == DisplayFeatureType.fold);
  }

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;


  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-4822261519089529/4402371323', // Test ID
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad failed to load: $error');
          ad.dispose();
          _isAdLoaded = false;
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium)
    );
    _nativeAd!.load();
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
              height: widget.height ,
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
                        child: widget.article.type == "Image"
                            ? Container(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Image.network(
                                    fit: BoxFit.cover,
                                    widget.article.imageUrl.url ?? "",
                                  ),
                                ),
                              )
                            : widget.article.type == "addMob"
                                ?_isAdLoaded
                                    ? AdWidget(ad: _nativeAd!)
                                    : SizedBox()
                                :widget.article.type == "Gallery"
                                ? FullPageCarousel(
                                    isHome: true,
                                    imageUrls: widget.article.gallery ?? [],
                                    postDetails: widget.article,
                                  )
                                : widget.article.homepage != null
                                    ? FirstCardHomeFeeds(
                                        getHomeList: widget.article.homepage)
                                    : Container(
                                        color: widget.article.subType ==
                                                "BigBlackStandard"
                                            ? Colors.black
                                            : Colors.white,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              // height: MediaQuery.of(context).size.height/2.35,
                                              flex: widget.article.subType ==
                                                      "BigBlackStandard"
                                                  ? isFoldable
                                                      ? 9
                                                      : 7
                                                  : isFoldable
                                                      ? widget.article.subType ==
                                                              "BulletPost"
                                                          ? 7
                                                          : 9
                                                      : 4,
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                      child: widget
                                                                  .article.type ==
                                                              "Video"
                                                          ? Container(
                                                              color: Colors.black,
                                                              child: Center(
                                                                  child: VideoPreview(
                                                                      imageUrl: widget
                                                                          .article
                                                                          .imageUrl!
                                                                          .url
                                                                          .toString(),
                                                                      url: widget
                                                                              .article
                                                                              .videoUrl
                                                                              ?.url ??
                                                                          "")))
                                                          : CachedNetworkImage(
                                                              imageUrl:
                                                                  '${widget.article.imageUrl.url}',
                                                              height:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              fit: isFoldable
                                                                  ? BoxFit.fill
                                                                  : BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      Container(
                                                                color: AppColors
                                                                    .borderColor
                                                                    .withOpacity(
                                                                        .2),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Center(
                                                                      child: Icon(
                                                                Icons.image,
                                                                size: 100,
                                                                color: Colors.grey
                                                                    .shade300,
                                                              )),
                                                            )),
                                                  if (widget.article.isReporter)
                                                    Positioned(
                                                        bottom: 30,
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            // width: 100,
                                                            child: Text(
                                                              widget.article
                                                                  .reportedBy
                                                                  .toString(),
                                                              style: homeScreenFontStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ))),
                                                  Positioned(
                                                      bottom: -12,
                                                      child: Container(
                                                          margin: const EdgeInsets
                                                              .all(8),
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8),
                                                          height: 30,
                                                          width: 100,
                                                          decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Image.asset(
                                                            "assets/images/brandlogo.png",
                                                          ))),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        widget.article.title ??
                                                            "No Title",
                                                        style: homeScreenFontStyle(
                                                            color: widget.article
                                                                        .subType ==
                                                                    "BigBlackStandard"
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontSize:
                                                                Platform.isIOS
                                                                    ? 19
                                                                    : 18,
                                                            fontWeight:
                                                                FontWeight.bold)),
                                                    height(height: 8),
                                                    Expanded(
                                                      child:
                                                          widget.article
                                                                      .subType ==
                                                                  "BulletPost"
                                                              ? Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    (widget.article
                                                                                .content !=
                                                                            "")
                                                                        ? Text(
                                                                            widget
                                                                                .article
                                                                                .content,
                                                                            style:
                                                                                homeScreenFontStyle(
                                                                              color:
                                                                                  Colors.black,
                                                                              fontWeight:
                                                                                  FontWeight.w500,
                                                                              fontSize:
                                                                                  16,
                                                                            ))
                                                                        : const SizedBox
                                                                            .shrink(),
                                                                    height(
                                                                        height:
                                                                            8),
                                                                    Expanded(
                                                                      child:
                                                                          ListView(
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        children: widget
                                                                            .article
                                                                            .bulletPoints
                                                                            .map<Widget>(
                                                                                (item) {
                                                                          // Explicitly specify <Widget>
                                                                          return Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              const Text("• ",
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle(fontSize: 30)),
                                                                              // Bullet point
                                                                              Expanded(
                                                                                child: Text(
                                                                                  item,
                                                                                  style: homeScreenFontStyle(
                                                                                    color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.black,
                                                                                    fontWeight: FontWeight.w400,
                                                                                    fontSize: Platform.isIOS ? 17 : 16,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }).toList(), // Ensure it is converted to List<Widget>
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '\n\nPosted ${formatTimeDifference(widget.article.created)}',
                                                                      style:
                                                                          fontStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : RichText(
                                                                  text: TextSpan(
                                                                    text: '',
                                                                    children: [
                                                                      ..._parseText(
                                                                        context,
                                                                        '${widget.article.content}',
                                                                        widget
                                                                            .article
                                                                            .links,
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '\n\nPosted ${formatTimeDifference(widget.article.created)}',
                                                                        style:
                                                                            fontStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          color: Colors
                                                                              .grey,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                      ),
                    ),
                  ),
                  Container(
                    color: AppColors.borderColor,
                    height: 1,
                  ),
                  PostBottomActions(
                      postType: widget.article.subType,
                      flipProvider: flipProvider,
                      article: widget.article,
                      screenshotController: screenshotController),
                  // height(height: 2),
                ],
              ),
            )),
      );
    });
  }

  bool isLike = false;

  List<TextSpan> _parseText(
      BuildContext context, String text, List<LinkModel>? links) {
    RegExp linkRegExp =
        RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(
      linkRegExp,
      onMatch: (match) {
        String link = match.group(0)!;

        if (link.contains('<link1>')) {
          log("click linkss    ${links!.first.value.toString()}");
          link = links.first.value.toString();
        }

        if (link.contains('<link1>') && links != null && links.isNotEmpty) {
          link = links[0].value.toString();
        } else if (link.contains('<link2>') && links != null && links.length > 1) {
          link = links[1].value.toString();
        } else if (link.contains('<link3>') && links != null && links.length > 2) {
          link = links[2].value.toString();
        } else {
          link = link;
        }
        spans.add(TextSpan(
          text: match
              .group(0)
              .toString()
              .replaceFirst('<link1>', '')
              .replaceFirst('</link1>', '')
              .replaceFirst('<link2>', '')
              .replaceFirst('</link2>', '')
              .replaceFirst('<link3>', '')
              .replaceFirst('</link3>', ''),
          style: fontStyle(
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              print(" $link");
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                CustomToast.showErrorToast(msg: "Could not launch $link");
              }
            },
        ));

        return "";
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(
            text: nonMatch,
            style: homeScreenFontStyle(
              color: widget.article.subType == "BigBlackStandard"
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: Platform.isIOS ? 17 : 16
              ,
            )));
        return "";
      },
    );

    return spans;
  }


}
