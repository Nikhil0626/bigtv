import 'dart:async';
import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/date_format.dart';
import '../home_screen/first_card_home_feeds.dart';
import '../home_screen/post_bottom_actions.dart';
import '../videos_main/video_views/gallery_screen.dart';
import '../videos_main/video_views/video_preview.dart';

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

  @override
  Widget build(BuildContext context) {
    double heights = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom)-32;
    return Consumer<FlipProvider>(builder: (context, flipProvider, __) {
      return Container(
        color: widget.article.subType ==
            "BigBlackStandard"?Colors.black:Colors.white,
        height:heights,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
            onWillPop: () {
              return Future(() {
                if (widget.flipBack == null) return true;
                widget.flipBack!();
                return false;
              });
            },
            child: Column(
              children: [
                Expanded(
                  child: Screenshot(
                    controller: screenshotController,
                    child: widget.article.type == "Image"
                        ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Image.network(
                        fit: BoxFit.fill,
                        widget.article.imageUrl.url ?? "",
                      ),
                    )
                        : widget.article.type == "Gallery"
                            ? FullPageCarousel(
                                isHome :true,
                                imageUrls: widget.article.gallery ?? [],
                                postDetails: widget.article,
                              )
                            : widget.article.homepage != null
                                ? FirstCardHomeFeeds(
                                    getHomeList: widget.article.homepage)
                                : InkWell(
                      onTap: (){
                        flipProvider
                            .isShowTopBottomChange(flipProvider.isShowTopBottomView);
                      },
                                  child: Container(
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
                                            flex:  widget.article.subType ==
                                                    "BigBlackStandard"
                                                ? 8
                                                : 4,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  child: widget.article.type ==
                                                          "Video"
                                                      ? Container(
                                                          color: Colors.black,
                                                          child: Center(
                                                              child: VideoPreview(
                                                                  url: widget
                                                                          .article
                                                                          .videoUrl
                                                                          ?.url ??
                                                                      "")))
                                                      : Image.network(
                                                          widget.article
                                                              .imageUrl.url,
                                                          key: ValueKey(widget
                                                              .article
                                                              .imageUrl
                                                              .url),
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                        ),
                                                ),
                                                Positioned(
                                                    bottom: -12,
                                                    child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        height: 30,
                                                        width: 100,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(topLeft:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                                      topRight: Radius.circular(10)
                                                                )),
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
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  height(height: 8),
                                                  Expanded(
                                                    child:
                                                        widget.article
                                                                    .subType ==
                                                                "BulletPost"
                                                            ? ListView(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                children: widget
                                                                    .article
                                                                    .bulletPoints
                                                                    .map<Widget>(
                                                                        (item) {
                                                                  // Explicitly specify <Widget>
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4.0),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Text(
                                                                            "• ",
                                                                            style:
                                                                                TextStyle(fontSize: 24)),
                                                                        // Bullet point
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            item,
                                                                            style:
                                                                                fontStyle(fontSize: 16),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }).toList(), // Ensure it is converted to List<Widget>
                                                              )
                                                            : RichText(
                                                                text: TextSpan(
                                                                  text: '',
                                                                  children:
                                                                      _parseText(
                                                                    context,
                                                                    '${widget.article.content}',
                                                                    widget
                                                                        .article
                                                                        .links,
                                                                  ),
                                                                ),
                                                              ),
                                                  ),
                                                  Text(
                                                      "\nPosted ${formatTimeDifference(widget.article.created)}",
                                                      style: fontStyle(
                                                          fontSize: 12,
                                                          color: widget.article
                                                                      .subType ==
                                                                  "BigBlackStandard"
                                                              ? Colors.white
                                                              : Colors
                                                                  .grey[800])),
                                                  height(height: 1)

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
                const Divider(color: AppColors.borderColor),
                PostBottomActions(
                    postType: widget.article.subType,
                    flipProvider: flipProvider,
                    article: widget.article,
                    screenshotController: screenshotController),
                // height(height: 2),
              ],
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
          link = links!.first.value.toString();
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
              print("ghhgjjkjjhg $link");
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not launch $link")));
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
              fontSize: 16,
            )));
        return "";
      },
    );

    return spans;
  }
}
