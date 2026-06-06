
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class FullStandardVideoView extends StatefulWidget {
  dynamic reelData;

   FullStandardVideoView({super.key, required this.reelData});

  @override
  State<FullStandardVideoView> createState() => FullStandardVideoViewState();
}

class FullStandardVideoViewState extends State<FullStandardVideoView> {
  ScreenshotController sc = ScreenshotController();
  YoutubePlayerController? ytController;

  @override
  void initState() {
    super.initState();
    ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=${widget.reelData['reel_video_code']}")!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
        hideControls: true,
        loop: false,
        disableDragSeek: false,
        enableCaption: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    ytController?.dispose();
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
              return GestureDetector(
                onVerticalDragUpdate: (details) {
                  final controller = context.read<HomeProvider>().pageController!;

                  if (details.delta.dy < -10) {
                    controller.nextPage(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    );
                  }
                  else if (details.delta.dy > 10) {
                    controller.previousPage(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: YoutubePlayer(
                  controller: ytController!,
                  // showVideoProgressIndicator: true,
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(
                      isExpanded: true,
                      colors: ProgressBarColors(bufferedColor: Colors.grey, playedColor: Colors.red),
                    ),
                    RemainingDuration(),
                    IconButton(
                      icon: Icon(
                        homeProvider.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (homeProvider.isMuted) {
                          ytController?.unMute();
                        } else {
                          ytController?.mute();
                        }
                        homeProvider.toggleMute(); // Update your isMuted state
                      },
                    ), // ✅ Show remaining time
                  ],
                ),
              );
            }),
          ),
        ),
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: Padding(
        //     padding: const EdgeInsets.only(bottom: 10.0,top: 10.0),
        //     child: Container(
        //       padding: EdgeInsets.only(right: 12.w, left: 12.w),
        //       width: MediaQuery.of(context).size.width - 100,
        //       decoration: BoxDecoration(
        //         color:   Colors.black.withOpacity(0.7),
        //           ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           // Title (Main Text)
        //           Text(
        //             widget.rellData['title'] ?? "No title",
        //             style: newAppFont(
        //               fontWeight: FontWeight.w400,
        //               color: Colors.white,
        //               fontSize: 12.sp,
        //             ),
        //             maxLines: 2,
        //             overflow: TextOverflow.ellipsis,
        //           ),
        //           height(height: 10.h),
        //
        //           Row(
        //             children: [
        //               width(width: 10),
        //               InkWell(
        //                 onTap: () {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) => InAppWebViewScreen(
        //                           webUrl: "https://www.youtube.com",
        //                           title: "Videos",
        //                         ),
        //                       ));
        //                 },
        //                 child: SizedBox(
        //                   height: 30,
        //                   width: 30,
        //                   child: ClipRRect(
        //                     borderRadius: BorderRadius.all(Radius.circular(8)),
        //                     child: CachedNetworkImage(
        //                       imageUrl: widget.rellData['reel_channel_avatar'],
        //                       fit: BoxFit.fill,
        //                       placeholder: (context, url) => Container(
        //                         color: AppColors.borderColor.withOpacity(.2),
        //                       ),
        //                       errorWidget: (context, url, error) => Center(
        //                         child: Icon(
        //                           Icons.image,
        //                           size: 30,
        //                           color: Colors.grey.shade300,
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               width(width: 6.h),
        //               Text(
        //                 widget.rellData['reel_channel_title'],
        //                 style: fontStyle(
        //                   color: Colors.white,
        //                   fontSize: 12.sp,
        //                   fontWeight: FontWeight.w600,
        //                 ),
        //               ),
        //
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
