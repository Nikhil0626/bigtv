import 'dart:async';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'video_provider.dart';
import 'fullscreen_video_view.dart';

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
    bool isLoading = false,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with WidgetsBindingObserver {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initializeVideo();
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

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
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _initializeVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoProvider = context.read<VideoProvider>();
      videoProvider.initializeVideo(widget.url);
    });
  }

  void _openFullscreen(BuildContext context, VideoPlayerController controller) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FullscreenVideoView(
          controller: controller,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, HomeProvider>(
      builder: (context, videoProvider, homeProvider, __) {
        return GestureDetector(
          onTap: () {
            _toggleControls();
          },
          onVerticalDragUpdate: (details) {
            final controller = context.read<HomeProvider>().pageController!;
            if (details.delta.dy < -10) {
              videoProvider.pauseVideo();
              controller.nextPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
              );
            } else if (details.delta.dy > 10) {
              videoProvider.controller?.pause();
              controller.previousPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
              );
            }
          },
          child: videoProvider.isPlaying
              ? Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 330,
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: videoProvider.controller!.value.aspectRatio,
                  child: VideoPlayer(videoProvider.controller!),
                ),
              ),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!videoProvider.isPlaying)
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/svg/play_circle.svg",
                            height: 58,
                            width: 58,
                          ),
                          onPressed: () {
                            videoProvider.playVideo();
                            _startHideTimer();
                          },
                        ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                videoProvider.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                videoProvider.togglePlayPause();
                                _startHideTimer();
                              },
                            ),
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
                            IconButton(
                              icon: Icon(
                                videoProvider.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                videoProvider.toggleMute();
                                _startHideTimer();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: () {
                                _openFullscreen(context, videoProvider.controller!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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