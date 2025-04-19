import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_models/reels_model.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../reels_provider/reels_providers.dart';

class ReelPreviewScreen extends StatefulWidget {
  final int initialIndex;

  const ReelPreviewScreen({super.key, required this.initialIndex});

  @override
  _ReelPreviewScreenState createState() => _ReelPreviewScreenState();
}

class _ReelPreviewScreenState extends State<ReelPreviewScreen> {
  late PageController _pageController;
  late List<YoutubePlayerController> _controllers;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    final reelsList  = context.read<ReelsProviders>().getAllReelsList;

    _controllers = List.generate(
      reelsList.length,
          (index) {
        final controller = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(reelsList[index].videoUrl)!,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            forceHD: true,
            loop: false,
            disableDragSeek: true,
            enableCaption: false,
            controlsVisibleAtStart: true,
          ),
        );

        controller.addListener(() {
          final playerState = controller.value.playerState;
          if (playerState == PlayerState.ended) {
            // Play next video
            if (index < reelsList.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          }
        });

        return controller;
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _pageController = PageController(initialPage: widget.initialIndex);
  //
  //   _controllers = List.generate(
  //     context.read<ReelsProviders>().getAllReelsList.length,
  //     (index) => YoutubePlayerController(
  //       initialVideoId: YoutubePlayer.convertUrlToId(context.read<ReelsProviders>().getAllReelsList[index].videoUrl)!,
  //       flags: const YoutubePlayerFlags(
  //         autoPlay: true,
  //         mute: false,
  //         forceHD: true,
  //         loop: false,
  //         disableDragSeek: true,
  //         enableCaption: false,
  //         controlsVisibleAtStart: true,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReelsProviders>(builder: (_, reelsProviders, __) {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: reelsProviders.getAllReelsList.length,
          onPageChanged: (value) {
            // Pause all except current
            for (var i = 0; i < _controllers.length; i++) {
              if (i == value) {
                _controllers[i].play();
              } else {
                _controllers[i].pause();
              }
            }
          },
          itemBuilder: (context, index) {
            return ReelsCardView(youtubePlayerController: _controllers[index], reelCard: reelsProviders.getAllReelsList[index]);
          },
        );
      }),
    );
  }


}


class ReelsCardView extends StatefulWidget {
  final YoutubePlayerController youtubePlayerController;
  final ReelsModel reelCard;
  const ReelsCardView({super.key,required this.youtubePlayerController,required this.reelCard});


  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Screenshot(
            controller: sc,
            child: Consumer<HomeProvider>(
              builder: (_,homeProvider,__) {
                return YoutubePlayer(
                  controller: widget.youtubePlayerController,
                  // showVideoProgressIndicator: true,
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(isExpanded: true,colors: ProgressBarColors(bufferedColor: Colors.grey,playedColor: Colors.red),),
                    RemainingDuration(),
                    IconButton(
                      icon: Icon(homeProvider.isMuted ? Icons.volume_off : Icons.volume_up,color: Colors.white,),
                      onPressed: () {
                        if (homeProvider.isMuted) {
                          widget.youtubePlayerController.unMute();
                        } else {
                          widget.youtubePlayerController.mute();
                        }
                      homeProvider.toggleMute(); // Update your isMuted state
                      },
                    ),// ✅ Show remaining time
                  ],
                );
              }
            ),
          ),
        ),

        Positioned(
          top: 50,
          right: 14,
          child: GestureDetector(
            onTap: () {
              context.read<SettingsProvider>().saveBookmarks(
                widget.reelCard.id.toString(),
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
                size: 30,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 14,
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back, // Back icon
                color: Colors.white,
                size: 24,
              ),
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
                postType: widget.reelCard.postName ?? "",
                icon: context.read<ReelsProviders>().isLikeList.contains(widget.reelCard.id.toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                label: 'లైక్',
                isLike:  context.read<ReelsProviders>().isLikeList.contains(widget.reelCard.id.toString()),
                onTap: () {
                  log("Like");
                  context.read<ReelsProviders>().isLikePost(widget.reelCard);
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
                      "postId": widget.reelCard.id.toString(),
                    }
                  });
                  showComments(context, widget.reelCard.id.toString());
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
                      "postId": widget.reelCard.id.toString(),
                      "isWhatAppShare": false,
                    }
                  });

                  sendShareDetails(userId, widget.reelCard.id, widget.reelCard.content.toString());

                  try {
                    final image = await sc.capture(
                      pixelRatio: 2,
                    );
                    if (image != null) {
                      final directory = await getTemporaryDirectory();
                      final imagePath = '${directory.path}/${widget.reelCard.id}.png';
                      final imageFile = File(imagePath);
                      await imageFile.writeAsBytes(image);

                      Share.shareXFiles([XFile(imageFile.path)], text: widget.reelCard.videoUrl);
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
                    widget.reelCard.title ?? "No title",
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
                              imageUrl: widget.reelCard.publisherImage,
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
                        widget.reelCard.publisher,
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
      ],
    );
  }
}
