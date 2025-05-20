import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_and _source.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import 'main_screen_pageview.dart';

class StandardCard extends StatefulWidget {
  final getAllPostList;
  final index;

  const StandardCard({
    super.key,
    this.getAllPostList,
    required this.index,
  });

  @override
  State<StandardCard> createState() => _StandardCardState();
}

class _StandardCardState extends State<StandardCard> {
  ScreenshotController sc = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: sc,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
              color: AppColors.cardBackgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    child: widget.getAllPostList['type'].toString() == "Video"
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * .35,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    height: 330,
                                    width: MediaQuery.of(context).size.width,
                                    widget.getAllPostList['image_url'].toString(),
                                    fit: BoxFit.fill,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 14,
                                    child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                                      return GestureDetector(
                                        onTap: () {
                                          homeProvider.isBookMarkPost(widget.getAllPostList, context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: (homeProvider.isBookMark.contains(widget.getAllPostList['id'].toString()) || widget.getAllPostList['isBookmarked'] == 1)
                                                ? AppColors.appButtonColor
                                                : Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            (homeProvider.isBookMark.contains(widget.getAllPostList['id'].toString()) || widget.getAllPostList['isBookmarked'] == 1)
                                                ? Icons.bookmark
                                                : Icons.bookmark_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      "assets/svg/play_circle.svg",
                                      height: 58,
                                      width: 58,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainScreenPageView(
                                              startIndex: widget.index,
                                            ),
                                          ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.getAllPostList['image_url'].toString(),
                                height: MediaQuery.of(context).size.height * .35,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                placeholder: (context, url) => Container(
                                  height: MediaQuery.of(context).size.height * .35,
                                  width: MediaQuery.of(context).size.width,
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
                              Positioned(
                                top: 10,
                                right: 14,
                                child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                                  return GestureDetector(
                                    onTap: () {
                                      homeProvider.isBookMarkPost(widget.getAllPostList, context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: (homeProvider.isBookMark.contains(widget.getAllPostList['id'].toString()) || widget.getAllPostList['isBookmarked'] == 1)
                                            ? AppColors.appButtonColor
                                            : Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        (homeProvider.isBookMark.contains(widget.getAllPostList['id'].toString()) || widget.getAllPostList['isBookmarked'] == 1)
                                            ? Icons.bookmark
                                            : Icons.bookmark_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                  ),
                ),
                height(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
                  child: Text(
                    widget.getAllPostList['title'].toString(),
                    style: fontStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Spacer(),
                if(widget.getAllPostList['isStickyPost']==0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: DateAndSource(data: widget.getAllPostList),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                        return BottomActions(
                          iconColor: AppColors.iconColors,
                          postType: widget.getAllPostList['subType'].toString() ?? "",
                          icon: settingsProvider.isLikeList.contains(widget.getAllPostList['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                          label: 'లైక్',
                          isLike: settingsProvider.isLikeList.contains(widget.getAllPostList['id'].toString()),
                          onTap: () {
                            log("Like");
                            settingsProvider.isLikePost(widget.getAllPostList);
                          },
                        );
                      }),
                      BottomActions(
                        postType: widget.getAllPostList['subType'] ?? "",
                        icon: "assets/svg/new_comment.svg",
                        label: 'కామెంట్',
                        iconColor: AppColors.iconColors,
                        onTap: () async {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? userId = sp.getString("userId");
                          String? deviceId = sp.getString("deviceId");
                          context.read<AuthProvider>().sendEvent("CommentPage");
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {
                              "device_id": "$deviceId",
                              "userId": userId ?? "",
                              "postId": widget.getAllPostList['id'].toString(),
                            }
                          });
                          showComments(context, widget.getAllPostList['id']);
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                          });
                        },
                      ),
                      Spacer(),
                      BottomActions(
                        postType: widget.getAllPostList['subType'] ?? "",
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
                              "userId": userId ?? "",
                              "postId": widget.getAllPostList['id'].toString(),
                              "isWhatAppShare": false,
                              "source_from":"news"
                            }
                          });

                          sendShareDetails(userId, widget.getAllPostList['id'], widget.getAllPostList['content'].toString());

                          if (widget.getAllPostList['type'] == "Standard" || widget.getAllPostList['type'] == "Video") {
                            try {
                              final image = await sc.capture(
                                pixelRatio: 2,
                              );
                              if (image != null) {
                                final directory = await getTemporaryDirectory();
                                final imagePath = '${directory.path}/${widget.getAllPostList['id']}.png';
                                final imageFile = File(imagePath);
                                await imageFile.writeAsBytes(image);

                                Share.shareXFiles([XFile(imageFile.path)], text: Platform.isIOS ? widget.getAllPostList['linkURLAndroid'].toString() : widget.getAllPostList['linkURLIos'].toString());
                              } else {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                              }
                            } catch (e) {
                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                            }
                          } else if (widget.getAllPostList['type'] == "Gallery") {
                            createAndSharePdf(context, widget.getAllPostList);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                height(height: 20)
              ],
            ),
          ),
          Positioned(
            left: 30,
            top: widget.getAllPostList['type'].toString() == "Video" ? MediaQuery.of(context).size.height * .35 : MediaQuery.of(context).size.height * .345,
            child: Container(
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Chota ",
                        style: fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "News",
                        style: fontStyle(
                          fontSize: 14,
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
    );
  }
}
