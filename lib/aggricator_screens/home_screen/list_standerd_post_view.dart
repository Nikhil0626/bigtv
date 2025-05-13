import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import '../../screens/videos_main/video_views/video_preview.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_and _source.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import 'home_provider.dart';
import 'main_screen_pageview.dart';


class ListStandardPostView extends StatefulWidget {
  final articalData;
  final int index;
  const ListStandardPostView({super.key,required this.articalData,required this.index});

  @override
  State<ListStandardPostView> createState() => _ListStandardPostViewState();
}

class _ListStandardPostViewState extends State<ListStandardPostView> {
ScreenshotController screenshotControllers = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotControllers,
      child: Stack(
        children: [
          Container(
            height: 330.h,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundColor, // Unique color per card
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.r),
                        ),
                        child: widget.articalData['type'] == "Video"
                            ? SizedBox(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  height: 330,
                                  width: MediaQuery.of(context).size.width,
                                  widget.articalData['image_url'].toString(),
                                  fit: BoxFit.fill,
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
                            : CachedNetworkImage(
                          imageUrl: widget.articalData['image_url'].toString(),
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            color: AppColors.borderColor.withOpacity(.2),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey.shade200,
                            child: Center(
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
                        top: 10,
                        right: 14,
                        child:  Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                          return GestureDetector(
                              onTap: () {
                                homeProvider.isBookMarkPost(widget.articalData, context);
                                print("");
                              },
                              child: Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: (homeProvider.isBookMark.contains(widget.articalData['id'].toString()) || widget.articalData['isBookmarked'] == 1)
                                      ? AppColors.appButtonColor
                                      : Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (homeProvider.isBookMark.contains(widget.articalData['id'].toString()) || widget.articalData['isBookmarked'] == 1)
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
                  child: Text(
                    widget.articalData['title'],
                    style: fontStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Spacer(),

                if(widget.articalData['isStickyPost']==0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: DateAndSource(data: widget.articalData),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                        return BottomActions(
                          iconColor: AppColors.iconColors,
                          postType: widget.articalData['subType'] ?? "",
                          icon:
                          settingsProvider.isLikeList.contains(widget.articalData['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                          label: 'లైక్',
                          isLike: settingsProvider.isLikeList.contains(widget.articalData['id'].toString()),
                          onTap: () {
                            log("Like");
                            settingsProvider.isLikePost(widget.articalData);
      
                            // flipProvider.isLikePost(widget.articalData);
                          },
                        );
                      }),
      
                      BottomActions(
                        postType: widget.articalData['subType'] ?? "",
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
                              "userId": userId?? "",
                              "postId": widget.articalData['id'].toString(),
                            }
                          });
                          log("Comment --- ${context.read<AuthProvider>().loginType}");
                          showComments(context, widget.articalData['id']);
                          EventRepo().sendEvent({
                            "key": "comments",
                            "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                          });
                        },
                      ),
                      Spacer(),
                      BottomActions(
                        postType: widget.articalData['subType'] ?? "",
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
                              "postId": widget.articalData['id'].toString(),
                              "isWhatAppShare": false,
                              "source_from":"news"
                            }
                          });
      
                          sendShareDetails(userId, widget.articalData['id'], widget.articalData['content'].toString());
      
                          if (widget.articalData['type'] == "Standard" || widget.articalData['type'] == "Video"|| widget.articalData['type'] == "Image" ) {
                            try {
                              final image = await screenshotControllers.capture(
                                pixelRatio: 2,
                              );
                              if (image != null) {
                                final directory = await getTemporaryDirectory();
                                final imagePath = '${directory.path}/${widget.articalData['id']}.png';
                                final imageFile = File(imagePath);
                                await imageFile.writeAsBytes(image);
      
                                Share.shareXFiles([XFile(imageFile.path)], text: widget.articalData['linkURLAndroid'].toString());
                              } else {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                              }
                            } catch (e) {
                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                            }
                          } else if (widget.articalData['type'] == "Gallery") {
                            createAndSharePdf(context, widget.articalData);
                          }
                        },
                      ),
      
                    ],
                  ),
                ),
                height(height: 10)
              ],
            ),
          ),
          Positioned(
            left: 40,
            top: 184,
            child: Container(
              height: 30,
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
