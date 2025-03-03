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
    return widget.isVideoScreen
        ? SafeArea(
      child: Scaffold(
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
            "Video View",
            style: fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
        body: Center(child: _buildVideoPlayer()),
      ),
    )
        : _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    return isPlaying
        ? YoutubePlayer(

      controller: controller,
      showVideoProgressIndicator: true,
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
}
