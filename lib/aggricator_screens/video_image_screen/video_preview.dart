import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../home_screen/home_provider/home_provider.dart';
class VideoPreview extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;
  final bool isFoldable;
  final String postId;

  VideoPreview({
    super.key,
    required this.url,
    required this.imageUrl,
    this.isVideoScreen = false,
    this.isFoldable = false,
    this.postId = "0",
  });

  @override
  _VideoPreview createState() => _VideoPreview();
}

class _VideoPreview extends State<VideoPreview> {
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().youtubeInitial(widget.url);
  }

  @override
  void dispose() {
    // context.read<HomeProvider>().controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          final controller = context.read<HomeProvider>().pageController!;
          if (details.delta.dy < -10) {

            log("jhvjhbhjbjhhijhiu");
            homeProvider.isPlayingYoutube(false);
            controller.nextPage(
              duration: Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          } else if (details.delta.dy > 10) {
            log("jhvjhbhjbjhhijhiu000");
            homeProvider.isPlayingYoutube(false);
            controller.previousPage(
              duration: Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          }
        },
        child: homeProvider.isPlaying
            ? Stack(
          children: [
            SizedBox(
              height: 330,
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: homeProvider.controller,
                  showVideoProgressIndicator: true,
                  onReady: () => debugPrint("YouTube Player Ready"),
                  onEnded: (metaData) {
                    homeProvider.isPlayingYoutube(false);
                  },
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(
                        isExpanded: true,
                    colors: ProgressBarColors(bufferedColor: Colors.grey, playedColor: Colors.red)),
                    RemainingDuration(),
                    IconButton(
                      icon: Icon(
                        homeProvider.isMuted ? Icons.volume_off : Icons.volume_up,
                      ),
                      onPressed: () {
                        if (homeProvider.isMuted) {
                          homeProvider.controller.unMute();
                        } else {
                          homeProvider.controller.mute();
                        }
                        homeProvider.toggleMute();
                      },
                    ),
                  ],
                ),
                builder: (context, player) => player,
              ),
            ),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                height: 330,
                width: MediaQuery.of(context).size.width,
                widget.imageUrl,
                fit: BoxFit.fill,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/svg/play_circle.svg",
                  height: 58,
                  width: 58,
                ),
                onPressed: () {
                  homeProvider.isPlayingYoutube(true);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
