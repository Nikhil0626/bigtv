import 'dart:developer';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'fullscreen_youtube_view.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;
  final bool isFoldable;
  final String postId;

  const VideoPreview({
    super.key,
    required this.url,
    required this.imageUrl,
    this.isVideoScreen = false,
    this.isFoldable = false,
    this.postId = "0",
  });

  @override
  VideoPreviewPage createState() => VideoPreviewPage();
}

class VideoPreviewPage extends State<VideoPreview> {
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().youtubeInitial(widget.url);
  }

  @override
  void dispose() {
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
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          } else if (details.delta.dy > 10) {
            log("jhvjhbhjbjhhijhiu000");
            homeProvider.isPlayingYoutube(false);
            controller.previousPage(
              duration: const Duration(milliseconds: 600),
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
                      colors: const ProgressBarColors(
                        bufferedColor: Colors.grey,
                        playedColor: Color(0xFFE53935),
                        handleColor: Color(0xFFE53935),
                      ),
                    ),
                    RemainingDuration(),
                    IconButton(
                      icon: Icon(
                        homeProvider.isMuted
                            ? Icons.volume_off
                            : Icons.volume_up,
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
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () {
                        final currentPos = homeProvider.controller.value.position;
                        final wasPlaying = homeProvider.controller.value.isPlaying;
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => FullscreenYoutubeView(
                              controller: homeProvider.controller,
                              initialPosition: currentPos,
                              wasPlaying: wasPlaying,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                          ),
                        ).then((result) {
                          if (result is Map) {
                            final pos = result['position'] as Duration?;
                            final playing = result['wasPlaying'] as bool?;
                            if (pos != null) {
                              homeProvider.controller.seekTo(pos);
                            }
                            if (playing == true) {
                              homeProvider.controller.play();
                            }
                          } else if (wasPlaying) {
                            homeProvider.controller.play();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 120),
                  ],
                ),
                builder: (context, player) => player,
              ),
            ),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.zero,
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
