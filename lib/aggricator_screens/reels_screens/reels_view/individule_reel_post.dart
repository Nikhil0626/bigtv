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

