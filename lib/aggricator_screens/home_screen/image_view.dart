import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../settings_screen/settings_provider/settings_provider.dart';

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
        if (widget.getAllPostList[widget.index]['type'] == "Image") {
          if (await canLaunchUrl(Uri.parse(widget.getAllPostList[widget.index]['content'].toString()))) {
            await launchUrl(Uri.parse(widget.getAllPostList[widget.index]['content'].toString()));
          } else {
            throw 'Could not launch ${Uri.parse(widget.getAllPostList[widget.index]['content'].toString())}';
          }
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
                        widget.getAllPostList[widget.index]['image_url'].toString() ?? "",
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
                          postType: widget.getAllPostList[widget.index]['subType'].toString() ?? "",
                          icon: settingsProvider.isLikeList.contains(widget.getAllPostList[widget.index]['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                          label: 'లైక్',
                          isLike: settingsProvider.isLikeList.contains(widget.getAllPostList[widget.index]['id'].toString()),
                          onTap: () {
                            log("Like");
                            settingsProvider.isLikePost(widget.getAllPostList[widget.index]);
                          },
                        );
                      }),
                      BottomActions(
                        postType: widget.getAllPostList[widget.index]['subType'] ?? "",
                        icon: "assets/svg/new_comment.svg",
                        label: 'కామెంట్',
                        iconColor: AppColors.iconColors,
                        onTap: () async{
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? userId = sp.getString("userId");
                          String? deviceId = sp.getString("deviceId");
                          context.read<AuthProvider>().sendEvent("CommentPage");
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {
                              "device_id": "$deviceId",
                              "userId":userId ?? "",
                              "postId": widget.getAllPostList[widget.index]['id'].toString(),
                            }
                          });
                          showComments(context, widget.getAllPostList[widget.index]['id']);
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                          });
                        },
                      ),
                      Spacer(),
                      BottomActions(
                        postType: widget.getAllPostList[widget.index]['subType'] ?? "",
                        icon: "assets/svg/share.svg",
                        label: 'షేర్',
                        iconColor: AppColors.iconColors,
                        onTap: () async {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? userId = sp.getString("userId");
                          String? deviceId = sp.getString("deviceId");
                          EventRepo().sendEvent({
                            "key": "share_via_articles",
                            "data": {
                              "device_id": "$deviceId",
                              "userId": userId?? "",
                              "postId": widget.getAllPostList[widget.index]['id'].toString(),
                              "isWhatAppShare": false,
                            }
                          });

                          sendShareDetails(userId, widget.getAllPostList[widget.index]['id'], widget.getAllPostList[widget.index]['content'].toString());

                          if (widget.getAllPostList[widget.index]['type'] == "Standard" || widget.getAllPostList[widget.index]['type'] == "Video") {
                            try {
                              final image = await sc.capture(
                                pixelRatio: 2,
                              );
                              if (image != null) {
                                final directory = await getTemporaryDirectory();
                                final imagePath = '${directory.path}/${widget.getAllPostList[widget.index]['id']}.png';
                                final imageFile = File(imagePath);
                                await imageFile.writeAsBytes(image);

                                Share.shareXFiles([XFile(imageFile.path)], text: Platform.isIOS ? widget.getAllPostList[widget.index]['linkURLAndroid'].toString() : widget.getAllPostList[widget.index]['linkURLIos'].toString());
                              } else {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                              }
                            } catch (e) {
                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                            }
                          } else if (widget.getAllPostList[widget.index]['type'] == "Gallery") {
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
              child: GestureDetector(
                onTap: () {
                  context.read<SettingsProvider>().saveBookmarks(
                    widget.getAllPostList[widget.index]['id'].toString(),context
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
    );
  }
}
