import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FullscreenYoutubeView extends StatefulWidget {
  final YoutubePlayerController controller;
  final Duration? initialPosition;
  final bool wasPlaying;

  const FullscreenYoutubeView({
    super.key,
    required this.controller,
    this.initialPosition,
    this.wasPlaying = true,
  });

  @override
  State<FullscreenYoutubeView> createState() => _FullscreenYoutubeViewState();
}

class _FullscreenYoutubeViewState extends State<FullscreenYoutubeView> {
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition != null) {
        widget.controller.seekTo(widget.initialPosition!);
      }
      if (widget.wasPlaying) {
        widget.controller.play();
      }
    });
  }

  void _setLandscapeOrientation() async {
    // Reset orientation constraints first for iOS UIKit compatibility
    await SystemChrome.setPreferredOrientations([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _exitFullscreen() async {
    if (_isExiting) return;
    _isExiting = true;
    final currentPos = widget.controller.value.position;
    final wasPlaying = widget.controller.value.isPlaying;

    // Reset constraints first, then set portrait
    await SystemChrome.setPreferredOrientations([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    if (mounted) {
      Navigator.of(context).pop({
        'position': currentPos,
        'wasPlaying': wasPlaying,
      });
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
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: YoutubePlayer(
                controller: widget.controller,
                showVideoProgressIndicator: true,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
