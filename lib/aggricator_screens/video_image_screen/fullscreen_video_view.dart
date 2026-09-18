import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'video_provider.dart';

class FullscreenVideoView extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenVideoView({super.key, required this.controller});

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  final ValueNotifier<bool> _showControlsNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _showControlsNotifier.dispose();
    // Failsafe in case of swipe back
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    // Add a tiny delay to allow the engine to flush the layout
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggleControls() {
    _showControlsNotifier.value = !_showControlsNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<VideoProvider>(
          builder: (context, videoProvider, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleControls,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showControlsNotifier,
                  builder: (context, showControls, _) {
                    return AnimatedOpacity(
                      opacity: showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !showControls,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          left: 20,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 30),
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
                                  videoProvider.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => videoProvider.togglePlayPause(),
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
                                  videoProvider.isMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: videoProvider.toggleMute,
                              ),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit,
                                    color: Colors.white, size: 30),
                                onPressed: _exitFullscreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}
}
