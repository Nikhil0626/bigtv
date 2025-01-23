import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../videos_model/videos_model.dart';

class VideoPreview extends StatefulWidget {
  final GetAllVideosModel videoPreviewData;

  const VideoPreview({super.key, required this.videoPreviewData});

  @override
  _VideoPreview createState() => _VideoPreview();
}
class _VideoPreview extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    print(widget.videoPreviewData.videoUrl?.url.toString());
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoPreviewData.videoUrl!.url.toString()))
      ..initialize().then((_) {
        setState(() {});
      })
      ..addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          setState(() {});
        }
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(

            child: Stack(
              fit: StackFit.expand,
              children: [
                _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : Container(),
                Positioned.fill(
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          if (_controller.value.position ==
                              _controller.value.duration) {
                            _controller.seekTo(Duration.zero);
                            _controller.play();
                          } else {
                            _controller.play();
                          }
                        }
                        setState(() {});
                      },
                      child: Icon(
                        _controller.value.isPlaying ||
                                _controller.value.position ==
                                    _controller.value.duration
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 70,
                        color: Colors.lightBlue.shade50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
