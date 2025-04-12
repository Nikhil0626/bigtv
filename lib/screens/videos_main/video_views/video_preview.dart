import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;
  final bool isFoldable;

  VideoPreview({super.key, required this.url, required this.imageUrl, this.isVideoScreen = false, this.isFoldable = false});

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
        forceHD: false,
        disableDragSeek: true,
        isLive: false,

        showLiveFullscreenButton: false,
        // hideControls: true,
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
    return isPlaying
        ? Container(
            width: MediaQuery.of(context).size.width, // Fixed width
            height: 330, // Fixed height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: controller,
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(isExpanded: true),
                  RemainingDuration(), // ✅ Show remaining time
                  IconButton(
                    icon: Icon(controller.value.volume == 0 ? Icons.volume_off : Icons.volume_up),
                    onPressed: () {
                      if (controller.value.volume == 0) {
                        controller.setVolume(100); // ✅ Unmute
                      } else {
                        controller.setVolume(0); // ✅ Mute
                      }
                    },
                  ),
                ],
                onEnded: (metaData) {
                  isPlaying = false;
                  setState(() {});
                },
                showVideoProgressIndicator: false,
                onReady: () => debugPrint("YouTube Player Ready"),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  height: 330,
                  widget.imageUrl,
                  // "https://img.youtube.com/vi/${widget.url}/hqdefault.jpg",
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/play_circle.svg",
                    height: 58,
                    width: 58,
                  ),
                  onPressed: () {
                    isPlaying = true;
                    setState(() {});
                  },
                ),
              ],
            ),
          );
  }
}
