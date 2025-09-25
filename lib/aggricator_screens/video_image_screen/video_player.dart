import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../home_screen/home_provider/home_provider.dart';
import 'video_provider.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;
  final bool isFoldable;
  final String postId;

  const CustomVideoPlayer({
    super.key,
    required this.url,
    required this.imageUrl,
    this.isVideoScreen = false,
    this.isFoldable = false,
    this.postId = '0',
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the URL changed, reinitialize the video
    if (oldWidget.url != widget.url) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Don't dispose the controller here - let the provider handle it
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final videoProvider = context.read<VideoProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        videoProvider.pauseVideo();
        break;
      case AppLifecycleState.resumed:
      // Don't auto-play on resume
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _initializeVideo() {
    // Use a small delay to ensure widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoProvider = context.read<VideoProvider>();
      videoProvider.initializeVideo(widget.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, HomeProvider>(
      builder: (context, videoProvider, homeProvider, __) {
        return GestureDetector(
          onTap: () {
            // Toggle play/pause on tap
            videoProvider.togglePlayPause();
          },
          onVerticalDragUpdate: (details) {
            final controller = context.read<HomeProvider>().pageController!;
            if (details.delta.dy < -10) {
              log("jhvjhbhjbjhhijhiu");
              videoProvider.pauseVideo();
              // videoProvider.controller?.pause();
              controller.nextPage(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeIn,
              );
            } else if (details.delta.dy > 10) {
              log("jhvjhbhjbjhhijhiu000");
              videoProvider.controller?.pause();
              controller.previousPage(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeIn,
              );
            }
          },
          child: videoProvider.isPlaying
              ? Stack(
            alignment: Alignment.center,
            children: [
              /// Video Player
              SizedBox(
                height: 330,
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: videoProvider.controller!.value.aspectRatio,
                  child: VideoPlayer(videoProvider.controller!),
                ),
              ),

              /// Play / Pause button overlay
              if (!videoProvider.isPlaying)
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/play_circle.svg",
                    height: 58,
                    width: 58,
                  ),
                  onPressed: () => videoProvider.playVideo(),
                ),

              /// Video Controls
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    /// Play/Pause Button
                    IconButton(
                      icon: Icon(
                        videoProvider.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () => videoProvider.togglePlayPause(),
                    ),

                    /// Progress Bar
                    Expanded(
                      child: VideoProgressIndicator(
                        videoProvider.controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ),

                    /// Mute Button
                    IconButton(
                      icon: Icon(
                        videoProvider.isMuted
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: videoProvider.toggleMute,
                    ),
                  ],
                ),
              ),
            ],
          )
              : ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.imageUrl,
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/play_circle.svg",
                    height: 58,
                    width: 58,
                  ),
                  onPressed: () {
                    videoProvider.initializeVideo(widget.url).then((_) {
                      videoProvider.playVideo();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}