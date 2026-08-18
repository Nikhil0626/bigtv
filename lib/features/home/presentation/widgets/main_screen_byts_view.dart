import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

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

import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chotanews/utils/image_post_slider.dart';
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
            height: double.infinity,
            width: double.infinity,
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
                        : GestureDetector(
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
                                  : widget.article['type'] == "Reel"
                                          ? FullStandardVideoView(
                                              reelData: widget.article,
                                            )
                                          : (widget.article['type'] == "Image" && widget.article['subType'] != "ImageAd")
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
                                                  ? InkWell(
                                                      onTap: () async {
                                                        if (widget.article['postUrl'] != null && widget.article['postUrl'].toString().isNotEmpty) {
                                                          final url = widget.article['postUrl'].toString();
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => InAppWebViewScreen(webUrl: url, title: "")));
                                                        }
                                                        
                                                        SharedPreferences sp = await SharedPreferences.getInstance();
                                                        bool isLogin = sp.getString("loginType") != "login" ? true : false;
                                                        if (!isLogin) {
                                                          context.read<HomeProvider>().sendAdsDataSend(
                                                              widget.article['id'],
                                                              widget.article['title'],
                                                              widget.article['image_url'],
                                                              false,
                                                              widget.article['postUrl']);
                                                        }
                                                      },
                                                      child: (widget.article['image_url'] is List)
                                                          ? (widget.article['image_url'].length == 1
                                                              ? CachedNetworkImage(
                                                                  imageUrl: _getImageUrl(widget.article['image_url'][0]),
                                                                  width: MediaQuery.of(context).size.width,
                                                                  height: MediaQuery.of(context).size.height,
                                                                  fit: BoxFit.fill,
                                                                  placeholder: (context, url) => Container(
                                                                    color: AppColors.borderColor.withValues(alpha: .2),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Center(
                                                                    child: Icon(
                                                                      Icons.image,
                                                                      size: 100,
                                                                      color: Colors.grey.shade300,
                                                                    ),
                                                                  ),
                                                                )
                                                              : ImagePostSlider(
                                                                  imageUrl: widget.article['image_url'],
                                                                ))
                                                          : CachedNetworkImage(
                                                              imageUrl: _getImageUrl(widget.article['image_url']),
                                                              width: MediaQuery.of(context).size.width,
                                                              height: MediaQuery.of(context).size.height,
                                                              fit: BoxFit.fill,
                                                              placeholder: (context, url) => Container(
                                                                color: AppColors.borderColor.withValues(alpha: .2),
                                                              ),
                                                              errorWidget: (context, url, error) => Center(
                                                                child: Icon(
                                                                  Icons.image,
                                                                  size: 100,
                                                                  color: Colors.grey.shade300,
                                                                ),
                                                              ),
                                                            ))
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
                                                            LandscapeFlexible(
                                                              child: Stack(
                                                                children: [
                                                                  /// IMAGE / VIDEO CONTAINER
                                                                  Container(
                                                                  height: MediaQuery.of(context).orientation == Orientation.landscape 
                                                                      ? double.infinity
                                                                      : (widget.article['subType'] ==
                                                                          "BigBlackStandard"
                                                                      ? MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .52
                                                                      : MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .33),
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
                                                                              height: MediaQuery.of(context).orientation == Orientation.landscape
                                                                                  ? double.infinity
                                                                                  : MediaQuery.of(context).size.height * .33,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              child: VideoPreview(
                                                                                imageUrl: _getImageUrl(widget.article['image_url']),
                                                                                url: widget.article['video_url'],
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

                                                                if (MediaQuery.of(context).orientation != Orientation.landscape)
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    child: Image.asset(
                                                                      "assets/images/BigTvPostLogo.png",
                                                                      width: 120,
                                                                      height: 40,
                                                                      fit: BoxFit.contain,
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
                                                                  bottom: 6,
                                                                  left: 12,
                                                                  right: 12,
                                                                  child: widget.article[
                                                                              'type'] ==
                                                                          "Video"
                                                                      ? SizedBox
                                                                          .shrink()
                                                                      : SizedBox.shrink(),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (MediaQuery.of(context).orientation != Orientation.landscape) ...[
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
                                                                      /// Title only (Action Icons moved below)
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                                                                      height(
                                                                          height:
                                                                              0),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      widget.article['subType'] ==
                                                                              "BulletPost"
                                                                          ? Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty)
                                                                                      ? (() {
                                                                                          String content = widget.article['content'].toString();
                                                                                          List<String> words = content.split(RegExp(r'\s+'));
                                                                                          bool isOverflow = words.length > 50;
                                                                                          String displayContent = isOverflow ? words.take(50).join(' ') + "..." : content;
                                                                                          
                                                                                          return RichText(
                                                                                            text: TextSpan(
                                                                                              text: displayContent,
                                                                                              style: homeScreenFontStyle(
                                                                                                color: AppColors.textColor,
                                                                                                fontWeight: FontWeight.w600,
                                                                                                fontSize: 16.sp,
                                                                                              ),
                                                                                              children: [
                                                                                                if (isOverflow)
                                                                                                  TextSpan(
                                                                                                    text: " Read more",
                                                                                                    style: homeScreenFontStyle(
                                                                                                      color: Colors.blue,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontSize: 16.sp,
                                                                                                    ),
                                                                                                    recognizer: TapGestureRecognizer()
                                                                                                      ..onTap = () {
                                                                                                        _showBottomSheet(context, widget.article);
                                                                                                      },
                                                                                                  ),
                                                                                              ],
                                                                                            ),
                                                                                          );
                                                                                        })()
                                                                                      : const SizedBox.shrink(),
                                                                                  if (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty) height(height: 8),
                                                                                  ListView(
                                                                                    shrinkWrap: true,
                                                                                    padding: EdgeInsets.zero,
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
                                                                                ],
                                                                              )
                                                                            : RichText(
                                                                                text: TextSpan(
                                                                                  text: '',
                                                                                  children: [
                                                                                    ...(() {
                                                                                      String content = widget.article['content']?.toString() ?? "";
                                                                                      List<String> words = content.split(RegExp(r'\s+'));
                                                                                      bool isOverflow = words.length > 50;
                                                                                      String displayContent = isOverflow ? words.take(50).join(' ') + "..." : content;
                                                                                      
                                                                                      List<TextSpan> spans = _parseText(context, displayContent, widget.article['links'], widget.article);
                                                                                      if (isOverflow) {
                                                                                        spans.add(
                                                                                          TextSpan(
                                                                                            text: " Read more",
                                                                                            style: homeScreenFontStyle(
                                                                                              color: Colors.blue,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontSize: 16.sp,
                                                                                            ),
                                                                                            recognizer: TapGestureRecognizer()
                                                                                              ..onTap = () {
                                                                                                _showBottomSheet(context, widget.article);
                                                                                              },
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      return spans;
                                                                                    })(),

                                                                                  ],
                                                                                ),
                                                                              ),
                                                                      if (widget.article['type'] != 'ImageAd' && widget.article['subType'] != 'ImageAd')
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              if (widget.article['isStickyPost'] != 1)
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    if (widget.article['isReporter'] == 1) const Icon(Icons.person, size: 14, color: Colors.grey),
                                                                                    if (widget.article['isReporter'] == 1)
                                                                                      Text(
                                                                                        ' ${widget.article['reportedBy']} | ',
                                                                                        style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                      ),
                                                                                    if (widget.article['isWebPost'] == true)
                                                                                      InkWell(
                                                                                        onTap: () async {
                                                                                          if (widget.article['postUrl'] != null && widget.article['postUrl'].toString().isNotEmpty) {
                                                                                            await launchUrl(Uri.parse(widget.article['postUrl']));
                                                                                          }
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(right: 8.0),
                                                                                          child: Text(
                                                                                            "BIGTV.COM",
                                                                                            style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.red),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                                                    Text(
                                                                                      " ${formatTimeDifference(widget.article['created'])}",
                                                                                      style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              else
                                                                                const SizedBox.shrink(),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                /// Like Icon
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
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            SvgPicture.asset(
                                                                                              settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                                                              height: 22, width: 22,
                                                                                              color: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? AppColorTokens.primaryRed : AppColorTokens.primaryRed,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                                  const SizedBox(width: 16),
                                                                                /// Comment Icon
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    log("Comment...");
                                                                                    if (context.mounted) {
                                                                                      context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                                                      showComments(context, widget.article['id'], widget.article['title']);
                                                                                    }
                                                                                  },
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          SvgPicture.asset("assets/svg/new_comment.svg", height: 22, width: 22, color: const Color(0xFFED1C24)),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                  const SizedBox(width: 16),
                                                                                /// Reload Icon
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
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            homeProvide.isReload
                                                                                                ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                                                                : SvgPicture.asset("assets/svg/new_refresh.svg", height: 22, width: 22, color: const Color(0xFFED1C24)),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                                  const SizedBox(width: 16),
                                                                                /// WhatsApp Icon
                                                                                InkWell(
                                                                                  onTap: () async {
                                                                                    try {
                                                                                      final String title = widget.article['title']?.toString() ?? "";
                                                                                      final String link = Platform.isIOS ? (widget.article['linkURLIos']?.toString() ?? "") : (widget.article['linkURLAndroid']?.toString() ?? "");
                                                                                      final String postUrl = widget.article['postUrl']?.toString() ?? "";
                                                                                      final String shareText = "$title\n${postUrl.isNotEmpty ? postUrl + '\n' : ''}$link";
                                                                                      final imageBytes = await adsScreenshotController.capture(delay: const Duration(milliseconds: 10));
                                                                                      if (imageBytes != null) {
                                                                                        final directory = await getTemporaryDirectory();
                                                                                        final imagePath = await File(directory.path + "/screenshot_" + DateTime.now().millisecondsSinceEpoch.toString() + ".png").create();
                                                                                        await imagePath.writeAsBytes(imageBytes);
                                                                                        try {
                                                                                          if (Platform.isIOS) {
                                                                                            final Size size = MediaQuery.of(context).size;
                                                                                            await Share.shareXFiles([XFile(imagePath.path)], text: shareText, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
                                                                                          } else {
                                                                                            const platform = MethodChannel('com.chotanews/whatsapp');
                                                                                            await platform.invokeMethod('shareToWhatsApp', {'imagePath': imagePath.path, 'text': shareText});
                                                                                          }
                                                                                        } catch (e) {
                                                                                          if (e is PlatformException && e.code == "APP_NOT_INSTALLED") {
                                                                                            CustomToast.showInfoToast(msg: "WhatsApp is not installed");
                                                                                          } else {
                                                                                            final Size size = MediaQuery.of(context).size;
                                                                                            await Share.shareXFiles([XFile(imagePath.path)], text: shareText, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        final url = "whatsapp://send?text=" + Uri.encodeComponent(shareText);
                                                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                                                          await launchUrl(Uri.parse(url));
                                                                                        } else {
                                                                                          CustomToast.showInfoToast(msg: "WhatsApp is not installed");
                                                                                        }
                                                                                      }
                                                                                    } catch (e) {
                                                                                      debugPrint("WhatsApp share error: " + e.toString());
                                                                                    }
                                                                                  },
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Image.asset("assets/images/WhatsApp_icon.png", height: 30, width: 30),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            ],
                                                          ],
                                                        ),
                            ),
                          ),
          );
  }

  void _showBottomSheet(BuildContext context, dynamic article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/images/BigTvPostLogo.png",
                          height: 30.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            "News Details",
                            style: homeScreenFontStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['image_url'] != null && article['image_url'].toString().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagePreview(
                                      imageUrl: _getImageUrl(article['image_url']),
                                      title: article['title'] ?? "",
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: _getImageUrl(article['image_url']),
                              width: double.infinity,
                              height: 250.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.borderColor.withValues(alpha: .2),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  Icons.image,
                                  size: 100,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          article['title'] ?? "",
                          style: homeScreenFontStyle(
                            color: AppColorTokens.primaryRed,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        RichText(
                          text: TextSpan(
                            children: _parseText(
                              context, 
                              article['content'] ?? "", 
                              article['links'], 
                              {'subType': 'Standard'}
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

class LandscapeFlexible extends StatelessWidget {
  final Widget child;
  const LandscapeFlexible({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: MediaQuery.of(context).orientation == Orientation.landscape ? FlexFit.tight : FlexFit.loose,
      child: child,
    );
  }
}

