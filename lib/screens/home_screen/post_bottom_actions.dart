import 'dart:developer';
import 'dart:io';

import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';

import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/commant_screen.dart';
import 'botton_actions.dart';
import 'dart:typed_data';

class PostBottomActions extends StatelessWidget {
  final String postType;
  final FlipProvider flipProvider;
  final HomeScreenModel article;
  final ScreenshotController screenshotController;

  const PostBottomActions(
      {super.key,
      required this.flipProvider,
      required this.article,
      required this.screenshotController,
      this.postType = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: postType == "BigBlackStandard" ? Colors.black : Colors.white,
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            // color: Colors.cyan,
            // height: 52,
            // width: 60,
            child: InkWell(
              onTap: () {
                log("Refresh");
                flipProvider.getArticles(refresh: true);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  flipProvider.isRefresh
                      ? const SizedBox(
                          height: 20, width: 20, child: AppLoadingScreen())
                      : SvgPicture.asset(
                          "assets/svg/reload.svg",
                          height: 20,
                          width: 20,
                          color: postType == "BigBlackStandard"
                              ? Colors.white
                              : Colors.grey,
                        ),
                  height(height: 6),
                  Text(
                    "రిలోడ్",
                    style: fontStyle(
                      fontSize: 14,
                      color: postType == "BigBlackStandard"
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            // color: Colors.brown,
            // height: 52,
            // width: 60,
            child: BottomActions(
              postType: postType,
              icon: flipProvider.isLikeList.contains(article.id.toString())
                  ? "assets/svg/like_full.svg"
                  : "assets/svg/like.svg",
              label: 'లైక్',
              isLike: flipProvider.isLikeList.contains(article.id.toString()),
              onTap: () {
                log("Like");
                flipProvider.isLikePost(article);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                if (article.type == "Gallery") {
                  showSaveBottomSheet(context, article, screenshotController);

                } else {
                  try {
                    debugPrint("Capturing screenshot...");
                    Uint8List? image = await screenshotController.capture();

                    if (image == null) {
                      debugPrint("Failed to capture screenshot");
                      return;
                    }

                    // Get correct directory based on platform
                    final directory = Platform.isIOS
                        ? await getApplicationDocumentsDirectory()
                        : await getTemporaryDirectory();
                    final String imagePath = '${directory.path}/${article.id}.png';

                    // Save the image
                    File imageFile = File(imagePath);
                    await imageFile.writeAsBytes(image, flush: true);

                    await Future.delayed(const Duration(milliseconds: 500));

                    if (!await imageFile.exists()) {
                      debugPrint("Error: File not found at $imagePath");
                      return;
                    }

                    debugPrint("Image saved at: $imagePath");

                    // Save to gallery (iOS required)
                    if (Platform.isIOS) {
                      final result = await ImageGallerySaverPlus.saveImage(image);
                      debugPrint("Image saved to gallery: $result");
                    } else {
                      final result = await ImageGallerySaverPlus.saveFile(imageFile.path);
                      debugPrint("Image saved to gallery: $result");
                    }

                    // Ensure correct file path
                    String filePath = imageFile.absolute.path;

                    // Share to WhatsApp
                    await SocialSharingPlus.shareToSocialMedia(
                      SocialPlatform.whatsapp,
                      Platform.isIOS ? article.linkURLIos.toString() : article.linkURLAndroid.toString(),
                      media: filePath, // Ensure absolute path
                      onAppNotInstalled: () {
                        debugPrint("WhatsApp not installed");
                      },
                      isOpenBrowser: false,
                    );

                  } catch (e, stacktrace) {
                    debugPrint("Error taking screenshot: $e");
                    debugPrint("Stacktrace: $stacktrace");
                  }


                }

                /*  try {
                  log("Capturing screenshot...");
                  Uint8List? image = await screenshotController.capture();

                  if (image == null) {
                    print("Failed to capture screenshot");
                    return;
                  }

                  // Save image to a publicly accessible directory
                  final directory = await getTemporaryDirectory();
                  final imagePath = '${directory.path}/${article.id}.png';
                  File imageFile = File(imagePath);
                  await imageFile.writeAsBytes(image);
                  log("Image saved at: $imagePath");

                  // Save to gallery (iOS might need this before sharing)
                  final result = await ImageGallerySaver.saveFile(imageFile.path);
                  log("Image saved to gallery: $result");

                  // Convert to XFile (needed for iOS)
                  XFile xFile = XFile(imageFile.path);

                  // Ensure proper file path formatting for iOS
                  String filePath = Platform.isIOS ? Uri.file(imageFile.path).toString() : imageFile.path;

                  // Share the screenshot
                  await SocialSharingPlus.shareToSocialMedia(
                    SocialPlatform.whatsapp,
                    Platform.isIOS ? article.linkURLIos : article.linkURLAndroid,
                    media: filePath,
                    onAppNotInstalled: () {
                      log("WhatsApp not installed");
                    },
                    isOpenBrowser: false,
                  );

                } catch (e, stacktrace) {
                  print("Error taking screenshot: $e");
                  print("Stacktrace: $stacktrace");
                }*/
                // try {
                //   log("Capturing screenshot...");
                //   Uint8List? image = await screenshotController.capture();
                //
                //   if (image == null) {
                //     print("Failed to capture screenshot");
                //     return;
                //   }
                //
                //   final directory = await getTemporaryDirectory();
                //   final imagePath = '${directory.path}/${article.id}.png';
                //
                //   File imageFile = File(imagePath);
                //   await imageFile.writeAsBytes(image);
                //
                //   log("Image saved at: $imagePath");
                //
                //   // Convert to XFile (especially for iOS)
                //   XFile xFile = XFile(imageFile.path);
                //
                //   // Ensure iOS path is prefixed with "file://"
                //   String filePath = Platform.isIOS ? "file://${imageFile.path}" : imageFile.path;
                //
                //   await SocialSharingPlus.shareToSocialMedia(
                //     SocialPlatform.whatsapp,
                //     Platform.isIOS ? article.linkURLIos.toString() : article.linkURLAndroid.toString(),
                //     media: filePath, // Try changing this to `xFile.path` if needed
                //     onAppNotInstalled: () {
                //       log("WhatsApp not installed");
                //     },
                //     isOpenBrowser: false,
                //   );
                // } catch (e) {
                //   print("Error taking screenshot: $e");
                // }

                /// hello

                // try {
                //   log("ghfdsfghjkhgfdszxfghjkhjhgfsdsfygukhhgf");
                //   Uint8List? image = await screenshotController.capture();
                //   if (image == null) {
                //     print("Failed to capture screenshot");
                //     return;
                //   }
                //   final directory = await getTemporaryDirectory();
                //   final imagePath = '${directory.path}/${article.id}.png';
                //   final imageFile = File(imagePath);
                //   await imageFile.writeAsBytes(image);
                //   log(",knlkjkjhkjhk ${imagePath}");
                //   await SocialSharingPlus.shareToSocialMedia(
                //     SocialPlatform.whatsapp,
                //     Platform.isIOS
                //         ? article.linkURLIos.toString()
                //         : article.linkURLAndroid.toString(),
                //     media: imagePath,
                //     onAppNotInstalled: () {
                //       log(",knlkjkjhkjhk ${imagePath}");
                //     },
                //     isOpenBrowser: false,
                //   );
                // } catch (e) {
                //   print("Error taking screenshot: $e");
                // }
              },
              child: Container(
                // color: Colors.white,

                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 12),
                child: SvgPicture.asset(
                  height: 34,
                  width: 34,
                  "assets/svg/whatsapp.svg",
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: BottomActions(
              postType: postType,
              icon: "assets/svg/comment.svg",
              label: 'కామెంట్',
              onTap: () {
                log("Comment --- ${context.read<AuthProvider>().loginType}");
                showComments(context, article);
              },
            ),
          ),
          Expanded(
            flex: 1,
            // color: Colors.green,
            // height: 52,
            // width: 60,
            child: BottomActions(
              postType: postType,
              icon: "assets/svg/share.svg",
              label: 'షేర్',
              onTap: () {
                sendShareDetails(context.read<FlipProvider>().userId,
                    article.id, article.content.toString());
                if (article.type == "Standard" || article.type == "Image") {
                  takeScreenshotAndShare(article, screenshotController);
                } else if (article.type == "Gallery") {
                  createAndSharePdf(context, article);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryPostBottomActions extends StatelessWidget {
  final article;
  final bool isHome;

  const GalleryPostBottomActions(
      {super.key, required this.article, this.isHome = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlipProvider>(builder: (_, flipProvider, __) {
      return Container(
        color: Colors.white.withOpacity(0.4),
        height: Platform.isIOS ? 75 : 70,
        child: Padding(
          padding: EdgeInsets.only(bottom: Platform.isIOS ? 20 : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   color: Colors.black,
              //   height: 1,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomActions(
                      postType: "",
                      iconColor: Colors.black87,
                      icon: flipProvider.isLikeList
                              .contains(article.id.toString())
                          ? "assets/svg/like_full.svg"
                          : "assets/svg/like.svg",
                      label: 'లైక్',
                      isLike: flipProvider.isLikeList
                          .contains(article.id.toString()),
                      onTap: () {
                        log(
                          "Like Post",
                        );
                        flipProvider.isLikePost(article);
                      }),
                  BottomActions(
                      postType: "",
                      iconColor: Colors.black87,
                      icon: "assets/svg/comment.svg",
                      label: 'కామెంట్',
                      onTap: () async {
                        log("Comment --- ${context.read<AuthProvider>().loginType}");
                        showComments(context, article);
                      }),
                  BottomActions(
                      postType: "",
                      iconColor: Colors.black87,
                      icon: "assets/svg/share.svg",
                      label: ' షేర్',
                      onTap: () async {
                        if (article.type == "Gallery") {
                          createAndSharePdf(context, article);
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

void showSaveBottomSheet(
    BuildContext context, article, ScreenshotController screenshotController) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                try {
                  debugPrint("Capturing screenshot...");

                  // Capture screenshot
                  Uint8List? image = await screenshotController.capture();

                  if (image == null) {
                    debugPrint("Failed to capture screenshot");
                    return;
                  }

                  // Get temporary directory
                  final directory = await getTemporaryDirectory();
                  final String imagePath =
                      '${directory.path}/${article.id}.png';

                  // Save image as a file
                  File imageFile = File(imagePath);
                  await imageFile.writeAsBytes(image);

                  // Ensure file exists before proceeding
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!await imageFile.exists()) {
                    debugPrint("Error: File not found at $imagePath");
                    return;
                  }

                  debugPrint("Image saved at: $imagePath");

                  // Save to gallery (for iOS compatibility)
                  final result =
                      await ImageGallerySaverPlus.saveFile(imageFile.path);
                  debugPrint("Image saved to gallery: $result");

                  // Convert to XFile (needed for iOS)
                  XFile xFile = XFile(imageFile.path);

                  // Ensure proper file path formatting for iOS
                  String filePath = Platform.isIOS
                      ? "file://${imageFile.path}"
                      : imageFile.path;

                  // Share the screenshot via WhatsApp
                  await SocialSharingPlus.shareToSocialMedia(
                    SocialPlatform.whatsapp,
                    Platform.isIOS
                        ? article.linkURLIos.toString()
                        : article.linkURLAndroid.toString(),
                    // You can replace this with a dynamic link if needed
                    media: filePath,
                    onAppNotInstalled: () {
                      debugPrint("WhatsApp not installed");
                    },
                    isOpenBrowser: false,
                  );
                  Navigator.pop(context);
                } catch (e, stacktrace) {
                  debugPrint("Error taking screenshot: $e");
                  debugPrint("Stacktrace: $stacktrace");
                }
              },
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    color: AppColors.appButtonColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "Download Single Post",
                  style: fontStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            height(height: 20),
            InkWell(
              onTap: () {
                createAndSharePdf(context, article).then((onValue)=>   Navigator.pop(context));
              },
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    color: AppColors.appButtonColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "Download Entire gallery",
                  style: fontStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            height(height: 20),
          ],
        ),
      );
    },
  );
}
