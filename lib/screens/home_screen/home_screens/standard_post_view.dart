import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/date_format.dart';
import '../../videos_main/video_views/video_preview.dart';
import '../home_models/home_screen_model.dart';

class StandardPostView extends StatefulWidget {
  final article;
  final isFoldable;
  const StandardPostView({super.key,required this.article,required this.isFoldable});

  @override
  State<StandardPostView> createState() => _StandardPostViewState();
}

class _StandardPostViewState extends State<StandardPostView> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                ? widget.isFoldable
                ? 9
                : 7
                : widget.isFoldable
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
                      fit: widget.isFoldable
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
    );
  }



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
