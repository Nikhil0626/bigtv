import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../utils/app_colors.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final bool isVideoScreen;

  VideoPreview({super.key, required this.url, this.isVideoScreen = false});

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
      initialVideoId: widget.url,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
        hideControls: true, // This hides fullscreen button
      ),
    );
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
          "https://img.youtube.com/vi/${widget.url}/hqdefault.jpg",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        IconButton(
          icon: Icon(Icons.play_circle_filled, size: 70, color: Colors.blue),
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
