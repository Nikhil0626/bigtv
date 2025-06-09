import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/banner_300x50_size.dart';
import 'package:chotanews/aggricator_screens/image_preview.dart';
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

import '../auth_screens/authentication_provider/authentication_provider.dart';
import '../botton_actions.dart';
import '../in_app_web_view.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../ad_manager_screen/test_ads.dart';
import '../reels_screens/reels_view/reels_screen_preview.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../video_image_view/gallery_screen.dart';
import '../video_image_view/video_preview.dart';
import 'full_standed_video_view.dart';
import 'home_provider/home_provider.dart';

class MainScreenBytView extends StatefulWidget {
  final article;
  final PageController;
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
    this.PageController,
    this.length = 0,
    this.index = 0,
  });

  @override
  State<MainScreenBytView> createState() => _MainScreenBytViewState();
}

class _MainScreenBytViewState extends State<MainScreenBytView> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final content = widget.article['content'] ?? '';
    final bool showIcon = content.length < 360;
    return InkWell(
      onTap: () {
        context.read<HomeProvider>().pageChange(isValue: !context.read<HomeProvider>().isBottomEnable);
      },
      child: (widget.index + 2 > context.read<HomeProvider>().getAllPostList.length && context.read<HomeProvider>().isAiTagDataLoaded)
          ? Card(
              elevation: 4,
              color: Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/svg/done.json", height: 200, width: 200),
                      height(
                        height: 10,
                      ),
                      Text(
                        "Your have Read the News",
                        style: homeScreenFontStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      height(
                        height: 20,
                      ),
                      Text(
                        "${context.read<HomeProvider>().getAllPostList.length}/${context.read<HomeProvider>().getAllPostList.length} Completed",
                        style: homeScreenFontStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Screenshot(
                controller: adsScreenshotController,
                child: widget.article['type'].toString() == "WebUrl"
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InAppWebViewScreen(
                          webUrl: context.read<HomeProvider>().webUrl.toString(),
                          title: '',
                        ),
                      )
                    : widget.article['type'] == "GoogleAds"
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FullScreenNativeAd(
                              article: widget.article,
                            ),
                          )
                        :widget.article['type'] == "Reel"
                        ? FullStandardVideoView( rellData:  widget.article,)
                        : widget.article['type'] == "Image"
                            ? Stack(
                                children: [
                                  Image.network(
                                    widget.article['image_url'] ?? "",
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                  ),
                                  if (widget.article['subType'] != "ImageAd")
                                    Positioned(
                                      bottom: 0,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 6),
                                        child: Container(
                                          height: 45.sp,
                                          color: Colors.transparent,
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                                      return BottomActions(
                                                        postType: widget.article['subType'] ?? "",
                                                        icon: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                        label: 'లైక్',
                                                        // isLike: flipProvider.isLikeList.contains(widget.article.id.toString()),
                                                        isLike: settingsProvider.isLikeList.contains(widget.article['id'].toString()),
                                                        onTap: () {
                                                          log("Like");
                                                          settingsProvider.isLikePost(widget.article);

                                                          // settingsProvider.isLikePost(widget.article);
                                                        },
                                                      );
                                                    }),
                                                    width(width: 6),
                                                    BottomActions(
                                                      postType: widget.article['subType'].toString() ?? "",
                                                      icon: "assets/svg/new_comment.svg",
                                                      label: 'కామెంట్',
                                                      onTap: () async {
                                                        if (context.mounted) {
                                                          context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                          showComments(context, widget.article['id']);
                                                        }
                                                      },
                                                    ),
                                                    Spacer(),
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

                                                              Share.shareXFiles([XFile(imageFile.path)], text: widget.article['linkURLAndroid'].toString());
                                                            } else {
                                                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                            }
                                                          } catch (e) {
                                                            CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                          }
                                                        } else if (widget.article['type'] == "Gallery") {
                                                          createAndSharePdfs(context, widget.article);
                                                        }
                                                      },
                                                      child: isSending
                                                          ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                          : SvgPicture.asset(
                                                              "assets/svg/share.svg",
                                                              height: 20,
                                                              width: 20,
                                                              color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
                                                            ),
                                                    ),
                                                    width(width: 20),
                                                    Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                                      return SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            log("Refresh");

                                                            homeProvide.isReloadData();
                                                            if (widget.isaiTags) {
                                                              homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
                                                                (value) {
                                                                  homeProvide.isReloadFalse();
                                                                },
                                                              );
                                                            } else {
                                                              homeProvide.getAllPostList = [];
                                                              homeProvide.getAllPost();
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
                            : widget.article['type'] == "Gallery"
                                ? Stack(
                                    children: [
                                      // Image carousel
                                      FullPageCarousel(
                                        isHome: true,
                                        imageUrls: widget.article['gallery'] ?? [],
                                        postDetails: widget.article,
                                      ),

                                      // Bottom action bar
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      Container(
                                        height: widget.article['subType'] == "BigBlackStandard" ? MediaQuery.of(context).size.height * .65 : MediaQuery.of(context).size.height * .35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16.r),
                                            topLeft: Radius.circular(16.r),
                                          ),
                                          color: Colors.black,
                                        ),
                                        child: widget.article['type'] == "Video"
                                            ? SizedBox(
                                                height: MediaQuery.of(context).size.height * .31,
                                                width: MediaQuery.of(context).size.width,
                                                child: Align(
                                                  alignment: Alignment.topCenter,
                                                  child: VideoPreview(
                                                    imageUrl: widget.article['image_url'],
                                                    url: widget.article['video_url'] ?? "",
                                                    isFoldable: false,
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ImagePreview(
                                                          imageUrl: widget.article['image_url'],
                                                          title: widget.article['title'],
                                                        ),
                                                      ));
                                                },
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.height * .35,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(16.r),
                                                      topLeft: Radius.circular(16.r),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: widget.article['image_url'] ?? "fgyhuiiuh",
                                                      height: MediaQuery.of(context).size.height * (widget.article['subType'] == "BigBlackStandard" ? .65 : .4),
                                                      width: MediaQuery.of(context).size.width,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context, url) => Container(
                                                        color: AppColors.borderColor.withOpacity(.2),
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
                                              ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 14,
                                        child: Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                          return InkWell(
                                            onTap: () {
                                              log("Refresh");

                                              homeProvide.isReloadData();
                                              if (widget.isaiTags) {
                                                homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
                                                  (value) {
                                                    homeProvide.isReloadFalse();
                                                  },
                                                );
                                              } else {
                                                homeProvide.getAllPostList = [];
                                                homeProvide.getAllPost();
                                                homeProvide.pageChange(isValue: true);
                                              }
                                            },
                                            child: Container(
                                              width: 38,
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: (homeProvide.isBookMark.contains(widget.article['id'].toString()) || widget.article['isBookmarked'] == 1)
                                                    ? AppColors.appButtonColor
                                                    : Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: SvgPicture.asset("assets/svg/new_refresh.svg",
                                                  height: 20, width: 20, color: widget.article['subType'] != "BigBlackStandard" ? Colors.white : Colors.grey),
                                            ),
                                          );
                                        }),
                                      ),
                                      if (context.watch<HomeProvider>().isAiTagDataLoaded)
                                        Positioned(
                                          top: 10,
                                          left: 14,
                                          child: GestureDetector(
                                            onTap: () {
                                              context.read<HomeProvider>().setSelectedTagId(0);
                                              context.read<HomeProvider>().aiTagDataLoaded(false);
                                              context.read<HomeProvider>().pageChange(isValue: true);
                                              context.read<HomeProvider>().getAllPost();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          height: widget.article['subType'] == "BigBlackStandard"
                                              ? MediaQuery.of(context).size.height * .3
                                              : (widget.article['type'] == "Video")
                                                  ? MediaQuery.of(context).size.height * .55
                                                  : MediaQuery.of(context).size.height * .58,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: widget.article['subType'] == "BigBlackStandard" ? AppColors.textColor : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10.sp),
                                              topLeft: Radius.circular(10.sp),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                height(height: 8),
                                                Text(widget.article['title'] ?? "No Title",
                                                    style: homeScreenFontStyle(
                                                        color: widget.article['subType'] != "BigBlackStandard" ? AppColors.textColor : AppColors.cardBackgroundColor,
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold)),
                                                height(height: 8),
                                                Expanded(
                                                  child: widget.article['subType'] == "BulletPost"
                                                      ? Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty)
                                                                ? Text(widget.article['content'],
                                                                    style: homeScreenFontStyle(
                                                                      color: AppColors.textColor,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 16.sp,
                                                                    ))
                                                                : const SizedBox.shrink(),
                                                            if (widget.article['content'] != "" && widget.article['content'] != null && widget.article['content'].toString().isNotEmpty)
                                                              height(height: 8),
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
                                                                          color: AppColors.textColor.withOpacity(0.5) ,
                                                                          height: 1, // Ensures proper line height
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 5.sp),
                                                                      // Space between bullet & text
                                                                      Expanded(
                                                                        child: Text(
                                                                          item,
                                                                          strutStyle: StrutStyle(
                                                                            fontSize: 16.sp,
                                                                            height: 1, // Ensures consistent line height
                                                                          ),
                                                                          style: homeScreenFontStyle(
                                                                            color:  AppColors.textColor.withOpacity(0.5) ,
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: 16.sp,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }).toList(), // Ensure it is converted to List<Widget>
                                                              ),
                                                            ),
                                                            RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(text: "\n\n"),
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
                                                            // if (widget.article['subType'] != "BigBlackStandard") Banner300x50Size()
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
                                                                    TextSpan(text: "\n\n"),
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
                                                // if (widget.article['subType'] != "BigBlackStandard") Banner300x50Size()
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        bottom: widget.article['subType'] == "BigBlackStandard"
                                            ? MediaQuery.of(context).size.height * .30 - 15
                                            : (widget.article['type'] == "Video")
                                                ? MediaQuery.of(context).size.height * .55 - 15
                                                : MediaQuery.of(context).size.height * .58 - 15,
                                        child: Container(
                                          height: 30,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : AppColors.cardBackgroundColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Chota ",
                                                    style: fontStyle(
                                                      fontSize: Platform.isIOS ? 16 : 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "News",
                                                    style: fontStyle(
                                                      fontSize: Platform.isIOS ? 16 : 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xff00A8FF),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        bottom: widget.article['subType'] == "BigBlackStandard"
                                            ? MediaQuery.of(context).size.height * .30 - 15
                                            : (widget.article['type'] == "Video")
                                                ? MediaQuery.of(context).size.height * .55 - 15
                                                : MediaQuery.of(context).size.height * .58 - 15,
                                        child: Container(
                                          height: 30,
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : AppColors.cardBackgroundColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                                return InkWell(
                                                  onTap: () {
                                                    log("Like");
                                                    settingsProvider.isLikePost(widget.article);
                                                  },
                                                  child: SizedBox(
                                                    width: 24,
                                                    child: SvgPicture.asset(settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                        height: 18, width: 18, color: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? Colors.lightBlue : Colors.grey),
                                                  ),
                                                );
                                              }),
                                              InkWell(
                                                onTap: () {
                                                  log("Comment...");
                                                  if (context.mounted) {
                                                    context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                    showComments(context, widget.article['id']);
                                                  }
                                                },
                                                child: SizedBox(
                                                  width: 24,
                                                  child: SvgPicture.asset("assets/svg/new_comment.svg", height: 20, width: 20, color: Colors.grey),
                                                ),
                                              ),
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

                                                        Share.shareXFiles([XFile(imageFile.path)], text: widget.article['linkURLAndroid'].toString());
                                                      } else {
                                                        CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                      }
                                                    } catch (e) {
                                                      CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                    }
                                                  } else if (widget.article['type'] == "Gallery") {
                                                    createAndSharePdfs(context, widget.article);
                                                  }
                                                },
                                                child: isSending
                                                    ? const SizedBox(height: 20, width: 20, child: AppLoadingScreen())
                                                    : SizedBox(
                                                        width: 24,
                                                        child: SvgPicture.asset(
                                                          "assets/svg/share.svg",
                                                          height: 18,
                                                          width: 18,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
              ),
            ),
    );
  }

  bool isSending = false;

  Future<void> createAndSharePdfs(BuildContext context, article) async {
    isSending = true;
    setState(() {});

    List imageData = article['gallery'];
    try {
      final pdf = pw.Document();

      for (var item in imageData) {
        String imageUrl = item['Url'].toString() ?? '';
        log("Pdf $imageUrl");
        if (imageUrl.isNotEmpty) {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            final Uint8List imageData = response.bodyBytes;
            final pdfImage = pw.MemoryImage(imageData);

            pdf.addPage(
              pw.Page(
                // pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.FullPage(
                    ignoreMargins: true, // Ensures full coverage
                    child: pw.Image(
                      pdfImage,
                      fit: pw.BoxFit.contain, // Covers the full page
                    ),
                  );
                },
              ),
            );
          } else {
            log("Failed to load image: $imageUrl");
          }
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/${article['id']}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      log("PDF saved at: $filePath");

      await Share.shareXFiles([XFile(filePath)], text: "https://apps.signitivessoft.com/individualPage");
      isSending = false;
      setState(() {});
    } catch (e) {
      isSending = false;
      setState(() {});
      log("Error: $e");
    }
  }

  List<TextSpan> _parseText(BuildContext context, String text, links, article) {
    RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
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
          color: article['subType'] == "BigBlackStandard" ? Colors.white : Colors.blue,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            print("sbhjhfjksdfnsdknf1111 $link");

            if (link == "https://play.google.com/store/apps/details?id=com.chotanews" && Platform.isIOS) {
              print("sbhjhfjksdfnsdknf $link");
              launchURL(Uri.parse("https://apps.apple.com/in/app/chotanews-daily-telugu-news/id1631068092"));
            } else {
              launchURL(Uri.parse(link.toString()));
            }
          },
      ));

      return "";
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            color: widget.article['subType'] == "BigBlackStandard" ? AppColors.cardBackgroundColor : AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
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
