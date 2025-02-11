import 'dart:developer';

import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';

class ReelsViewScreen extends StatefulWidget {
  final String getReelDetails;
  // Pass "youtube" or "reel" to force the layout type.
  final String videoType;

  const ReelsViewScreen({
    super.key,
    required this.getReelDetails,
    required this.videoType,
  });

  @override
  State<ReelsViewScreen> createState() => _ReelsViewScreenState();
}
class _ReelsViewScreenState extends State<ReelsViewScreen> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    log("Reel URL: ${widget.getReelDetails}");

    _controller = VideoPlayerController.network(widget.getReelDetails)
      ..initialize().then((_) {
        setState(() {}); // Update UI when video is ready
      })
      ..addListener(() {
        // Reset play state when video ends
        if (_controller.value.position >= _controller.value.duration) {
          setState(() {
            isPlaying = false;
          });
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();
    }
    setState(() {
      isPlaying = _controller.value.isPlaying;
    });
  }
  void seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }
  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Determine layout type:
    bool isYoutubeType = false;
    if (_controller.value.isInitialized) {
      // Check video duration – more than 60 seconds indicates YouTube type.
      isYoutubeType = _controller.value.duration.inSeconds > 30;
    }
    // Override based on widget.videoType if passed
    if (widget.videoType.toLowerCase() == "youtube") {
      isYoutubeType = true;
    } else if (widget.videoType.toLowerCase() == "reel") {
      isYoutubeType = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            color: Colors.white,
            Icons.arrow_back_ios,
            size: 18,
          ),
        ),
        backgroundColor: AppColors.appButtonColor,
        title: Text(
          isYoutubeType ? "YouTube View" : "Reels View",
          style: fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Display
          _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const Center(child: CircularProgressIndicator()),
          // Right side action icons (common to both types)
          Positioned(
            bottom: 100,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                height(height: 20),
                const Icon(Icons.favorite_border,
                    color: Colors.white, size: 20),
                height(height: 5),
                 Text('2000',
                    style: fontStyle(color: Colors.white, fontSize: 12)),
                height(height: 30),
                const Icon(Icons.comment, color: Colors.white, size: 35),
                height(height: 5),
                 Text('4500',
                    style: fontStyle(color: Colors.white, fontSize: 12)),
                height(height: 30),
                const Icon(Icons.send_rounded, color: Colors.white, size: 35),
                height(height: 5),
                 Text('8900',
                    style: fontStyle(color: Colors.white, fontSize: 12)),
                height(height: 30),
                const Icon(Icons.more_horiz_outlined,
                    color: Colors.white, size: 35),
                height(height: 5),
              ],
            ),
          ),
          // Bottom control overlay with progress slider, play/pause, and skip buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _controller.value.isInitialized
                ? Container(
              color: Colors.black45,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Slider
                  Row(
                    children: [
                      // Current position text
                      Text(
                        _formatDuration(_controller.value.position),
                        style:  fontStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                          min: 0.0,
                          max: _controller.value.duration.inMilliseconds
                              .toDouble(),
                          value: _controller.value.position.inMilliseconds
                              .toDouble()
                              .clamp(
                            0.0,
                            _controller.value.duration.inMilliseconds
                                .toDouble(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _controller.seekTo(Duration(
                                  milliseconds: value.toInt()));
                            });
                          },
                        ),
                      ),
                      // Duration text
                      Text(
                        _formatDuration(_controller.value.duration),
                        style:  fontStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  // Control Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 10 Seconds Backward
                      IconButton(
                        onPressed: () =>
                            seekRelative(const Duration(seconds: -10)),
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 30),
                      ),
                      // Play/Pause Button
                      IconButton(
                        onPressed: togglePlayPause,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      // 10 Seconds Forward
                      IconButton(
                        onPressed: () =>
                            seekRelative(const Duration(seconds: 10)),
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
