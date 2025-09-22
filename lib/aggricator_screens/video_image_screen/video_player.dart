import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
    this.postId = "0",
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.url != null) {
        context.read<VideoProvider>().initializeVideo(widget.url);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, _) {
        final controller = videoProvider.controller;

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -10) {
              log("Swipe Up: Go to next video");
              // Example: navigate to next video
            } else if (details.delta.dy > 10) {
              log("Swipe Down: Go to previous video");
              // Example: navigate to previous video
            }
          },
          child: controller != null && controller.value.isInitialized
              ? Stack(
            alignment: Alignment.center,
            children: [
              /// Video Player
              SizedBox(
                height: 330,
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
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
                  onPressed: videoProvider.togglePlayPause,
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
                      onPressed: videoProvider.togglePlayPause,
                    ),

                    /// Progress Bar
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
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
              : /// Show thumbnail before video initializes
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.imageUrl,
                  height: 330,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/play_circle.svg",
                    height: 58,
                    width: 58,
                  ),
                  onPressed: () {
                    videoProvider.togglePlayPause();
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



// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class DirectVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//
//   DirectVideoPlayer({required this.videoUrl});
//
//   @override
//   _DirectVideoPlayerState createState() => _DirectVideoPlayerState();
// }
//
// class _DirectVideoPlayerState extends State<DirectVideoPlayer> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {}); // refresh after video initializes
//         _controller.play();
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text("Twitter Video")),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: VideoPlayer(_controller),
//         )
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }
