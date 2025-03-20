import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


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
        forceHD: false,
        disableDragSeek: true,
        isLive: false,
      ),
    )..addListener(() {

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
        ? Container(
      width: MediaQuery.of(context).size.width, // Fixed width
      height: 280, // Fixed height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: controller,
          onEnded: (metaData) {
            isPlaying= false;
            setState(() {

            });
          },
          showVideoProgressIndicator: false,
          onReady: () => debugPrint("YouTube Player Ready"),
        ),
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
           isPlaying= true;
           setState(() {

           });
          },
        ),
      ],
    );
  }

}
