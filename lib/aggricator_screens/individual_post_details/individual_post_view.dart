import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/screens/home_screen/home_screens/home_screen_view.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_models/home_screen_model.dart';
import '../../screens/home_screen/home_provider/provider.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../screens/home_screen/home_screens/google_ads_view.dart';
import '../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../screens/videos_main/video_views/gallery_screen.dart';
import '../../screens/videos_main/video_views/video_preview.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../settings_screen/settings_provider/settings_provider.dart';

class IndividualPostView extends StatefulWidget {
  final String postId;
final bool isComeFrom;
  const IndividualPostView({super.key, required this.postId,this.isComeFrom = true});

  @override
  State<IndividualPostView> createState() => _IndividualPostViewState();
}

class _IndividualPostViewState extends State<IndividualPostView> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    log("is come from lin----k${widget.postId}");
    context.read<HomeProvider>().getIndividualPost(widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
          final article =  homeProvider.getSinglePostList.isEmpty?{}:homeProvider.getSinglePostList;
          return homeProvider.isPostLoading
              ? AppLoadingScreen()
              :  Stack(
                      children: [
                        homeProvider.getSinglePostList.isEmpty
                            ? AppNoData()
                            :  SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Expanded(
                                child: Screenshot(
                                  controller: adsScreenshotController,
                                  child: article['type'] == "WebView"
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InAppWebViewScreen(
                                            webUrl: context.read<HomeProvider>().webUrl.toString(),
                                            title: '',
                                          ),
                                        )
                                      : article['type'] == "GoogleAds"
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: GoogleAdsView(
                                                article: article,
                                                flipProvider: context.read<HomeProvider>(),
                                                // screenshotController:
                                                //     adsScreenshotController,
                                                isFoldable: false,
                                              ),
                                            )
                                          : article['type'] == "Image"
                                              ? Image.network(
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height,
                                                fit: BoxFit.cover,
                                                article['image_url'] ?? "",
                                              )
                                              : article['type'] == "Gallery"
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(12),
                                                      ),
                                                      child: FullPageCarousel(
                                                        isHome: true,
                                                        imageUrls: article['gallery'] ?? [],
                                                        postDetails: article,
                                                      ),
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Container(
                                                          height: article['subType'] == "BigBlackStandard" ? MediaQuery.of(context).size.height * .65 : MediaQuery.of(context).size.height * .4,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(16.r),
                                                              topLeft: Radius.circular(16.r),
                                                            ),
                                                            color: Colors.black,
                                                          ),
                                                          child: article['type'] == "Video"
                                                              ? Align(
                                                                  alignment: Alignment.topCenter,
                                                                  child: VideoPreview(
                                                                    imageUrl: article['image_url'],
                                                                    url: article['video_url'] ?? "",
                                                                    isFoldable: false,
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(16.r),
                                                                    topLeft: Radius.circular(16.r),
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    imageUrl: article['image_url'],
                                                                    height: MediaQuery.of(context).size.height * .40,
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
                                                        Positioned(
                                                          top: 20,
                                                          right: 20,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              context.read<SettingsProvider>().saveBookmarks(
                                                                widget.postId.toString(),
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(7),
                                                              decoration: BoxDecoration(
                                                                color: Colors.black54,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.bookmark_outline,
                                                                color: Colors.white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 0,
                                                          child: Container(
                                                            height: article['subType'] == "BigBlackStandard" ? MediaQuery.of(context).size.height * .3 : MediaQuery.of(context).size.height * .55,
                                                            width: MediaQuery.of(context).size.width,
                                                            decoration: BoxDecoration(
                                                              color: article['subType'] == "BigBlackStandard" ? AppColors.textColor : AppColors.cardBackgroundColor,
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
                                                                  Text(article['title'],
                                                                      style: homeScreenFontStyle(
                                                                          color: article['subType'] != "BigBlackStandard" ? AppColors.textColor : AppColors.cardBackgroundColor,
                                                                          fontSize: 18.sp,
                                                                          fontWeight: FontWeight.bold)),
                                                                  height(height: 8),
                                                                  Container(
                                                                    child: article['subType'] == "BulletPost"
                                                                        ? Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              (article['content'] != "")
                                                                                  ? Text(article['content'],
                                                                                      style: homeScreenFontStyle(
                                                                                        color: article['subType'] == "BigBlackStandard"
                                                                                            ? AppColors.textColor.withOpacity(0.5)
                                                                                            : AppColors.cardBackgroundColor,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontSize: 16.sp,
                                                                                      ))
                                                                                  : const SizedBox.shrink(),
                                                                              height(height: 8.sp),
                                                                              Expanded(
                                                                                child: ListView(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  children: article['']!.map<Widget>((item) {
                                                                                    // Explicitly specify <Widget>
                                                                                    return Row(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      // Align items at the top
                                                                                      children: [
                                                                                        Text(
                                                                                          "● ",
                                                                                          style: TextStyle(
                                                                                            fontSize: 14.sp,
                                                                                            color: article['subType'] == "BigBlackStandard"
                                                                                                ? AppColors.textColor.withOpacity(0.5)
                                                                                                : AppColors.cardBackgroundColor,
                                                                                            // Reduce bullet size for better alignment
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
                                                                                              // Match font size
                                                                                              height: 1, // Ensures consistent line height
                                                                                            ),
                                                                                            style: homeScreenFontStyle(
                                                                                              color: article['subType'] == "BigBlackStandard"
                                                                                                  ? AppColors.textColor.withOpacity(0.5)
                                                                                                  : AppColors.cardBackgroundColor,
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
                                                                              )
                                                                            ],
                                                                          )
                                                                        : RichText(
                                                                            text: TextSpan(
                                                                              text: '',
                                                                              children: [
                                                                                ..._parseText(context, article['content'], [], article),
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
                                                        Positioned(
                                                          left: 20,
                                                          bottom:
                                                              article['subType'] == "BigBlackStandard" ? MediaQuery.of(context).size.height * .30 - 15 : MediaQuery.of(context).size.height * .55 - 15,
                                                          child: Container(
                                                            height: 30,
                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.shade50,
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Center(
                                                              child: Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: "Chota ",
                                                                      style: fontStyle(
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: "News",
                                                                      style: fontStyle(
                                                                        fontSize: 16,
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
                                                      ],
                                                    ),
                                ),
                              ),
                              Container(
                                color: article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
                                height: 45.sp,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      color: AppColors.borderColor,
                                      width: MediaQuery.of(context).size.width,
                                      height: 1,
                                    ),
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
                                              // isLike: flipProvider.isLikeList.contains(widget.article.id.toString()),
                                              isLike: settingsProvider.isLikeList.contains(article['id'].toString()),
                                              onTap: () {
                                                log("Like");
                                                settingsProvider.isLikePost(article);

                                                // settingsProvider.isLikePost(widget.article);
                                              },
                                            );
                                          }),
                                          width(width: 20),
                                          BottomActions(
                                            postType: article['subType'] ?? "",
                                            icon: "assets/svg/new_comment.svg",
                                            label: 'కామెంట్',
                                            onTap: () {
                                              context.read<AuthProvider>().sendEvent("CommentPage");
                                              EventRepo().sendEvent({
                                                "key": "comments",
                                                "data": {
                                                  "device_id": "${GlobalVariables().deviceId}",
                                                  "userId": context.read<FlipProvider>().userId ?? "",
                                                  "postId": article['id'].toString(),
                                                }
                                              });
                                              log("Comment --- ${context.read<AuthProvider>().loginType}");
                                              showComments(context, article['id']);
                                              EventRepo().sendEvent({
                                                "key": "comments",
                                                "data": {"deviceId": GlobalVariables().deviceId.toString(), "openTime": DateTime.now().toString()}
                                              });
                                            },
                                          ),
                                          Spacer(),
                                          BottomActions(
                                            postType: article['subType'] ?? "",
                                            icon: "assets/svg/share.svg",
                                            label: 'షేర్',
                                            onTap: () async {
                                              EventRepo().sendEvent({
                                                "key": "share_via_widget.articles",
                                                "data": {
                                                  "device_id": "${GlobalVariables().deviceId}",
                                                  "userId": context.read<FlipProvider>().userId ?? "",
                                                  "postId": article['id'].toString(),
                                                  "isWhatAppShare": false,
                                                }
                                              });

                                              sendShareDetails(context.read<FlipProvider>().userId, article['id'], article['content'].toString());

                                              if (article['type'] == "Standard" || article['type'] == "Video") {
                                                try {
                                                  final image = await adsScreenshotController.capture(
                                                    pixelRatio: 0.5,
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
                                              } else if (article['type'] == "Gallery") {
                                                createAndSharePdf(context, article);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            left: 20,
                            top: 20,
                            child: InkWell(
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: Colors.blueGrey.shade200),
                                  child: Icon(
                                    Icons.keyboard_backspace,
                                    size: 20,
                                  )),
                              onTap: () {
                                if(widget.isComeFrom){
                                  Navigator.pop(context);
                                }else {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeView(),
                                    ),
                                        (route) => false,
                                  );
                                }
                              },
                            ))
                      ],
                    );
        }),
      ),
    );
  }

  List<TextSpan> _parseText(BuildContext context, String text, links,  article) {
    RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(linkRegExp, onMatch: (match) {
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
        style: homeScreenFontStyle(
          color: article.subType == "BigBlackStandard" ? Colors.white : Colors.blue,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
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
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            // color:  article.subType == "BigBlackStandard" ? AppColors.cardBackgroundColor: AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
          )));
      return "";
    });

    return spans;
  }
}
