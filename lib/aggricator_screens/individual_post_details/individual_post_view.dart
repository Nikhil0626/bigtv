import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/image_view_ads.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:flutter_svg/svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/in_app_web_view.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import '../video_image_screen/gallery_screen.dart';
import '../video_image_screen/video_preview.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../events_data/event_repo.dart';

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
    log("is come from lin----k ${widget.postId}");
    getWebData();
    context.read<HomeProvider>().getIndividualPost(widget.postId, isAds: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                    : (article['type'] == "Image" &&article['subType'] == "ImageAd")
                    ? InkWell(
                    onTap: () async {
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      bool isLogin = sp.getString("loginType") != "login" ? true : false;
                      if (isLogin) {
                        CustomToast.showErrorToast(msg: "Your a guest user, Please Login to Join Contest");
                      } else {
                        if (article['postUrl'] == "" || article['postUrl'] == null) {

                        } else {
                          Navigator.pop(context);
                          context
                              .read<HomeProvider>()
                              .sendAdsDataSend(article['id'], article['title'], article['image_url'], false, article['postUrl']);
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        article['image_url'].length == 1
                            ? Image.network(
                         article['image_url'][0] ?? "",
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.fill,
                        )
                            : ImagePostSlider(
                          imageUrl: article['image_url'],
                        ),

                        Positioned(
                          top: 40,
                          left: 30,
                          child: InkWell(
                            onTap: () {
                              log("sfhskjfhewfheawiuhgf");
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
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
                              imageUrl: (article['image_url'] != null && article['image_url'].toString().startsWith('http')) ? article['image_url'] : "https://migwp.chotanews.com/${article['image_url']}",
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
                                    imageUrl: (article['image_url'] != null && article['image_url'].toString().startsWith('http')) ? article['image_url'] : "https://migwp.chotanews.com/${article['image_url']}",
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
                                imageUrl: (article['image_url'] != null && article['image_url'].toString().startsWith('http')) ? article['image_url'] : "https://migwp.chotanews.com/${article['image_url']}",
                                height: MediaQuery.of(context).size.height * (article['subType'] == "BigBlackStandard" ? .65 : .45),
                                width: MediaQuery.of(context).size.width,
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

                    Container(
                      height: 4,
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xFFED1C24),
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: article['subType'] == "BigBlackStandard"
                            ? Colors.black
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title and Action Icons in a Row with minimal spacing
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Article Title
                                    Expanded(
                                      child: Text(
                                        article['title'] ?? "No Title",
                                        style: homeScreenFontStyle(
                                          color: AppColorTokens.primaryRed,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                     width(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(border: BoxBorder.all(color: Color(0xFFED1C24), width: 0.36), borderRadius: BorderRadius.all(Radius.circular(8))),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                            return InkWell(
                                              onTap: () async {
                                                log("Like");
                                                settingsProvider.isLikePost(article);
                                                EventRepo().addEvent({
                                                  "isLike": !settingsProvider.isLikeList.contains(article['id'].toString()),
                                                  "postId": article['id'].toString() ?? "000",
                                                  "createAt": DateTime.now().toString(),
                                                  "postTitle": article['title'].toString()
                                                }, "liked_article");
                                              },
                                              child: SvgPicture.asset(
                                                settingsProvider.isLikeList.contains(article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                height: 18,
                                                width: 18,
                                                color: settingsProvider.isLikeList.contains(article['id'].toString()) ? AppColorTokens.primaryRed : AppColorTokens.primaryRed,
                                              ),
                                            );
                                          }),
                                           width(width: 14),
                                          InkWell(
                                            onTap: () {
                                              log("Comment...");
                                              if (context.mounted) {
                                                context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                showComments(context, article['id'], article['title']);
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              "assets/svg/new_comment.svg",
                                              height: 18,
                                              width: 18,
                                              color: Color(0xFFED1C24),
                                            ),
                                          ),
                                         width(width: 14),

                                          InkWell(
                                            onTap: () async {
                                              SharedPreferences sp = await SharedPreferences.getInstance();
                                              String? userId = sp.getString("userId");
                                              sendShareDetails(userId, article['id'], article['content'].toString());
                                              if (article['type'] == "Standard" || article['type'] == "Video" || article['type'] == "Image") {
                                                try {
                                                  final image = await adsScreenshotController.capture(pixelRatio: 2.0);
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
                                              height: 18,
                                              width: 18,
                                              color: Color(0xFFED1C24),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              height(height: 8),
                              Expanded(
                                child: article['subType'] == "BulletPost"
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (article['content'] != "" && article['content'] != null && article['content'].toString().isNotEmpty)
                                        ? (() {
                                            String content = article['content'].toString();
                                            List<String> words = content.split(RegExp(r'\s+'));
                                            bool isOverflow = words.length > 30;
                                            String displayContent = isOverflow ? words.take(30).join(' ') + "..." : content;
                                            
                                            return RichText(
                                              text: TextSpan(
                                                text: displayContent,
                                                style: homeScreenFontStyle(
                                                  color: AppColors.textColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                                children: [
                                                  if (isOverflow)
                                                    TextSpan(
                                                      text: " Read more",
                                                      style: homeScreenFontStyle(
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16.sp,
                                                      ),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _showBottomSheet(context, article);
                                                        },
                                                    ),
                                                ],
                                              ),
                                            );
                                          })()
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
                                                  color: article['subType'] == "BigBlackStandard" ? AppColors.textColor.withValues(alpha: 0.5) : AppColors.textColor,
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
                                                    color: article['subType'] == "BigBlackStandard" ? AppColors.textColor.withValues(alpha: 0.5) : AppColors.textColor,
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
                                      ...(() {
                                        String content = article['content']?.toString() ?? "";
                                        List<String> words = content.split(RegExp(r'\s+'));
                                        bool isOverflow = words.length > 30;
                                        String displayContent = isOverflow ? words.take(30).join(' ') + "..." : content;
                                        
                                        List<TextSpan> spans = _parseText(context, displayContent, article['links'], article);
                                        if (isOverflow) {
                                          spans.add(
                                            TextSpan(
                                              text: " Read more",
                                              style: homeScreenFontStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.sp,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _showBottomSheet(context, article);
                                                },
                                            ),
                                          );
                                        }
                                        return spans;
                                      })(),
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
                            child: CachedNetworkImage(
                              imageUrl: (article['image_url'].toString().startsWith('http'))
                                  ? article['image_url']
                                  : "https://migwp.chotanews.com/${article['image_url']}",
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
                              {'subType': 'Standard'} // Force standard colors for bottom sheet
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
              log("Launching URL: $link");
              launchURL(Uri.parse(link.toString()));
            }));

      return "";
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            color: article['subType'] == "BigBlackStandard" ? AppColors.cardBackgroundColor : AppColors.textColor.withValues(alpha: 0.5),
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