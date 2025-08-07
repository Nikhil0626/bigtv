import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../home_screen/home_provider/home_provider.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final String imageUrl;
  final bool isVideoScreen;
  final bool isFoldable;
  final String postId;

  VideoPreview({super.key, required this.url, required this.imageUrl, this.isVideoScreen = false, this.isFoldable = false, this.postId = "0"});

  @override
  _VideoPreview createState() => _VideoPreview();
}

class _VideoPreview extends State<VideoPreview> {
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().youtubeInitial(widget.url);
    log("asfdsgsdgds ${widget.url}");
  }

  @override
  void dispose() {
    context.read<HomeProvider>().youtubeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          final controller = context.read<HomeProvider>().pageController!;

          if (details.delta.dy < -10) {
            controller.nextPage(
              duration: Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          } else if (details.delta.dy > 10) {
            controller.previousPage(
              duration: Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          }
        },
        child: homeProvider.isPlaying
            ? YoutubePlayerScaffold(
          controller: context.read<HomeProvider>().controller,
          builder: (context, player) {
            return Container(
              height: 330,
              width: MediaQuery.of(context).size.width,
              child: player,
            );
          },
        )
            : ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                height: 330,
                width: MediaQuery.of(context).size.width,
                widget.imageUrl,
                fit: BoxFit.fill,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/svg/play_circle.svg",
                  height: 58,
                  width: 58,
                ),
                onPressed: () {
                  homeProvider.isPlayingYoutube(true);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}



