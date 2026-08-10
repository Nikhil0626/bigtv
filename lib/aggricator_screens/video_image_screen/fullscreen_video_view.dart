import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'video_provider.dart';

class FullscreenVideoView extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenVideoView({Key? key, required this.controller}) : super(key: key);

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  bool _showControls = true;
  bool _isExiting = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
  }

  void _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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

  void _exitFullscreen() async {
    if (_isExiting) return;
    _isExiting = true;
    _hideTimer?.cancel();
    await SystemChrome.setPreferredOrientations([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<VideoProvider>(
          builder: (context, videoProvider, __) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 20,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                              onPressed: _exitFullscreen,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 32),
                              onPressed: _exitFullscreen,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    videoProvider.togglePlayPause();
                                    _startHideTimer();
                                  },
                                ),
                                Expanded(
                                  child: VideoProgressIndicator(
                                    widget.controller,
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
                                    videoProvider.isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    videoProvider.toggleMute();
                                    _startHideTimer();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
                                  onPressed: _exitFullscreen,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
