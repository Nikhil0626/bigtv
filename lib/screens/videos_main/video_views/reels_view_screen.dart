import 'dart:developer';

import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../vodeo_bloc/videos_bloc.dart';
import '../vodeo_bloc/videos_event.dart';

class ReelsViewScreen extends StatefulWidget {
  final String getReelDetails;

  const ReelsViewScreen({super.key, required this.getReelDetails});

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
        if (_controller.value.position >= _controller.value.duration) {
          setState(() {
            isPlaying = false; // Reset play state when video ends
          });
        }
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

  @override
  Widget build(BuildContext context) {
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
          "Reels View",
          style: fontStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
          if (!isPlaying)
            Positioned.fill(
              child: Center(
                child: InkWell(
                  onTap: togglePlayPause,
                  child: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 70,
                    color: Colors.lightBlue.shade50,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPlaying)
                  InkWell(
                    onTap: togglePlayPause,
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 40,
                      color: Colors.lightBlue.shade50,
                    ),
                  ),
                 height(height: 20),
                const Icon(Icons.favorite_border,
                    color: Colors.white, size: 35),
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
        ],
      ),
    );
  }
}
