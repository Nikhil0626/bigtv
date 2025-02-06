import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../../utils/image_view_popup.dart';
import '../home_screen/botton_actions.dart';
import '../home_screen/first_card_home_feeds.dart';
import '../home_screen/home_bloc.dart';
import '../home_screen/home_event.dart';
import '../videos_main/video_views/gallery_screen.dart';
import '../videos_main/video_views/video_preview.dart';
import 'article_bloc_provider.dart';

typedef FlipBack = void Function({bool backToTop});

class ArticlePage extends StatefulWidget {
  final HomeScreenModel article;

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
  Future<void> _selectSources(BuildContext context) async {
    // String? result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SourcesPage(bloc: ArticleBlocProvider.of(context))),
    // );
    // if (result == null) {
    //   ArticleBlocProvider.of(context).getArticles(refresh: true);
    // }
  }

  Future<void> _aboutPage(BuildContext context) async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
  }

  _launchURL() async {
    // String url = widget.article.url ?? '';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch $url")));
    // }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    Icon _getMenuIcon(TargetPlatform platform) {
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return const Icon(Icons.more_horiz);
        default:
          return const Icon(Icons.more_vert);
      }
    }

    Icon _getBackIcon(TargetPlatform platform) {
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return const Icon(Icons.arrow_back_ios);
        default:
          return const Icon(Icons.arrow_back);
      }
    }

    return Container(
      color: Colors.white,
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      child: WillPopScope(
        onWillPop: () {
          return Future(() {
            if (widget.flipBack == null) return true;
            widget.flipBack!();
            return false;
          });
        },
        child: Scaffold(
            body: widget.article.type == "Image"
                ? CachedNetworkImage(
                    imageUrl: widget.article.imageUrl.url ?? "",
                  )
                : widget.article.type == "Gallery"
                    ? FullPageCarousel(imageUrls: widget.article.gallery ?? [])
                    : widget.article.homepage != null
                        ? FirstCardHomeFeeds(
                            getHomeList: widget.article.homepage)
                        : InkWell(
                            onTap: () {
                              context.read<HomeBloc>().add(MenuChange());
                            },
                            child: Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          child: widget.article.type == "Video"
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
                                                  widget.article.imageUrl.url,
                                                  key: ValueKey(widget
                                                      .article.imageUrl.url),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                          // CachedNetworkImage(
                                          //   imageUrl: widget.article.imageUrl.url ?? "",
                                          //   imageBuilder: (context, imageProvider) =>
                                          //       Container(
                                          //         height: MediaQuery.of(context).size.height,
                                          //         width: MediaQuery.of(context).size.width,
                                          //         decoration: BoxDecoration(
                                          //           image: DecorationImage(
                                          //             image: imageProvider,
                                          //             fit: BoxFit.cover,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //   errorWidget: (context, url, error) => Container(
                                          //     height: MediaQuery.of(context).size.height,
                                          //     width: MediaQuery.of(context).size.width,
                                          //     decoration: const BoxDecoration(
                                          //       borderRadius:
                                          //       BorderRadius.all(Radius.circular(32)),
                                          //     ),
                                          //     child: const Icon(
                                          //       Icons.account_box,
                                          //       size: 200,
                                          //     ),
                                          //   ),
                                          // )
                                        ),
                                        Positioned(
                                            bottom: 1,
                                            child: Container(
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                height: 30,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .appButtonColor
                                                        .withOpacity(.4),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10))),
                                                child: Image.asset(
                                                  "assets/images/brandlogo.png",
                                                ))),
                                        Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: InkWell(
                                                onTap: () {
                                                  if (widget
                                                      .article.type == "Video") {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => VideoPreview(
                                                            url: widget.article.videoUrl!.url.toString(),
                                                            isVideoScreen: true,
                                                          ),
                                                        ));
                                                  } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ImageViewPopup(
                                                          imageUrl: widget
                                                              .article
                                                              .imageUrl
                                                              .url,
                                                        ),
                                                      ));
                                                  }
                                                },
                                                child: const Center(
                                                    child: Icon(
                                                  Icons.zoom_out_map_sharp,
                                                  color:
                                                      AppColors.appButtonColor,
                                                  size: 24,
                                                )))),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              widget.article.title ??
                                                  "No Title",
                                              style: fontStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          height(height: 10),
                                          Expanded(
                                            child: Text(
                                                "${widget.article.content}\n\nPosted ${formatTimeDifference(widget.article.created)}",
                                                style: fontStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[800])),
                                          ),
                                          height(height: 4),
                                          const Divider(
                                              color: AppColors.borderColor),
                                          SizedBox(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                BottomActions(
                                                    icon:
                                                        "assets/svg/reload.svg",
                                                    label: 'రిలోడ్ ',
                                                    onTap: () {
                                                      log("Refresh");
                                                      ArticleBlocProvider.of(
                                                              context)
                                                          .getArticles(
                                                              refresh: true);
                                                    }),
                                                BottomActions(
                                                    icon: "assets/svg/like.svg",
                                                    label: 'లైక్',
                                                    isLike: isLike,
                                                    onTap: () {
                                                      log(
                                                        "Like",
                                                      );
                                                      setState(() {
                                                        isLike = !isLike;
                                                      });
                                                    }),
                                                BottomActions(
                                                    icon:
                                                        "assets/svg/comment.svg",
                                                    label: 'కామెంట్',
                                                    onTap: () {
                                                      log("Comment");
                                                      showComments(
                                                          context,
                                                          widget.article.id
                                                              .toString());
                                                      // context.read<HomeBloc>().add(GetAllNewsFeed());
                                                    }),
                                                BottomActions(
                                                    icon:
                                                        "assets/svg/share.svg",
                                                    label: ' షేర్',
                                                    onTap: () {
                                                      log("Share");
                                                      context.read<HomeBloc>().add(
                                                          SendNewsToSocialMedia(
                                                              id: widget.article
                                                                  .linkURLAndroid));
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
      ),
    );
  }

  bool isLike = false;
}
