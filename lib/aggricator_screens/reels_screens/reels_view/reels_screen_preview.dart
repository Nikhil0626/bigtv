import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_models/reels_model.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../utils/botton_actions.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../../utils/in_app_web_view.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
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

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    final reelsList = context.read<ReelsProviders>().getAllReelsList;

    _controllers = List.generate(
      reelsList.length,
      (index) {
        // final controller = YoutubePlayerController(
        //   initialVideoId: YoutubePlayer.convertUrlToId(reelsList[index].videoUrl)!,
        //   flags: const YoutubePlayerFlags(
        //     autoPlay: true,
        //     mute: false,
        //     forceHD: true,
        //     loop: false,
        //     disableDragSeek: true,
        //     enableCaption: false,
        //     controlsVisibleAtStart: true,
        //   ),
        // );

        final controller = YoutubePlayerController(

          params: const YoutubePlayerParams(
            showControls: false,
            mute: false,
            showFullscreenButton: true,
            loop: false,
            enableCaption: false,
            showVideoAnnotations: false,
            strictRelatedVideos: false,
            interfaceLanguage: 'en',
          ),
        );
        controller.loadVideoById(videoId: reelsList[index].videoUrl.toString().split("=").last.toString());

        controller.listen((event) {
          if (event.playerState == PlayerState.ended) {
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
    currentIndex = 0;
  }

  @override
  void dispose() {
    // _controllers = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ReelsProviders>(builder: (_, reelsProviders, __) {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: reelsProviders.getAllReelsList.length,
          onPageChanged: (value) async {
            context.read<HomeProvider>().flipEvent('reel', reelsProviders.getAllReelsList[value].id, value > currentIndex ? false : true);
            currentIndex = value;
            log(currentIndex.toString());
            for (var i = 0; i < _controllers.length; i++) {
              if (i == value) {
                _controllers[i].playVideo();
              } else {
                _controllers[i].pauseVideo();
              }
            }
            EventRepo().addEvent({
              "postid": reelsProviders.getAllReelsList[value].id,
              "createAt": DateTime.now().toString(),
              "postTitle": reelsProviders.getAllReelsList[value].title.toString(),
            }, "reel_viewed");
          },
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ReelsCardView(

                  youtubePlayerController: _controllers[index], reelCard: reelsProviders.getAllReelsList[index]),
            );
          },
        );
      }),
    );
  }
}

class ReelsCardView extends StatefulWidget {
  final YoutubePlayerController youtubePlayerController;
  final ReelsModel reelCard;

  const ReelsCardView({super.key, required this.youtubePlayerController, required this.reelCard});

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();

  @override
  void dispose() {
    // widget.youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Screenshot(
            controller: sc,
            child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
              return YoutubePlayer(
                controller: widget.youtubePlayerController,
                // showVideoProgressIndicator: true,
                // bottomActions: [
                //   CurrentPosition(),
                //   ProgressBar(
                //     isExpanded: true,
                //     colors: ProgressBarColors(bufferedColor: Colors.grey, playedColor: Colors.red),
                //   ),
                //   RemainingDuration(),
                //
                //   IconButton(
                //     icon: Icon(
                //       homeProvider.isMuted ? Icons.volume_off : Icons.volume_up,
                //       color: Colors.white,
                //     ),
                //     onPressed: () {
                //       if (homeProvider.isMuted) {
                //         widget.youtubePlayerController.unMute();
                //
                //       } else {
                //         widget.youtubePlayerController.mute();
                //       }
                //       homeProvider.toggleMute(); // Update your isMuted state
                //     },
                //   ), // ✅ Show remaining time
                // ],
              );
            }),
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
                isLike: context.read<ReelsProviders>().isLikeList.contains(widget.reelCard.id.toString()),
                onTap: () async {
                  log("Like");
                  context.read<ReelsProviders>().isLikePost(widget.reelCard);
                  EventRepo().addEvent({
                    "like": !context.read<ReelsProviders>().isLikeList.contains(widget.reelCard.id.toString()),
                    "postId": widget.reelCard.id.toString() ?? "000",
                    "createAt": DateTime.now().toString(),
                    "postTitle": widget.reelCard.title.toString()
                  }, "liked_article");
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
                  context.read<AuthenticationProvider>().sendEvent("CommentPage");

                  showComments(
                    context,
                    widget.reelCard.id.toString(),
                    widget.reelCard.title.toString(),
                  );
                },
              ),
              height(height: 20),
              BottomActions(
                postType: "",
                icon: "assets/svg/share.svg",
                label: 'షేర్',
                iconColor: Colors.white,
                onTap: () async {
                  print("Share");

                  EventRepo().addEvent({
                    "share": "reels",
                    "postId": widget.reelCard.id.toString() ?? "000", // ✅ postId converted to String
                    "createAt": DateTime.now().toString(),
                    "postTitle": widget.reelCard.title.toString()
                  }, "shared_article");

                  SharedPreferences sp = await SharedPreferences.getInstance();
                  String? userId = sp.getString("userId");
                  String? deviceId = sp.getString("deviceId");

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
          bottom: 50,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              padding: EdgeInsets.only(right: 12.w, left: 12.w),
              width: MediaQuery.of(context).size.width - 100,
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
        // Positioned(
        //   top: 50,
        //   left: 20,
        //   child: GestureDetector(
        //     onTap: () {
        //       widget.youtubePlayerController.pause();
        //       widget.youtubePlayerController.dispose();
        //       Navigator.pop(context);
        //     },
        //     child: Container(
        //       padding: EdgeInsets.all(7),
        //       decoration: BoxDecoration(
        //         color: Colors.black54,
        //         shape: BoxShape.circle,
        //       ),
        //       child: Icon(
        //         Icons.arrow_back,
        //         color: Colors.white,
        //         size: 20,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
