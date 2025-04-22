import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../../screens/home_screen/botton_actions.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../reels_provider/reels_providers.dart';

class ReelsCardView extends StatefulWidget {
 final String postId;
  const ReelsCardView({super.key,required this.postId});

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();
  @override
  void initState() {
  context.read<ReelsProviders>().getIndividualReelData(widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReelsProviders>(
          builder: (_,reelsProviders,__) {
          return reelsProviders.isReelDataLoading?AppLoadingScreen(): Stack(
            children: [
              Positioned.fill(
                child: Screenshot(
                  controller: sc,
                  child: YoutubePlayer(
                    controller: reelsProviders.controller,
                    // showVideoProgressIndicator: true,
                    bottomActions: [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true,colors: ProgressBarColors(bufferedColor: Colors.grey,playedColor: Colors.red),),
                      RemainingDuration(),
                      IconButton(
                        icon: Icon(reelsProviders.isMuted ? Icons.volume_off : Icons.volume_up,color: Colors.white,),
                        onPressed: () {
                          if (reelsProviders.isMuted) {
                            reelsProviders.controller.unMute();
                          } else {
                            reelsProviders.controller.mute();
                          }
                          reelsProviders.toggleMute(); // Update your isMuted state
                        },
                      ),// ✅ Show remaining time

                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 100,
                child: Column(
                  children: [
                    BottomActions(
                      iconColor: Colors.white,
                      postType: reelsProviders.reelData.title ?? "",
                      icon: context.read<ReelsProviders>().isLikeList.contains(reelsProviders.reelData.id.toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                      label: 'లైక్',
                      isLike:  context.read<ReelsProviders>().isLikeList.contains(reelsProviders.reelData.id.toString()),
                      onTap: () {
                        log("Like");
                        context.read<ReelsProviders>().isLikePost(reelsProviders.reelData);
                      },
                    ),
                    height(height: 20),
                    BottomActions(
                      postType: "",
                      icon: "assets/svg/new_comment.svg",
                      label: 'కామెంట్',
                      iconColor: Colors.white,
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
                            "postId": reelsProviders.reelData.id.toString(),
                          }
                        });
                        showComments(context, reelsProviders.reelData.id.toString());
                        EventRepo().sendEvent({
                          "key": "comments",
                          "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                        });
                      },
                    ),
                    height(height: 20),
                    BottomActions(
                      postType: "",
                      icon: "assets/svg/share.svg",
                      label: 'షేర్',
                      iconColor: Colors.white,
                      onTap: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        String? userId = sp.getString("userId");
                        String? deviceId = sp.getString("deviceId");
                        EventRepo().sendEvent({
                          "key": "share_via_articles",
                          "data": {
                            "device_id": "$deviceId",
                            "userId": userId ?? "",
                            "postId": reelsProviders.reelData.id.toString(),
                            "isWhatAppShare": false,
                          }
                        });

                        sendShareDetails(userId, reelsProviders.reelData.id, reelsProviders.reelData.content.toString());

                        try {
                          final image = await sc.capture(
                            pixelRatio: 2,
                          );
                          if (image != null) {
                            final directory = await getTemporaryDirectory();
                            final imagePath = '${directory.path}/${reelsProviders.reelData.id}.png';
                            final imageFile = File(imagePath);
                            await imageFile.writeAsBytes(image);

                            Share.shareXFiles([XFile(imageFile.path)], text: reelsProviders.reelData.videoUrl);
                          } else {
                            CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                          }
                        } catch (e) {
                          CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                        }
                      },
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 60.0),
                  child: Container(
                    padding: EdgeInsets.only(right: 12.w,left: 12.w),
                    width: MediaQuery.of(context).size.width-100,
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      //   colors: [
                      //     Colors.black.withOpacity(0.7),
                      //     Colors.transparent,
                      //   ],
                      // ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title (Main Text)
                        Text(
                          reelsProviders.reelData.title ?? "No title",
                          style: newAppFont(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        height(height: 10.h),

                        Row(
                          children: [
                            width(width: 10),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InAppWebViewScreen(
                                        webUrl: "https://www.youtube.com",
                                        title: "Videos",
                                      ),
                                    ));
                              },
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  child: CachedNetworkImage(
                                    imageUrl: reelsProviders.reelData.publisherImage,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.borderColor.withOpacity(.2),
                                    ),
                                    errorWidget: (context, url, error) => Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 30,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            width(width: 6.h),
                            Text(
                              reelsProviders.reelData.publisher,
                              style: fontStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(children: [
                  GestureDetector(
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
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      reelsProviders.isBookMarkPost( reelsProviders.reelData,context);

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
                ],),
              ),
            ],
          );
        }
      ),
    );
  }
}