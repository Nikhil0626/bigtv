import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../utils/app_colors.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;

  VideoPreview({super.key, required this.url,required this.imageUrl, this.isVideoScreen = false});

  @override
  _VideoPreview createState() => _VideoPreview();
}

class _VideoPreview extends State<VideoPreview> {
  late YoutubePlayerController controller;
  bool isPlaying = false; // Track whether video has started playing

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: widget.url, // Example YouTube video ID
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: false,
        forceHD: true,
        disableDragSeek: true,
        isLive: false,
      ),
    )..addListener(() {
      if (controller.value.isFullScreen) {
        controller.toggleFullScreenMode(); // Prevent full-screen mode
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? YoutubePlayer(
      onEnded: (metaData) {
        isPlaying = false;
        setState(() {

        });
      },
          controller: controller,
          // showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,

        )
        : Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.imageUrl,
          // "https://img.youtube.com/vi/${widget.url}/hqdefault.jpg",
          fit: BoxFit.cover,
        ),
        IconButton(
          icon: SvgPicture.asset("assets/svg/play_circle.svg",height: 58,width: 58,),
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return isPlaying
        ? Container(
      width: 300, // Set width of the player
      height: 200,
          color: Colors.greenAccent,
          child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,

              ),
        )
        : Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.imageUrl,
          // "https://img.youtube.com/vi/${widget.url}/hqdefault.jpg",
          fit: BoxFit.cover,
        ),
        IconButton(
          icon: SvgPicture.asset("assets/svg/play_circle.svg",height: 58,width: 58,),
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
          },
        ),
      ],
    );
  }
}
