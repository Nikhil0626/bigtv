import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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



  @override
  void initState() {
    super.initState();
   context.read<HomeProvider>().youtubeInitial(widget.url);

  }

  @override
  void dispose() {
    context.read<HomeProvider>().youtubeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return homeProvider.isPlaying
            ? Container(
                width: MediaQuery.of(context).size.width, // Fixed width
                height: 330, // Fixed height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YoutubePlayer(
                    controller: homeProvider.controller,
                    bottomActions: [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true),
                      RemainingDuration(), // ✅ Show remaining time
                      IconButton(
                        icon: Icon(homeProvider.controller.value.volume == 0 ? Icons.volume_off : Icons.volume_up),
                        onPressed: () {
                          if (homeProvider.controller.value.volume == 0) {
                            homeProvider.controller.setVolume(100); // ✅ Unmute
                          } else {
                            homeProvider.controller.setVolume(0); // ✅ Mute
                          }
                        },
                      ),
                    ],
                    onEnded: (metaData) {
                      homeProvider.isPlayingYoutube(false);
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
              );
      }
    );
  }
}
