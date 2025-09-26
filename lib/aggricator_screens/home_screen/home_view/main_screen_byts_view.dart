import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_support_widgets/image_preview.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_player.dart';
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

import '../../../utils/image_view_ads.dart';
import '../../../utils/keep_alive_page.dart';
import '../../ad_manager_screen/ad_screen/android_ads_view.dart';
import '../../auth_screens/authentication_provider/authentication_provider.dart';
import '../../../utils/botton_actions.dart';
import '../../events_data/event_repo.dart';
import '../../../utils/in_app_web_view.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../../utils/date_format.dart';
import '../../polls_screens/polls_view/polls_screen.dart';
import '../../rating_screen/rating_view/movie_reviews.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../../video_image_screen/gallery_screen.dart';
import '../../video_image_screen/video_preview.dart';
import '../home_support_widgets/full_standed_video_view.dart';
import '../home_provider/home_provider.dart';

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
  Widget build(BuildContext context) {
    return (widget.index + 2 > context.read<HomeProvider>().getAllPostList.length && context.read<HomeProvider>().isAiTagDataLoaded)
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
        : SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: (widget.article['type'].toString() == "Standard" && widget.article['subType'].toString().toLowerCase() == "polls")
                ? PollScreenDesign(
                    artical: widget.article,
                    index: widget.index,
                  )
                : (widget.article['type'].toString() == "Standard" && widget.article['subType'].toString().toLowerCase() == "reviews")
                    ? MovieRatings(
                        article: widget.article,
                      )
                    : InkWell(
                        onTap: () {
                          context.read<HomeProvider>().pageChange(isValue: !context.read<HomeProvider>().isBottomEnable);
                        },
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
                                  ? AndroidAdsView(article: widget.article, index: widget.index,)
                                  : widget.article['type'] == "Reel"
                                      ? FullStandardVideoView(
                                          rellData: widget.article,
                                        )
                                      : (widget.article['type'] == "Image" && widget.article['subType'] != "ImageAd")
                                          ? Stack(
                                              children: [
                                                Image.network(
                                                  widget.article['image_url'] ?? "",
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.height,
                                                  fit: BoxFit.fill,
                                                ),
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
                                                                    onTap: () async {
                                                                      log("Like");
                                                                      settingsProvider.isLikePost(widget.article);
                                                                      EventRepo().addEvent({
                                                                        "like": !settingsProvider.isLikeList.contains(widget.article['id'].toString()),
                                                                        "postId": widget.article['id'].toString() ?? '000',
                                                                        "createAt": DateTime.now().toString(),
                                                                        "postTitle": widget.article['title'].toString()
                                                                      }, "liked_article");

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
                                                                      showComments(context, widget.article['id'], widget.article['title']);
                                                                    }
                                                                  },
                                                                ),
                                                                Spacer(),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    SharedPreferences sp = await SharedPreferences.getInstance();
                                                                    String? userId = sp.getString("userId");
                                                                    EventRepo().addEvent({
                                                                      "share": "news",
                                                                      "postId": widget.article['id'].toString(),
                                                                      "createAt": DateTime.now().toString(),
                                                                      "postTitle": widget.article['title'].toString()
                                                                    }, "shared_article");

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
                                                                    EventRepo().addEvent({
                                                                      "share": "news",
                                                                      "postId": widget.article['id'].toString(),
                                                                      "createAt": DateTime.now().toString(),
                                                                      "postTitle": widget.article['title'].toString()
                                                                    }, "shared_article");
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
                                                                          EventRepo().addEvent({"refresh": false, "createAt": DateTime.now().toString()}, "reload_article");
                                                                          homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
                                                                            (value) {
                                                                              homeProvide.isReloadFalse();
                                                                            },
                                                                          );
                                                                        } else {
                                                                          homeProvide.getAllPostList = [];
                                                                          homeProvide.getAllPost();
                                                                          EventRepo().addEvent({"refresh": true, "createAt": DateTime.now().toString()}, "reload_article");
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
                                          : (widget.article['type'] == "Image" && widget.article['subType'] == "ImageAd")
                                              ? InkWell(
                                                  onTap: () async {
                                                    SharedPreferences sp = await SharedPreferences.getInstance();
                                                    bool isLogin = sp.getString("loginType") != "login" ? true : false;
                                                    if (isLogin) {
                                                      CustomToast.showErrorToast(msg: "Your a guest user, Please Login to Join Contest");
                                                    } else {
                                                      if (widget.article['postUrl'] == "" || widget.article['postUrl'] == null) {
                                                      } else {
                                                        context
                                                            .read<HomeProvider>()
                                                            .sendAdsDataSend(widget.article['id'], widget.article['title'], widget.article['image_url'], false, widget.article['postUrl']);
                                                      }
                                                    }
                                                  },
                                                  child: widget.article['image_url'].length == 1
                                                      ? CachedNetworkImage(
                                                          imageUrl: widget.article['image_url'][0] ?? "",
                                                          width: MediaQuery.of(context).size.width,
                                                          height: MediaQuery.of(context).size.height,
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
                                                        )
                                                      : ImagePostSlider(
                                                          imageUrl: widget.article['image_url'],
                                                        ))
                                              : widget.article['type'] == "Gallery"
                                                  ? KeepAlivePage(
                                                      keepAlive: true,
                                                      child: Stack(
                                                        children: [
                                                          FullPageCarousel(
                                                            isHome: true,
                                                            imageUrls: widget.article['gallery'] ?? [],
                                                            postDetails: widget.article,
                                                          ),

                                                          // Bottom action bar
                                                        ],
                                                      ),
                                                    )
                                                  : Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  widget.article['subType'] == "BigBlackStandard" ? MediaQuery.of(context).size.height * .52 : MediaQuery.of(context).size.height * .33,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(16.r),
                                                                  topLeft: Radius.circular(16.r),
                                                                ),
                                                                color: Colors.black,
                                                              ),
                                                              child: widget.article['type'] == "Video" && widget.article['video_platform'] == "Twitter"
                                                                  ? CustomVideoPlayer(
                                                                      url: widget.article['video_url'],
                                                                      imageUrl: widget.article['image_url'],
                                                                    )
                                                                  : widget.article['type'] == "Video"
                                                                      ? SizedBox(
                                                                          height: MediaQuery.of(context).size.height * .33,
                                                                          width: MediaQuery.of(context).size.width,
                                                                          child: VideoPreview(
                                                                            imageUrl: widget.article['image_url'],
                                                                            url: widget.article['video_url'] ?? "",
                                                                            isFoldable: false,
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
                                                                                imageUrl: widget.article['image_url'] ?? "hello",
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
                                                            // Positioned(
                                                            //   top: 12,
                                                            //   right: 14,
                                                            //   child: Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                                            //     return InkWell(
                                                            //       onTap: () async {
                                                            //         log("Refresh");
                                                            //         EventRepo().addEvent({"refresh": true, "createAt": DateTime.now().toString()}, "reload_article");
                                                            //         homeProvide.isReloadData();
                                                            //         if (homeProvide.isAiTagDataLoaded) {
                                                            //           homeProvide.getAllPostsByAiId(homeProvide.selectedTagId.toString());
                                                            //         } else {
                                                            //           homeProvide.getAllPostList = [];
                                                            //           homeProvide.getAllPost();
                                                            //           homeProvide.pageChange(isValue: true);
                                                            //         }
                                                            //       },
                                                            //       child: Container(
                                                            //         width: 38,
                                                            //         padding: EdgeInsets.all(7),
                                                            //         decoration: BoxDecoration(
                                                            //           color: (homeProvide.isBookMark.contains(widget.article['id'].toString()) || widget.article['isBookmarked'] == 1)
                                                            //               ? AppColors.appButtonColor
                                                            //               : Colors.black54,
                                                            //           shape: BoxShape.circle,
                                                            //         ),
                                                            //         child: SvgPicture.asset("assets/svg/new_refresh.svg",
                                                            //             height: 20, width: 20, color: widget.article['subType'] != "BigBlackStandard" ? Colors.white : Colors.grey),
                                                            //       ),
                                                            //     );
                                                            //   }),
                                                            // ),
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
                                                          ],
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            // height: widget.article['subType'] == "BigBlackStandard"
                                                            //     ? MediaQuery.of(context).size.height * .3
                                                            //     : widget.article['type'] == "Video"
                                                            //     ? (Platform.isIOS ? MediaQuery.of(context).size.height * .48 : MediaQuery.of(context).size.height * .55)
                                                            //     : MediaQuery.of(context).size.height * .58,
                                                            width: MediaQuery.of(context).size.width,
                                                            color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height: 20,
                                                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                          decoration: BoxDecoration(color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white
                                                                              // borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                          child: Center(
                                                                            child: Text.rich(
                                                                              TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: "Chota ",
                                                                                    style: fontStyle(
                                                                                      fontSize: Platform.isIOS ? 16 : 16,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: widget.article['subType'] != "BigBlackStandard" ? Colors.black : Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: "News",
                                                                                    style: fontStyle(
                                                                                      fontSize: Platform.isIOS ? 16 : 16,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xff00A8FF),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Spacer(),
                                                                        Container(
                                                                          height: 50,
                                                                          width: 120,
                                                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                          decoration: BoxDecoration(
                                                                            color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                                                                            borderRadius: BorderRadius.circular(20),
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
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
                                                                                  child: SizedBox(
                                                                                    width: 24,
                                                                                    child: SvgPicture.asset(
                                                                                        settingsProvider.isLikeList.contains(widget.article['id'].toString())
                                                                                            ? "assets/svg/like_full.svg"
                                                                                            : "assets/svg/like.svg",
                                                                                        height: 18,
                                                                                        width: 18,
                                                                                        color: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? Colors.lightBlue : Colors.grey),
                                                                                  ),
                                                                                );
                                                                              }),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  log("Comment...");
                                                                                  if (context.mounted) {
                                                                                    context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                                                    showComments(context, widget.article['id'], widget.article['title']);
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
                                                                                  EventRepo().addEvent({
                                                                                    "share": "news",
                                                                                    "postId": widget.article['id'].toString(),
                                                                                    "createAt": DateTime.now().toString(),
                                                                                    "postTitle": widget.article['title'].toString()
                                                                                  }, "shared_article");
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
                                                                              Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                                                                return InkWell(
                                                                                  onTap: () async {
                                                                                    log("Refresh");
                                                                                    EventRepo().addEvent({"refresh": true, "createAt": DateTime.now().toString()}, "reload_article");
                                                                                    homeProvide.isReloadData();
                                                                                    // if (widget.isaiTags) {
                                                                                    //   homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
                                                                                    //         (value) {
                                                                                    //       homeProvide.isReloadFalse();
                                                                                    //     },
                                                                                    //   );
                                                                                    if (homeProvide.isAiTagDataLoaded) {
                                                                                      homeProvide.getAllPostsByAiId(homeProvide.selectedTagId.toString());
                                                                                      homeProvide.isReloadFalse();
                                                                                    } else {
                                                                                      homeProvide.getAllPostList = [];
                                                                                      homeProvide.getAllPost();
                                                                                    }
                                                                                  },
                                                                                  child: homeProvide.isReload
                                                                                      ? const SizedBox(height: 20, width: 20, child: AppLoadingScreen())
                                                                                      : SvgPicture.asset("assets/svg/new_refresh.svg", height: 20, width: 20, color: Colors.grey),
                                                                                );
                                                                              })
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  height(height: 0),
                                                                  Text(widget.article['title'] ?? "No Title",
                                                                      style: homeScreenFontStyle(
                                                                          color: widget.article['subType'] != "BigBlackStandard" ? AppColors.textColor : AppColors.cardBackgroundColor,
                                                                          fontSize: 18.sp,
                                                                          fontWeight: FontWeight.bold)),
                                                                  height(height: 2),
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
                                                                              if (widget.article['content'] != "" &&
                                                                                  widget.article['content'] != null &&
                                                                                  widget.article['content'].toString().isNotEmpty)
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
                                                                                            color: AppColors.textColor.withOpacity(0.5),
                                                                                            height: 1, // Ensures proper line height
                                                                                          ),
                                                                                        ),
                                                                                        width(width: 5.sp),
                                                                                        // Space between bullet & text
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            item,
                                                                                            strutStyle: StrutStyle(
                                                                                              fontSize: 16.sp,
                                                                                              height: 1, // Ensures consistent line height
                                                                                            ),
                                                                                            style: homeScreenFontStyle(
                                                                                              color: AppColors.textColor.withOpacity(0.5),
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
                                                                                      TextSpan(text: "\n"),
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
                                                                  // if (widget.article['subType'] != "BigBlackStandard" && widget.index != 0 && widget.article['type'] != "GoogleAds") Banner300x50Size()
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

            launchURL(Uri.parse(link.toString()));
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
