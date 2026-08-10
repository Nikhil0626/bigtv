import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_screen/android_ads_view.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_screen.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/gallery_screen.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_preview.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/full_standed_video_view.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_player.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/botton_actions.dart';
import 'package:chotanews/utils/commant_screen.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:chotanews/utils/image_view_ads.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreenBytView extends StatefulWidget {
  final article;
  final pageController;
  final int length;
  final int index;
  final String aiTagId;
  final String aiTagName;
  final bool isaiTags;
  final bool isMainScreen;

  const MainScreenBytView({
    super.key,
    required this.article,
    this.isaiTags = false,
    this.aiTagId = "",
    this.aiTagName = "",
    this.isMainScreen = false,
    this.pageController,
    this.length = 0,
    this.index = 0,
  });

  @override
  State<MainScreenBytView> createState() => _MainScreenBytViewState();
}

class _MainScreenBytViewState extends State<MainScreenBytView> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // Debug log for AI tag videos
    if (widget.isaiTags && widget.article['type'] == "Video") {
      log("AI Tag Video Article: ${widget.article['id']}");
      log("Video URL: ${widget.article['video_url']}");
      log("Image URL: ${widget.article['image_url']}");
      log("Full Image URL: ${_getImageUrl(widget.article['image_url'])}");
    }
  }

  // Helper method to get proper image URL
  String _getImageUrl(dynamic imageUrl) {
    if (imageUrl == null) {
      return "https://via.placeholder.com/400x300?text=No+Image";
    }

    String url = imageUrl.toString();

    // If it's already a valid URL, return as is
    if (url.startsWith('http')) {
      return url;
    }

    // Handle different possible formats
    if (url.startsWith('/')) {
      return "https://migwp.chotanews.com$url";
    }

    // Default construction
    return "https://migwp.chotanews.com/$url";
  }

  // Helper method to get proper video URL
  String _getVideoUrl(dynamic videoUrl) {
    if (videoUrl == null) {
      return "";
    }

    String url = videoUrl.toString();

    // If it's already a valid URL, return as is
    if (url.startsWith('http')) {
      return url;
    }

    // Handle different possible formats
    if (url.startsWith('/')) {
      return "https://migwp.chotanews.com$url";
    }

    // Default construction
    return "https://migwp.chotanews.com/$url";
  }

  @override
  Widget build(BuildContext context) {
    return (widget.index + 2 >
                context.read<HomeProvider>().getAllPostList.length &&
            context.read<HomeProvider>().isAiTagDataLoaded)
        ? Card(
            elevation: 4,
            color: Colors.green[50],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/svg/done.json",
                        height: 200, width: 200),
                    height(
                      height: 10,
                    ),
                    Text(
                      "Your have Read the News",
                      style: homeScreenFontStyle(
                          color: AppColors.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    height(
                      height: 20,
                    ),
                    Text(
                      "${context.read<HomeProvider>().getAllPostList.length}/${context.read<HomeProvider>().getAllPostList.length} Completed",
                      style: homeScreenFontStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:
                (widget.article['type'].toString() == "Standard" &&
                        widget.article['subType'].toString().toLowerCase() ==
                            "polls")
                    ? PollScreenDesign(
                        artical: widget.article,
                        index: widget.index,
                      )
                    : (widget.article['type'].toString() == "Standard" &&
                            widget.article['subType']
                                    .toString()
                                    .toLowerCase() ==
                                "reviews")
                        ? MovieRatings(
                            article: widget.article,
                          )
                        : InkWell(
                            onTap: () {
                              context.read<HomeProvider>().pageChange(
                                  isValue: !context
                                      .read<HomeProvider>()
                                      .isBottomEnable);
                            },
                            child: Screenshot(
                              controller: adsScreenshotController,
                              child: widget.article['type'].toString() ==
                                      "WebUrl"
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InAppWebViewScreen(
                                        webUrl: context
                                            .read<HomeProvider>()
                                            .webUrl
                                            .toString(),
                                        title: '',
                                      ),
                                    )
                                  : widget.article['type'] == "GoogleAds"
                                      ? const SizedBox.shrink()
                                      : widget.article['type'] == "Reel"
                                          ? FullStandardVideoView(
                                              reelData: widget.article,
                                            )
                                          : (widget.article['type'] ==
                                                      "Image" &&
                                                  widget.article['subType'] !=
                                                      "ImageAd")
                                              ? Stack(
                                                  children: [
                                                    Image.network(
                                                      _getImageUrl(
                                                          widget.article[
                                                              'image_url']),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      fit: BoxFit.fill,
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            bottom: MediaQuery.of(
                                                                        context)
                                                                    .padding
                                                                    .bottom +
                                                                6),
                                                        child: Container(
                                                          height: 45.sp,
                                                          color: Colors
                                                              .transparent,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            16.0
                                                                                .sp,
                                                                        vertical:
                                                                            5.sp),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Consumer<
                                                                            SettingsProvider>(
                                                                        builder: (_,
                                                                            settingsProvider,
                                                                            __) {
                                                                      return BottomActions(
                                                                        postType:
                                                                            widget.article['subType'] ??
                                                                                "",
                                                                        icon: settingsProvider.isLikeList.contains(widget.article['id'].toString())
                                                                            ? "assets/svg/like_full.svg"
                                                                            : "assets/svg/like.svg",
                                                                        label:
                                                                            'லைக்',
                                                                        isLike: settingsProvider
                                                                            .isLikeList
                                                                            .contains(widget.article['id'].toString()),
                                                                        onTap:
                                                                            () async {
                                                                          log("Like");
                                                                          settingsProvider
                                                                              .isLikePost(widget.article);
                                                                          EventRepo()
                                                                              .addEvent({
                                                                            "like":
                                                                                !settingsProvider.isLikeList.contains(widget.article['id'].toString()),
                                                                            "postId":
                                                                                widget.article['id'].toString() ?? '000',
                                                                            "createAt":
                                                                                DateTime.now().toString(),
                                                                            "postTitle":
                                                                                widget.article['title'].toString()
                                                                          }, "liked_article");
                                                                        },
                                                                      );
                                                                    }),
                                                                    width(
                                                                        width:
                                                                            6),
                                                                    BottomActions(
                                                                      postType:
                                                                          widget.article['subType'].toString() ??
                                                                              "",
                                                                      icon:
                                                                          "assets/svg/new_comment.svg",
                                                                      label:
                                                                          'கமெண்ட்',
                                                                      onTap:
                                                                          () async {
                                                                        if (context
                                                                            .mounted) {
                                                                          context
                                                                              .read<AuthenticationProvider>()
                                                                              .sendEvent("CommentPage");
                                                                          showComments(
                                                                              context,
                                                                              widget.article['id'],
                                                                              widget.article['title']);
                                                                        }
                                                                      },
                                                                    ),
                                                                    const Spacer(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        SharedPreferences
                                                                            sp =
                                                                            await SharedPreferences.getInstance();
                                                                        String?
                                                                            userId =
                                                                            sp.getString("userId");
                                                                        EventRepo()
                                                                            .addEvent({
                                                                          "share":
                                                                              "news",
                                                                          "postId": widget
                                                                              .article['id']
                                                                              .toString(),
                                                                          "createAt":
                                                                              DateTime.now().toString(),
                                                                          "postTitle": widget
                                                                              .article['title']
                                                                              .toString()
                                                                        }, "shared_article");

                                                                        sendShareDetails(
                                                                            userId,
                                                                            widget.article['id'],
                                                                            widget.article['content'].toString());

                                                                        if (widget.article['type'] == "Standard" ||
                                                                            widget.article['type'] ==
                                                                                "Video" ||
                                                                            widget.article['type'] ==
                                                                                "Image") {
                                                                          try {
                                                                            final image =
                                                                                await adsScreenshotController.capture(
                                                                              pixelRatio: 2.0,
                                                                            );
                                                                            if (image !=
                                                                                null) {
                                                                              final directory = await getTemporaryDirectory();
                                                                              final imagePath = '${directory.path}/${widget.article['id']}.png';
                                                                              final imageFile = File(imagePath);
                                                                              await imageFile.writeAsBytes(image);

                                                                              Share.shareXFiles([
                                                                                XFile(imageFile.path)
                                                                              ], text: widget.article['linkURLAndroid'].toString());
                                                                            } else {
                                                                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                                            }
                                                                          } catch (e) {
                                                                            CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                                          }
                                                                        } else if (widget.article['type'] ==
                                                                            "Gallery") {
                                                                          context.read<HomeProvider>().createAndSharePdfs(
                                                                              context,
                                                                              widget.article);
                                                                        }
                                                                        EventRepo()
                                                                            .addEvent({
                                                                          "share":
                                                                              "news",
                                                                          "postId": widget
                                                                              .article['id']
                                                                              .toString(),
                                                                          "createAt":
                                                                              DateTime.now().toString(),
                                                                          "postTitle": widget
                                                                              .article['title']
                                                                              .toString()
                                                                        }, "shared_article");
                                                                      },
                                                                      child: context
                                                                              .watch<
                                                                                  HomeProvider>()
                                                                              .isPdfSending
                                                                          ? const SizedBox(
                                                                              height: 22,
                                                                              width: 22,
                                                                              child: AppLoadingScreen())
                                                                          : SvgPicture.asset(
                                                                              "assets/svg/share.svg",
                                                                              height: 20,
                                                                              width: 20,
                                                                              color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
                                                                            ),
                                                                    ),
                                                                    width(
                                                                        width:
                                                                            20),
                                                                    Consumer<
                                                                            HomeProvider>(
                                                                        builder: (_,
                                                                            homeProvide,
                                                                            __) {
                                                                      return SizedBox(
                                                                        height:
                                                                            24,
                                                                        width:
                                                                            24,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            log("Refresh");

                                                                            homeProvide.isReloadData();
                                                                            if (widget.isaiTags) {
                                                                              EventRepo().addEvent({
                                                                                "refresh": false,
                                                                                "createAt": DateTime.now().toString()
                                                                              }, "reload_article");
                                                                              homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
                                                                                (value) {
                                                                                  homeProvide.isReloadFalse();
                                                                                },
                                                                              );
                                                                            } else {
                                                                              homeProvide.getAllPostList = [];
                                                                              homeProvide.getAllPost();
                                                                              EventRepo().addEvent({
                                                                                "refresh": true,
                                                                                "createAt": DateTime.now().toString()
                                                                              }, "reload_article");
                                                                            }
                                                                          },
                                                                          child: context.read<HomeProvider>().isReload
                                                                              ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                                              : SvgPicture.asset(
                                                                                  "assets/svg/new_refresh.svg",
                                                                                  height: 22,
                                                                                  width: 22,
                                                                                  color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
                                                                                ),
                                                                        ),
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : (widget.article['type'] ==
                                                          "Image" &&
                                                      widget.article[
                                                              'subType'] ==
                                                          "ImageAd")
                                                  ? const SizedBox.shrink()
                                                  : widget.article['type'] ==
                                                          "Gallery"
                                                      ? KeepAlivePage(
                                                          keepAlive: true,
                                                          child: Stack(
                                                            children: [
                                                              FullPageCarousel(
                                                                isHome: true,
                                                                imageUrls: widget
                                                                            .article[
                                                                        'gallery'] ??
                                                                    [],
                                                                postDetails:
                                                                    widget
                                                                        .article,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                /// IMAGE / VIDEO CONTAINER
                                                                Container(
                                                                  height: widget.article[
                                                                              'subType'] ==
                                                                          "BigBlackStandard"
                                                                      ? MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .52
                                                                      : MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .33,
                                                                  child: widget.article['type'] ==
                                                                              "Video" &&
                                                                          widget.article['video_platform'] ==
                                                                              "Twitter"
                                                                      ? CustomVideoPlayer(
                                                                          url: _getVideoUrl(
                                                                              widget.article['video_url']),
                                                                          imageUrl:
                                                                              _getImageUrl(widget.article['image_url']),
                                                                        )
                                                                      : widget.article['type'] ==
                                                                              "Video"
                                                                          ? SizedBox(
                                                                              height: MediaQuery.of(context).size.height * .33,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              child: VideoPreview(
                                                                                imageUrl: _getImageUrl(widget.article['image_url']),
                                                                                url: _getVideoUrl(widget.article['video_url']),
                                                                                isFoldable: false,
                                                                              ),
                                                                            )
                                                                          : InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => ImagePreview(
                                                                                      imageUrl: _getImageUrl(widget.article['image_url']),
                                                                                      title: widget.article['title'],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: SizedBox(
                                                                                height: MediaQuery.of(context).size.height * .35,
                                                                                child: CachedNetworkImage(
                                                                                  imageUrl: _getImageUrl(widget.article['image_url']),
                                                                                  height: MediaQuery.of(context).size.height * (widget.article['subType'] == "BigBlackStandard" ? .65 : .4),
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  fit: BoxFit.fill,
                                                                                  placeholder: (context, url) => Container(
                                                                                    color: AppColors.borderColor.withValues(alpha: .2),
                                                                                  ),
                                                                                  errorWidget: (context, url, error) => Center(
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.error_outline,
                                                                                          size: 50,
                                                                                          color: Colors.grey.shade400,
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          "Failed to load image",
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade400,
                                                                                            fontSize: 12,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                ),

                                                                /// SHOW BACK BUTTON ONLY FOR AI TAG POSTS
                                                                if (widget
                                                                    .isaiTags)
                                                                  Positioned(
                                                                    top: MediaQuery.of(context)
                                                                            .padding
                                                                            .top +
                                                                        10,
                                                                    right: 16,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        context
                                                                            .read<VideoProvider>()
                                                                            .pauseVideo();
                                                                        context
                                                                            .read<HomeProvider>()
                                                                            .setSelectedTagId(0);
                                                                        context
                                                                            .read<HomeProvider>()
                                                                            .aiTagDataLoaded(false);
                                                                        context
                                                                            .read<HomeProvider>()
                                                                            .pageChange(
                                                                              isValue: true,
                                                                            );
                                                                        context
                                                                            .read<HomeProvider>()
                                                                            .getAllPost();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(7),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.black54,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_back,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 10,
                                                                  right: 0,
                                                                  child: widget.article[
                                                                              'type'] ==
                                                                          "Video"
                                                                      ? const SizedBox
                                                                          .shrink()
                                                                      : Container(
                                                                          padding: EdgeInsets.only(
                                                                              bottom: 6,
                                                                              right: 120,
                                                                              left: 10),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.bottomLeft,
                                                                            child:
                                                                                HighlightedTitleText(
                                                                              text: widget.article['title'] ?? "No Title",
                                                                              fontSize: 16,
                                                                              highlightColor: const Color(0xFFED1C24).withValues(alpha: 0.7),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/images/BigTvPostLogo.png",
                                                                    width: 120,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 4,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color: Color(
                                                                  0xFFED1C24),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                color: widget.article[
                                                                            'subType'] ==
                                                                        "BigBlackStandard"
                                                                    ? Colors
                                                                        .black
                                                                    : (Theme.of(context).brightness ==
                                                                            Brightness
                                                                                .dark
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .white),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16.0),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      /// Title and Action Icons in a Row with minimal spacing
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                5.0),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                widget.article['title'] ?? "No Title",
                                                                                style: homeScreenFontStyle(
                                                                                  color: const Color(0xFFED1C24),
                                                                                  fontSize: 18.sp,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 8),

                                                                            /// Action Icons Container with minimal spacing
                                                                            Container(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              decoration: BoxDecoration(border: BoxBorder.all(color: Color(0xFFED1C24), width: 0.36), borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  /// Like Icon - Size 14
                                                                                  Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                                                                    return InkWell(
                                                                                      onTap: () async {
                                                                                        log("Like");
                                                                                        settingsProvider.isLikePost(widget.article);
                                                                                        EventRepo().addEvent({
                                                                                          "isLike": !settingsProvider.isLikeList.contains(widget.article['id'].toString()),
                                                                                          "postId": widget.article['id'].toString() ?? "000",
                                                                                          "createAt": DateTime.now().toString(),
                                                                                          "postTitle": widget.article['title'].toString()
                                                                                        }, "liked_article");
                                                                                      },
                                                                                      child: SvgPicture.asset(
                                                                                        settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                                                        height: 16,
                                                                                        width: 16,
                                                                                        color: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? AppColorTokens.primaryRed : AppColorTokens.primaryRed,
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                                  const SizedBox(width: 8),

                                                                                  /// Comment Icon - Size 14
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      log("Comment...");
                                                                                      if (context.mounted) {
                                                                                        context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                                                        showComments(context, widget.article['id'], widget.article['title']);
                                                                                      }
                                                                                    },
                                                                                    child: SvgPicture.asset(
                                                                                      "assets/svg/new_comment.svg",
                                                                                      height: 16,
                                                                                      width: 16,
                                                                                      color: Color(0xFFED1C24),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 8),

                                                                                  /// Share Icon - Size 14
                                                                                  InkWell(
                                                                                    onTap: () async {
                                                                                      SharedPreferences sp = await SharedPreferences.getInstance();
                                                                                      String? userId = sp.getString("userId");
                                                                                      sendShareDetails(userId, widget.article['id'], widget.article['content'].toString());
                                                                                      if (widget.article['type'] == "Standard" || widget.article['type'] == "Video" || widget.article['type'] == "Image") {
                                                                                        try {
                                                                                          final image = await adsScreenshotController.capture(
                                                                                            pixelRatio: 2.0,
                                                                                          );
                                                                                          if (image != null) {
                                                                                            final directory = await getTemporaryDirectory();
                                                                                            final imagePath = '${directory.path}/${widget.article['id']}.png';
                                                                                            final imageFile = File(imagePath);
                                                                                            await imageFile.writeAsBytes(image);

                                                                                            final String shareLink = (Platform.isIOS
                                                                                                    ? (widget.article['linkURLIos'] ?? widget.article['linkURLAndroid'])
                                                                                                    : widget.article['linkURLAndroid'])
                                                                                                ?.toString() ?? '';
                                                                                            final String textToShare = (shareLink.isNotEmpty && shareLink != 'null') ? shareLink : '';

                                                                                            final RenderBox? box = context.findRenderObject() as RenderBox?;
                                                                                            final Rect sharePosition = box != null
                                                                                                ? (box.localToGlobal(Offset.zero) & box.size)
                                                                                                : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);

                                                                                            await Share.shareXFiles(
                                                                                              [XFile(imageFile.path, mimeType: 'image/png', bytes: image)],
                                                                                              text: textToShare.isNotEmpty ? textToShare : null,
                                                                                              sharePositionOrigin: sharePosition,
                                                                                            );
                                                                                          } else {
                                                                                            CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                                                          }
                                                                                        } catch (e) {
                                                                                          CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                                                        }
                                                                                      } else if (widget.article['type'] == "Gallery") {
                                                                                        context.read<HomeProvider>().createAndSharePdfs(context, widget.article);
                                                                                      }
                                                                                      EventRepo().addEvent({
                                                                                        "share": "news",
                                                                                        "postId": widget.article['id'].toString(),
                                                                                        "createAt": DateTime.now().toString(),
                                                                                        "postTitle": widget.article['title'].toString()
                                                                                      }, "shared_article");
                                                                                    },
                                                                                    child: context.watch<HomeProvider>().isPdfSending
                                                                                        ? const SizedBox(height: 14, width: 14, child: AppLoadingScreen())
                                                                                        : SvgPicture.asset(
                                                                                            "assets/svg/share.svg",
                                                                                            height: 16,
                                                                                            width: 16,
                                                                                            color: Color(0xFFED1C24),
                                                                                          ),
                                                                                  ),
                                                                                  const SizedBox(width: 8),

                                                                                  /// Refresh Icon - Size 18
                                                                                  Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                                                                    return InkWell(
                                                                                      onTap: () async {
                                                                                        log("Refresh");
                                                                                        EventRepo().addEvent({
                                                                                          "refresh": true,
                                                                                          "createAt": DateTime.now().toString()
                                                                                        }, "reload_article");
                                                                                        homeProvide.isReloadData();
                                                                                        if (homeProvide.isAiTagDataLoaded) {
                                                                                          homeProvide.getAllPostsByAiId(homeProvide.selectedTagId.toString());
                                                                                          homeProvide.isReloadFalse();
                                                                                        } else {
                                                                                          homeProvide.getAllPostList = [];
                                                                                          homeProvide.getAllPost();
                                                                                        }
                                                                                      },
                                                                                      child: homeProvide.isReload
                                                                                          ? const SizedBox(height: 18, width: 18, child: AppLoadingScreen())
                                                                                          : SvgPicture.asset(
                                                                                              "assets/svg/new_refresh.svg",
                                                                                              height: 16,
                                                                                              width: 16,
                                                                                              color: Color(0xFFED1C24),
                                                                                            ),
                                                                                    );
                                                                                  }),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      height(
                                                                          height:
                                                                              0),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child: widget.article['subType'] ==
                                                                                "BulletPost"
                                                                            ? Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty)
                                                                                      ? Text(widget.article['content'],
                                                                                          style: homeScreenFontStyle(
                                                                                            color: AppColors.textColor,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontSize: 16.sp,
                                                                                          ))
                                                                                      : const SizedBox.shrink(),
                                                                                  if (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty) height(height: 8),
                                                                                  Expanded(
                                                                                    child: ListView(
                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                      children: widget.article['bulletPoints'].map<Widget>((item) {
                                                                                        return Row(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              "● ",
                                                                                              style: TextStyle(
                                                                                                fontSize: 14.sp,
                                                                                                color: AppColors.textColor.withValues(alpha: 0.8),
                                                                                                height: 1,
                                                                                              ),
                                                                                            ),
                                                                                            width(width: 5.sp),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                item,
                                                                                                strutStyle: StrutStyle(
                                                                                                  fontSize: 16.sp,
                                                                                                  height: 1,
                                                                                                ),
                                                                                                style: homeScreenFontStyle(
                                                                                                  color: AppColors.textColor.withValues(alpha: 0.8),
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontSize: 16.sp,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                      }).toList(),
                                                                                    ),
                                                                                  ),
                                                                                  RichText(
                                                                                    text: TextSpan(
                                                                                      children: [
                                                                                        const TextSpan(text: "\n\n"),
                                                                                        WidgetSpan(
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              if (widget.article['isReporter'] == 1) Icon(Icons.person, size: 14, color: Colors.grey),
                                                                                              if (widget.article['isReporter'] == 1)
                                                                                                Text(
                                                                                                  ' ${widget.article['reportedBy']} | ',
                                                                                                  style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                ),
                                                                                              Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                                                              Text(
                                                                                                " ${formatTimeDifference(widget.article['created'])}",
                                                                                                style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : RichText(
                                                                                text: TextSpan(
                                                                                  text: '',
                                                                                  children: [
                                                                                    ..._parseText(context, widget.article['content'], widget.article['links'], widget.article),
                                                                                    if (widget.article['isStickyPost'] != 1)
                                                                                      TextSpan(
                                                                                        children: [
                                                                                          const TextSpan(text: "\n"),
                                                                                          WidgetSpan(
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: [
                                                                                                if (widget.article['isReporter'] == 1) Icon(Icons.person, size: 14, color: Colors.grey),
                                                                                                if (widget.article['isReporter'] == 1)
                                                                                                  Text(
                                                                                                    ' ${widget.article['reportedBy']} | ',
                                                                                                    style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                  ),
                                                                                                Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                                                                Text(
                                                                                                  " ${formatTimeDifference(widget.article['created'])}",
                                                                                                  style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                            ),
                          ),
          );
  }

  List<TextSpan> _parseText(BuildContext context, String text, links, article) {
    RegExp linkRegExp =
        RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(linkRegExp, onMatch: (match) {
      String link = match.group(0)!;

      if (link.contains('link1') && links != null && links.isNotEmpty) {
        link = links[0]['value'].toString();
        log("jkhdsbfrefkjfksbfke  $link");
      } else if (link.contains('link2') && links != null && links.length > 1) {
        link = links[1]['value'].toString();
      } else if (link.contains('link3') && links != null && links.length > 2) {
        link = links[2]['value'].toString();
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
        style: homeScreenFontStyle(
          color: article['subType'] == "BigBlackStandard"
              ? Colors.white
              : Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            print("sbhjhfjksdfnsdknf1111 $link");
            launchURL(Uri.parse(link.toString()));
          },
      ));

      return "";
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            color: widget.article['subType'] == "BigBlackStandard"
                ? Colors.white
                : AppColors.textColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
            fontSize: 17.sp,
          )));
      return "";
    });

    return spans;
  }

  Future<void> launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.path}';
    }
  }
}

class HighlightedTitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color highlightColor;

  const HighlightedTitleText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _HighlightTextPainter(
            text: text,
            fontSize: fontSize,
            highlightColor: highlightColor,
            maxWidth: constraints.maxWidth,
          ),
          size: _getSize(constraints.maxWidth),
        );
      },
    );
  }

  Size _getSize(double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    return tp.size;
  }
}

class _HighlightTextPainter extends CustomPainter {
  final String text;
  final double fontSize;
  final Color highlightColor;
  final double maxWidth;

  double _hPad = 6;
  double _vPad = 0;

  _HighlightTextPainter({
    required this.text,
    required this.fontSize,
    required this.highlightColor,
    required this.maxWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.5,
    );

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);

    final paint = Paint()..color = highlightColor;
    final lines = tp.computeLineMetrics();

    for (final line in lines) {
      final rect = Rect.fromLTWH(
        line.left - _hPad,
        line.baseline - line.ascent - _vPad,
        line.width + (_hPad * 2),
        line.ascent + line.descent + (_vPad * 2),
      );
      // Draw rounded rectangle for cleaner look
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }

    // Draw text on top of highlights
    tp.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _HighlightTextPainter old) =>
      old.text != text ||
      old.highlightColor != highlightColor ||
      old.fontSize != fontSize;
}
