import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_models/reels_model.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_preview.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../../utils/date_format.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    context.read<ReelsProviders>().getAllReelsList =[];
    context.read<ReelsProviders>().getAllReels();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ReelsProviders>(builder: (_, reelsProvider, __) {
        return reelsProvider.reelsLoading
            ? AppLoadingScreen()
            : reelsProvider.getAllReelsList.isEmpty
                ? AppNoData()
                : CardSwiper(
                    allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                    cardsCount: reelsProvider.getAllReelsList.length,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      print("Swiped from $previousIndex to $currentIndex");
                      return true;
                    },
                    numberOfCardsDisplayed: 4,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      final reel = reelsProvider.getAllReelsList[index];
                      return EachReelCard(reel: reel, reelsProvider: reelsProvider,index:index);
                    },
                  );
      }),
    );
  }
}

class EachReelCard extends StatefulWidget {
  final ReelsModel reel;
  final ReelsProviders reelsProvider;
  final int index;

  EachReelCard({super.key, required this.reel, required this.reelsProvider,required this.index});

  @override
  State<EachReelCard> createState() => _EachReelCardState();
}

class _EachReelCardState extends State<EachReelCard> {
  ScreenshotController sc = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: (){

    },
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReelPreviewScreen(initialIndex: widget.index,),));
        },
        child: Screenshot(
          controller: sc,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20.r)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                          child: CachedNetworkImage(
                            imageUrl: widget.reel.thumbnailUrl.toString(),
                            height: MediaQuery.of(context).size.height * .6,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: MediaQuery.of(context).size.height * .6,
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
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                        decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )),
                        child: Row(
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
                                    imageUrl: widget.reel.publisherImage,
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
                              widget.reel.publisher,
                              style: fontStyle(
                                color: AppColors.bodyTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              " ● ",
                              style: fontStyle(
                                color: AppColors.borderColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              " ${formatTimeDifference(widget.reel.createdAt.toString())}",
                              style: fontStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                            ),
                            width(width: 15.w),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 16.h, top: 6.h, left: 10.sp, right: 10.sp),
                        decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BottomActions(
                              iconColor: AppColors.iconColors,
                              postType: widget.reel.postName ?? "",
                              icon: widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                              label: 'లైక్',
                              isLike: widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()),
                              onTap: () {
                                log("Like");
                                widget.reelsProvider.isLikePost(widget.reel);
                              },
                            ),
                            BottomActions(
                              postType: "",
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
                                    "postId": widget.reel.id.toString(),
                                  }
                                });
                                showComments(context, widget.reel.id.toString());
                                EventRepo().sendEvent({
                                  "key": "comments",
                                  "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                                });
                              },
                            ),
                            Spacer(),
                            BottomActions(
                              postType: "",
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
                                    "postId": widget.reel.id.toString(),
                                    "isWhatAppShare": false,
                                  }
                                });

                                sendShareDetails(userId, widget.reel.id, widget.reel.content.toString());

                                try {
                                  final image = await sc.capture(
                                    pixelRatio: 2,
                                  );
                                  if (image != null) {
                                    final directory = await getTemporaryDirectory();
                                    final imagePath = '${directory.path}/${widget.reel.id}.png';
                                    final imageFile = File(imagePath);
                                    await imageFile.writeAsBytes(image);

                                    Share.shareXFiles([XFile(imageFile.path)], text: widget.reel.videoUrl);
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
                      // height(height: 20.sp)
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 14,
                  child: GestureDetector(
                    onTap: () {
                      context.read<SettingsProvider>().saveBookmarks(
                            widget.reel.id.toString(),context
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
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
