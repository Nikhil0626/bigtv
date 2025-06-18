import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../botton_actions.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import 'home_provider/home_provider.dart';
import 'main_screen_pageview.dart';

class ImageView extends StatefulWidget {
  final getAllPostList;
  final index;
  const ImageView({super.key,required this.getAllPostList,required this.index});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  ScreenshotController sc = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.getAllPostList ['type'] == "Image") {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => MainScreenPageView(
          //         startIndex: widget.index,
          //       ),
          //     ));
        }else{
          log("sdbsjbfsjbfjhsfbhjsdbfsmkfb");
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Screenshot(
                    controller: sc,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      child: Image.network(
                        widget.getAllPostList ['image_url'].toString() ?? "",
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.sp, vertical: 10.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                        return BottomActions(
                          iconColor: AppColors.iconColors,
                          postType: widget.getAllPostList ['subType'].toString() ?? "",
                          icon: settingsProvider.isLikeList.contains(widget.getAllPostList ['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                          label: 'లైక్',
                          isLike: settingsProvider.isLikeList.contains(widget.getAllPostList ['id'].toString()),
                          onTap: () {
                            log("Like");
                            settingsProvider.isLikePost(widget.getAllPostList );
                          },
                        );
                      }),
                      BottomActions(
                        postType: widget.getAllPostList ['subType'] ?? "",
                        icon: "assets/svg/new_comment.svg",
                        label: 'కామెంట్',
                        iconColor: AppColors.iconColors,
                        onTap: () async{
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? userId = sp.getString("userId");
                          String? deviceId = sp.getString("deviceId");
                          context.read<AuthenticationProvider>().sendEvent("CommentPage");

                          showComments(context, widget.getAllPostList ['id']);

                        },
                      ),
                      Spacer(),
                      BottomActions(
                        postType: widget.getAllPostList ['subType'] ?? "",
                        icon: "assets/svg/share.svg",
                        label: 'షేర్',
                        iconColor: AppColors.iconColors,
                        onTap: () async {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? userId = sp.getString("userId");

                          sendShareDetails(userId, widget.getAllPostList ['id'], widget.getAllPostList ['content'].toString());

                          if (widget.getAllPostList ['type'] == "Standard" || widget.getAllPostList ['type'] == "Video" || widget.getAllPostList ['type'] == "Image") {
                            try {
                              final image = await sc.capture(
                                pixelRatio: 2,
                              );
                              if (image != null) {
                                final directory = await getTemporaryDirectory();
                                final imagePath = '${directory.path}/${widget.getAllPostList ['id']}.png';
                                final imageFile = File(imagePath);
                                await imageFile.writeAsBytes(image);

                                Share.shareXFiles([XFile(imageFile.path)], text: Platform.isIOS ? widget.getAllPostList ['linkURLAndroid'].toString() : widget.getAllPostList ['linkURLIos'].toString());
                              } else {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                              }
                            } catch (e) {
                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                            }
                          } else if (widget.getAllPostList ['type'] == "Gallery") {
                            createAndSharePdf(context, widget.getAllPostList);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 14,
              child: Consumer<HomeProvider>(
                builder: (_,homeProvider,__) {
                  return GestureDetector(
                    onTap: () {

                      homeProvider.isBookMarkPost( widget.getAllPostList , context);
                      print("");
                    },
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color:  (homeProvider.isBookMark.contains(widget.getAllPostList ['id'].toString()) || widget.getAllPostList ['isBookmarked'] == 1)
                            ? AppColors.appButtonColor
                            : Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (homeProvider.isBookMark.contains(widget.getAllPostList ['id'].toString()) || widget.getAllPostList ['isBookmarked'] == 1)
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                }
              ),
            ),

          ],
        ),
      ),
    );
  }
}
