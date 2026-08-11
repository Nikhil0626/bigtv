
import 'dart:developer';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class ReelsCardView extends StatefulWidget {
  final String postId;

  const ReelsCardView({super.key, required this.postId});

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();
  final ValueNotifier<YoutubePlayerController?> _controllerNotifier = ValueNotifier<YoutubePlayerController?>(null);

  @override
  void initState() {
    super.initState();

    context.read<ReelsProviders>().getIndividualReelData(widget.postId).then((value) {
      log(value.toString());
      final videoId = YoutubePlayer.convertUrlToId(value.videoUrl) ?? value.videoUrl;
      if (videoId.isNotEmpty) {
        _controllerNotifier.value = YoutubePlayerController(
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
      }
    });
  }

  @override
  void dispose() {
    _controllerNotifier.value?.dispose(); // Dispose properly
    _controllerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReelsProviders>(builder: (_, reelsProviders, __) {
        return ValueListenableBuilder<YoutubePlayerController?>(
          valueListenable: _controllerNotifier,
          builder: (context, controller, child) {
            if (reelsProviders.isReelDataLoading || controller == null) {
              return AppLoadingScreen();
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Screenshot(
                    controller: sc,
                    child: YoutubePlayer(
                      controller: controller,
                      aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
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
                              controller.unMute();
                            } else {
                              controller.mute();
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
          },
        );
      }),
    );
  }
}

