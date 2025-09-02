import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ad_manager_screen/ad_screen/banner_300x50_size.dart';
import '../ad_manager_screen/ad_screen/ios_ads_view.dart';
import '../ad_manager_screen/ad_screen/android_ads_view.dart';

import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../../utils/botton_actions.dart';
import '../events_data/event_repo.dart';
import '../home_screen/home_provider/home_provider.dart';
import '../home_screen/home_support_widgets/image_preview.dart';
import '../../utils/in_app_web_view.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import '../video_image_screen/gallery_screen.dart';
import '../video_image_screen/video_preview.dart';

class IndividualPostView1 extends StatefulWidget {
  final String postId;
  final bool isComeFrom;

  const IndividualPostView1({super.key, required this.postId, this.isComeFrom = false});

  @override
  State<IndividualPostView1> createState() => _IndividualPostView1State();
}

class _IndividualPostView1State extends State<IndividualPostView1> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    log("is come from lin----k${widget.postId}");
    getWebData();
    context.read<HomeProvider>().getIndividualPost(widget.postId, isAds: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Exit app
      },
      child: Scaffold(
        body: SafeArea(
          child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
            final article = homeProvider.getSinglePostList.isEmpty ? {} : homeProvider.getSinglePostList;
            return homeProvider.isPostLoading
                ? AppLoadingScreen()
                : homeProvider.getSinglePostList.isEmpty
                ? AppNoData()
                : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Screenshot(
                controller: adsScreenshotController,
                child: article['type'].toString() == "WebUrl"
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InAppWebViewScreen(
                    webUrl: context.read<HomeProvider>().webUrl.toString(),
                    title: '',
                  ),
                )
                    : article['type'] == "GoogleAds"
                    ? Platform.isIOS?IosAdsWidgetScreen(article: article,):Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FullScreenNativeAd(
                    article: article,
                  ),
                )
                    : article['type'] == "Image"
                    ? Stack(
                  children: [
                    Image.network(
                      article['image_url'] ?? "",
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                    if (article['subType'] != "ImageAd")
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
                                          postType: article['subType'] ?? "",
                                          icon: settingsProvider.isLikeList.contains(article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                          label: 'లైక్',
                                          isLike: settingsProvider.isLikeList.contains(article['id'].toString()),
                                          onTap: () {
                                            log("Like");
                                            settingsProvider.isLikePost(article);
                                          },
                                        );
                                      }),
                                      width(width: 6),
                                      BottomActions(
                                        postType: article['subType'].toString() ?? "",
                                        icon: "assets/svg/new_comment.svg",
                                        label: 'కామెంట్',
                                        onTap: () async {
                                          if (context.mounted) {
                                            context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                            showComments(context, article['id'],article['title']);
                                          }
                                        },
                                      ),
                                      Spacer(),

                                      InkWell(
                                        onTap: () async {
                                          SharedPreferences sp = await SharedPreferences.getInstance();
                                          String? userId = sp.getString("userId");
                                          String? deviceId = sp.getString("deviceId");
                                          EventRepo().addEvent({
                                            "share": "news",
                                            "postId": article['id'].toString()??"000",
                                            "createAt": DateTime.now().toString(),
                                            "postTitle": article['title'].toString()

                                          }, "shared_article");


                                          sendShareDetails(userId, article['id'], article['content'].toString());

                                          if (article['type'] == "Standard" || article['type'] == "Video" || article['type'] == "Image") {
                                            try {
                                              final image = await adsScreenshotController.capture(
                                                pixelRatio: 2.0,
                                              );
                                              if (image != null) {
                                                final directory = await getTemporaryDirectory();
                                                final imagePath = '${directory.path}/${article['id']}.png';
                                                final imageFile = File(imagePath);
                                                await imageFile.writeAsBytes(image);

                                                Share.shareXFiles([XFile(imageFile.path)], text: article['linkURLAndroid'].toString());
                                              } else {
                                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                              }
                                            } catch (e) {
                                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                            }
                                          } else if (article['type'] == "Gallery") {}
                                        },
                                        child: SvgPicture.asset(
                                          "assets/svg/share.svg",
                                          height: 20,
                                          width: 20,
                                          color: article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
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
                                              homeProvide.getAllPostList = [];
                                              homeProvide.getAllPost();

                                              EventRepo().addEvent({
                                                "refresh": true,
                                                "createAt": DateTime.now().toString()
                                              }, "reload_article");
                                            },
                                            child: context.read<HomeProvider>().isReload
                                                ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                : SvgPicture.asset(
                                              "assets/svg/new_refresh.svg",
                                              height: 22,
                                              width: 22,
                                              color: article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
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
                    : article['type'] == "Gallery"
                    ? Stack(
                  children: [

                    FullPageCarousel(
                      isHome: true,
                      imageUrls: article['gallery'] ?? [],
                      postDetails: article,
                    ),

                    // Bottom action bar
                  ],
                )
                    : Column(
                  children: [
                    // Image section
                    Stack(
                      children: [Container(
                        height: article['subType'] == "BigBlackStandard"
                            ? MediaQuery.of(context).size.height * .65
                            : MediaQuery.of(context).size.height * .40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16.r),
                            topLeft: Radius.circular(16.r),
                          ),
                          color: Colors.black,
                        ),
                        child: article['type'] == "Video"
                            ? SizedBox(
                          height: MediaQuery.of(context).size.height * .31,
                          width: MediaQuery.of(context).size.width,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: VideoPreview(
                              imageUrl: article['image_url'],
                              url: article['video_url'] ?? "",
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
                                    imageUrl: article['image_url'],
                                    title: article['title'],
                                  ),
                                ));
                          },
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16.r),
                                topLeft: Radius.circular(16.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: article['image_url'] ?? "fgyhuiiuh",
                                height: MediaQuery.of(context).size.height * (article['subType'] == "BigBlackStandard" ? .65 : .45),
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
                      ), Positioned(
                        top: 10,
                        left: 14,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
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
                      ),],
                    ),

                    // Action bar between image and title
                    Container(
                      color: article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Chota News branding
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Chota ",
                                    style: fontStyle(
                                      fontSize: Platform.isIOS ? 16 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: article['subType'] == "BigBlackStandard" ? Colors.white : Colors.black,
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

                          // Action buttons
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                  return InkWell(
                                    onTap: () async {
                                      log("Like");
                                      settingsProvider.isLikePost(article);
                                      EventRepo().addEvent({
                                        "like": !settingsProvider.isLikeList.contains(article['id'].toString()),
                                        "postId": article['id'].toString()??"000",
                                        "createAt": DateTime.now().toString(),
                                        "postTitle": article['title'].toString()
                                      }, "liked_article");
                                    },
                                    child: SizedBox(
                                      width: 24,
                                      child: SvgPicture.asset(
                                          settingsProvider.isLikeList.contains(article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                          height: 18,
                                          width: 18,
                                          color: settingsProvider.isLikeList.contains(article['id'].toString()) ? Colors.lightBlue : Colors.grey),
                                    ),
                                  );
                                }),
                                SizedBox(width: 16),
                                InkWell(
                                  onTap: () {
                                    log("Comment...");
                                    if (context.mounted) {
                                      context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                      showComments(context, article['id'],article['title']);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 24,
                                    child: SvgPicture.asset("assets/svg/new_comment.svg", height: 20, width: 20, color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 16),
                                InkWell(
                                  onTap: () async {
                                    SharedPreferences sp = await SharedPreferences.getInstance();
                                    String? userId = sp.getString("userId");

                                    sendShareDetails(userId, article['id'], article['content'].toString());

                                    if (article['type'] == "Standard" || article['type'] == "Video" || article['type'] == "Image") {
                                      try {
                                        final image = await adsScreenshotController.capture(
                                          pixelRatio: 2.0,
                                        );
                                        if (image != null) {
                                          final directory = await getTemporaryDirectory();
                                          final imagePath = '${directory.path}/${article['id']}.png';
                                          final imageFile = File(imagePath);
                                          await imageFile.writeAsBytes(image);

                                          Share.shareXFiles([XFile(imageFile.path)], text: article['linkURLAndroid'].toString());
                                        } else {
                                          CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                        }
                                      } catch (e) {
                                        CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                      }
                                    } else if (article['type'] == "Gallery") {}
                                  },
                                  child: SizedBox(
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
                        ],
                      ),
                    ),

                    // Title and content section
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: article['subType'] == "BigBlackStandard" ? AppColors.textColor : Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.sp),
                            topLeft: Radius.circular(10.sp),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16, right: 16, left: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(article['title'] ?? "No Title",
                                  style: homeScreenFontStyle(
                                      color: article['subType'] != "BigBlackStandard" ? AppColors.textColor : AppColors.cardBackgroundColor,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold)),
                              height(height: 8),
                              Expanded(
                                child: article['subType'] == "BulletPost"
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (article['content'] != "" && article['content'] != null && article['content'].toString().isNotEmpty)
                                        ? Text(article['content'],
                                        style: homeScreenFontStyle(
                                          color: AppColors.textColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.sp,
                                        ))
                                        : const SizedBox.shrink(),
                                    if (article['content'] != "" && article['content'] != null && article['content'].toString().isNotEmpty) height(height: 8),
                                    Expanded(
                                      child: ListView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: article['bulletPoints'].map<Widget>((item) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "● ",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: article['subType'] == "BigBlackStandard" ? AppColors.textColor.withOpacity(0.5) : AppColors.textColor,
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
                                                    color: article['subType'] == "BigBlackStandard" ? AppColors.textColor.withOpacity(0.5) : AppColors.textColor,
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
                                                if (article['isReporter'] == 1) Icon(Icons.person, size: 14, color: Colors.grey),
                                                if (article['isReporter'] == 1)
                                                  Text(
                                                    ' ${article['reportedBy']} | ',
                                                    style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                  ),
                                                Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                Text(
                                                  " ${formatTimeDifference(article['created'])}",
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
                                      ..._parseText(context, article['content'], article['links'], article),
                                      if (article['isStickyPost'] != 1)
                                        TextSpan(
                                          children: [
                                            TextSpan(text: "\n\n"),
                                            WidgetSpan(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (article['isReporter'] == 1) Icon(Icons.person, size: 14, color: Colors.grey),
                                                  if (article['isReporter'] == 1)
                                                    Text(
                                                      ' ${article['reportedBy']} | ',
                                                      style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                                                    ),
                                                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                  Text(
                                                    " ${formatTimeDifference(article['created'])}",
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
            );
          }),
        ),
      ),
    );
  }

  List<TextSpan> _parseText(BuildContext context, String text, links, article) {
    RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(linkRegExp, onMatch: (match) {
      String link = match.group(0)!;

      if (link.contains('<link1>') && links != null && links.isNotEmpty) {
        link = links[0]['value'].toString();
      } else if (link.contains('<link2>') && links != null && links.length > 1) {
        link = links[1]['value'].toString();
      } else if (link.contains('<link3>') && links != null && links.length > 2) {
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
            }));

      return "";
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            color: article['subType'] == "BigBlackStandard" ? AppColors.cardBackgroundColor : AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
          )));
      return "";
    });

    return spans;
  }

  void getWebData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("webPostId", "");
  }

  Future<void> launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.path}';
    }
  }
}