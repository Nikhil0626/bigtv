
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../reels_provider/reels_providers.dart';

class ReelsCardView extends StatefulWidget {
  final String postId;

  const ReelsCardView({super.key, required this.postId});

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();
  YoutubePlayerController? controller;

  @override
  void initState() {
    super.initState();
    context.read<ReelsProviders>().getIndividualReelData(widget.postId).then((value) {
      print(value.toString());
      final videoId = YoutubePlayer.convertUrlToId(value.videoUrl);
      if (videoId != null) {
        controller = YoutubePlayerController(
          initialVideoId: videoId,
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
        setState(() {}); // Refresh UI after controller is ready
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose(); // Dispose properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReelsProviders>(builder: (_, reelsProviders, __) {
        if (reelsProviders.isReelDataLoading || controller == null) {
          return AppLoadingScreen();
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Screenshot(
                controller: sc,
                child: YoutubePlayer(
                  controller: controller!,
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(
                      isExpanded: true,
                      colors: ProgressBarColors(bufferedColor: Colors.grey, playedColor: Colors.red),
                    ),
                    RemainingDuration(),
                    IconButton(
                      icon: Icon(
                        reelsProviders.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (reelsProviders.isMuted) {
                          controller?.unMute();
                        } else {
                          controller?.mute();
                        }
                        reelsProviders.toggleMute();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ... other Positioned widgets
          ],
        );
      }),
    );
  }
}

