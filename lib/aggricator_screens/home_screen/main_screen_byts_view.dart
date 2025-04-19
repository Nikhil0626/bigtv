import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

class MainScreenBytView extends StatefulWidget {
  final article;
  final bool isaiTags;

  const MainScreenBytView({super.key, required this.article, this.isaiTags = false});

  @override
  State<MainScreenBytView> createState() => _MainScreenBytViewState();
}

class _MainScreenBytViewState extends State<MainScreenBytView> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: adsScreenshotController,
              child: context.read<HomeProvider>().isWebView==true
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
                          child: GoogleAdsView(
                            isList: true,
                            article: widget.article,
                            flipProvider: context.read<HomeProvider>(),
                            // screenshotController: adsScreenshotController,
                            isFoldable: false,
                          ),
                        )
                      : widget.article['type'] == "Image"
                          ? InkWell(
                              onTap: () async {
                                if (widget.article['type'] == "Image") {
                                  if (await canLaunchUrl(Uri.parse(widget.article['content'].toString()))) {
                                    await launchUrl(Uri.parse(widget.article['content'].toString()));
                                  } else {
                                    throw 'Could not launch ${Uri.parse(widget.article['content'].toString())}';
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  Image.network(
                                    widget.article['image_url'] ?? "",
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
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
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 14,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<SettingsProvider>().saveBookmarks(
                                              widget.article['id'].toString(),
                                            );
                                        print("");
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
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : widget.article['type'] == "Gallery"
                              ? Stack(
                                  children: [
                                    FullPageCarousel(
                                      isHome: true,
                                      imageUrls: widget.article['gallery'] ?? [],
                                      postDetails: widget.article,
                                    ),
                                    Positioned(
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
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 14,
                                      child: GestureDetector(
                                        onTap: () {
                                          // context.read<SettingsProvider>().saveBookmarks(
                                          //   flipProvider.mainArticlesData[index].id.toString(),
                                          // );
                                          context.read<SettingsProvider>().saveBookmarks(
                                                widget.article['id'].toString(),
                                              );
                                          print("");
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
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      height: widget.article['subType'] == "BigBlackStandard"
                                          ? MediaQuery.of(context).size.height * .65
                                          : widget.isaiTags
                                              ? MediaQuery.of(context).size.height * .45
                                              : MediaQuery.of(context).size.height * .4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(16.r),
                                          topLeft: Radius.circular(16.r),
                                        ),
                                        color: Colors.black,
                                      ),
                                      child: Stack(
                                        children: [
                                          // Main Content (Image or Video)
                                          widget.article['type'] == "Video"
                                              ? SizedBox(
                                                  height: MediaQuery.of(context).size.height * .35,
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
                                              : ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(16.r),
                                                    topLeft: Radius.circular(16.r),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: widget.article['image_url'],
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

                                          if (widget.isaiTags == false)
                                            Positioned(
                                              top: 12,
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
                                            ),

                                          if (widget.isaiTags == false)
                                            Positioned(
                                              top: 12,
                                              right: 14,
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.read<SettingsProvider>().saveBookmarks(
                                                        widget.article['id'].toString(),
                                                      );
                                                  print("");
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
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        height: widget.article['subType'] == "BigBlackStandard"
                                            ? MediaQuery.of(context).size.height * .3
                                            : widget.isaiTags
                                                ? MediaQuery.of(context).size.height * .50
                                                : MediaQuery.of(context).size.height * .55,
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
                                                          (widget.article['content'] != "")
                                                              ? Text(widget.article['content'],
                                                                  style: homeScreenFontStyle(
                                                                    color: widget.article['subType'] == "BigBlackStandard" ? AppColors.textColor.withOpacity(0.5) : AppColors.textColor,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 16.sp,
                                                                  ))
                                                              : const SizedBox.shrink(),
                                                          height(height: 8.sp),
                                                          Expanded(
                                                            child: ListView(
                                                              physics: const NeverScrollableScrollPhysics(),
                                                              children: widget.article['bulletPoints'].map<Widget>((item) {
                                                                // Explicitly specify <Widget>
                                                                return Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  // Align items at the top
                                                                  children: [
                                                                    Text(
                                                                      "● ",
                                                                      style: TextStyle(
                                                                        fontSize: 14.sp,
                                                                        color: widget.article['subType'] == "BigBlackStandard" ? AppColors.textColor.withOpacity(0.5) : AppColors.textColor,
                                                                        // Reduce bullet size for better alignment
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
                                                                          // Match font size
                                                                          height: 1, // Ensures consistent line height
                                                                        ),
                                                                        style: homeScreenFontStyle(
                                                                          color: widget.article['subType'] == "BigBlackStandard" ? AppColors.textColor.withOpacity(0.5) : AppColors.textColor,
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
                                                          )
                                                        ],
                                                      )
                                                    : RichText(
                                                        text: TextSpan(
                                                          text: '',
                                                          children: [
                                                            ..._parseText(context, widget.article['content'], [], widget.article),
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      bottom: widget.article['subType'] == "BigBlackStandard"
                                          ? MediaQuery.of(context).size.height * .30 - 15
                                          : widget.isaiTags
                                              ? MediaQuery.of(context).size.height * .50 - 15
                                              : MediaQuery.of(context).size.height * .55 - 15,
                                      child: Container(
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBackgroundColor,
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
            color: widget.article['subType'] == "BigBlackStandard" ? Colors.black : Colors.white,
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
                      width(width: 20),
                      BottomActions(
                        postType: widget.article['subType'].toString() ?? "",
                        icon: "assets/svg/new_comment.svg",
                        label: 'కామెంట్',
                        onTap: () {
                          context.read<AuthProvider>().sendEvent("CommentPage");
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {
                              "device_id": "${GlobalVariables().deviceId}",
                              "userId": context.read<FlipProvider>().userId ?? "",
                              "postId": widget.article['id'].toString(),
                            }
                          });
                          log("Comment --- ${context.read<AuthProvider>().loginType}");
                          showComments(context, widget.article['id']);
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {"deviceId": GlobalVariables().deviceId.toString(), "openTime": DateTime.now().toString()}
                          });
                        },
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          EventRepo().sendEvent({
                            "key": "share_via_widget.articles",
                            "data": {
                              "device_id": "${GlobalVariables().deviceId}",
                              "userId": context.read<FlipProvider>().userId ?? "",
                              "postId": widget.article['id'].toString(),
                              "isWhatAppShare": false,
                            }
                          });

                          sendShareDetails(context.read<FlipProvider>().userId, widget.article['id'], widget.article['content'].toString());

                          if (widget.article['type'] == "Standard" || widget.article['type'] == "Video") {
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
                        return InkWell(
                          onTap: () {
                            log("Refresh");
                            EventRepo().sendEvent({
                              "key": "reload",
                              "data": {
                                "device_id": "${GlobalVariables().deviceId}",
                                "userId": GlobalVariables().userId ?? "",
                              }
                            });
                            homeProvide.getAllPostList = [];
                            homeProvide.isReloadData();
                            homeProvide.getAllPost();
                          },
                          child: context.read<FlipProvider>().isRefresh
                              ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                              : SvgPicture.asset(
                                  "assets/svg/new_refresh.svg",
                                  height: 22,
                                  width: 22,
                                  color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey,
                                ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        print("pdfff ${imageUrl}");
        if (imageUrl.isNotEmpty) {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            final Uint8List imageData = response.bodyBytes;
            final pdfImage = pw.MemoryImage(imageData);

            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.FullPage(
                    ignoreMargins: true, // Ensures full coverage
                    child: pw.Image(
                      pdfImage,
                      fit: pw.BoxFit.cover, // Covers the full page
                    ),
                  );
                },
              ),
            );
          } else {
            print("Failed to load image: $imageUrl");
          }
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/${article['id']}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: $filePath");

      await Share.shareXFiles([XFile(filePath)], text: "https://apps.signitivessoft.com/individualPage");
      isSending = false;
      setState(() {});
    } catch (e) {
      isSending = false;
      setState(() {});
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<TextSpan> _parseText(BuildContext context, String text, links, article) {
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
          color: article['subType'] == "BigBlackStandard" ? Colors.white : Colors.blue,
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
            color: widget.article['subType'] == "BigBlackStandard" ? AppColors.cardBackgroundColor : AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
          )));
      return "";
    });

    return spans;
  }
}
