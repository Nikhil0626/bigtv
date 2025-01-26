import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../videos_model/videos_model.dart';

class ReelsViewScreen extends StatefulWidget {
  final String getReelDetails;

  const ReelsViewScreen({super.key, required this.getReelDetails});

  @override
  State<ReelsViewScreen> createState() => _ReelsViewScreenState();
}

class _ReelsViewScreenState extends State<ReelsViewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.getReelDetails != null) {
      log(widget.getReelDetails);
      _controller = VideoPlayerController.network(
          widget.getReelDetails.toString())
        ..initialize().then((_) {
          setState(() {});
        })
        ..addListener(() {
          if (_controller?.value.position == _controller?.value.duration) {
            setState(() {});
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_controller?.value.isInitialized ?? false)
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                Positioned.fill(
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        if (_controller != null) {
                          if (_controller!.value.isPlaying) {
                            _controller?.pause();
                          } else {
                            if (_controller?.value.position ==
                                _controller?.value.duration) {
                              _controller?.seekTo(Duration.zero);
                              _controller?.play();
                            } else {
                              _controller?.play();
                            }
                          }
                          setState(() {});
                        }
                      },
                      child: Icon(
                        _controller?.value.isPlaying ?? false
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 70,
                        color: Colors.lightBlue.shade50,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.favorite_border,
                              color: Colors.white, size: 35),
                          SizedBox(height: 5),
                          Text(
                            '2000',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Icon(Icons.comment, color: Colors.white, size: 35),
                          SizedBox(height: 5),
                          Text(
                            '4500',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Icon(Icons.send_rounded,
                              color: Colors.white, size: 35),
                          SizedBox(height: 5),
                          Text(
                            '8900',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Icon(Icons.more_horiz_outlined,
                              color: Colors.white, size: 35),
                          SizedBox(height: 5),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Text(
          //     widget.getReelDetails.title ?? "No Title",
          //     style: const TextStyle(
          //       fontSize: 15,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
