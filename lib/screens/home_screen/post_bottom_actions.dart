import 'dart:developer';
import 'dart:io';

import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';

import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
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
          SizedBox(
            height: 52,
            width: 52,
            child: InkWell(
              onTap: () {
                log("Refresh");
                flipProvider.getArticles(refresh: true);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  height(height: 4),
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
                  height(height: 4),
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
          SizedBox(
            height: 52,
            width: 52,
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
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () async {
                try {
                  Uint8List? image = await screenshotController.capture();
                  if (image == null) {
                    print("Failed to capture screenshot");
                    return;
                  }

                  final directory = await getTemporaryDirectory();
                  final imagePath = '${directory.path}/screenshot.png';
                  final imageFile = File(imagePath);
                  await imageFile.writeAsBytes(image);

                  await SocialSharingPlus.shareToSocialMedia(
                    SocialPlatform.whatsapp,
                    Platform.isIOS
                        ? article.linkURLIos.toString()
                        : article.linkURLAndroid.toString(),
                    media: imagePath,
                    isOpenBrowser: false,
                  );
                } catch (e) {
                  print("Error taking screenshot: $e");
                }
              },
              child: SizedBox(
                height: 35,
                width: 35,
                child: SvgPicture.asset(
                  "assets/svg/whatsapp.svg",

                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            width: 52,
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
          SizedBox(
            height: 52,
            width: 52,
            child: BottomActions(
              postType: postType,
              icon: "assets/svg/share.svg",
              label: 'షేర్',
              onTap: () {
                sendShareDetails(context.read<FlipProvider>().userId,article.id,article.content.toString());
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
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(
              color: Colors.black87,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomActions(
                    postType: "",
                    iconColor: Colors.black87,
                    icon: "assets/svg/like.svg",
                    label: 'లైక్',
                    isLike: context
                            .watch<FlipProvider>()
                            .isLikeList
                            .contains(article.id.toString())
                        ? true
                        : false,
                    onTap: () {
                      log(
                        "Like",
                      );
                      context
                          .read<FlipProvider>()
                          .isLikePost(article);
                    }),
                BottomActions(
                    postType: "",
                    iconColor: Colors.black87,
                    icon: "assets/svg/comment.svg",
                    label: 'కామెంట్',
                    onTap: () async {
                      log("Comment --- ${context.read<AuthProvider>().loginType}");
                      showComments(context, article.id.toString());
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
      );
    });
  }
}
