import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../reels_provider/reels_providers.dart';

class ReelPreviewScreen extends StatefulWidget {
  final int initialIndex;

  const ReelPreviewScreen({super.key, required this.initialIndex});

  @override
  _ReelPreviewScreenState createState() => _ReelPreviewScreenState();
}

class _ReelPreviewScreenState extends State<ReelPreviewScreen> {
  late PageController _pageController;
  List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsProviders>().getReels();
    });
  }

  String _constructYoutubeUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  @override
  Widget build(BuildContext context) {
    final reelsDataList = context.watch<ReelsProviders>().reelsDataList;


    if (reelsDataList.isNotEmpty && _controllers.length != reelsDataList.length) {
      _controllers = reelsDataList.map((reel) {
        final videoId = reel['videoUrl'];
        final fullUrl = _constructYoutubeUrl(videoId);
        print("Playing video: $fullUrl");

        return YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            forceHD: true,
            enableCaption: false,
            controlsVisibleAtStart: true,
          ),
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: reelsDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: reelsDataList.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: YoutubePlayer(
                  controller: _controllers[index],
                  showVideoProgressIndicator: true,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 70,
                child: Column(
                  children: [
                    _socialIconButton(Icons.thumb_up, "120"),
                    const SizedBox(height: 5),
                    _socialIcon(Icons.comment, "45"),
                    const SizedBox(height: 5),
                    _socialIcon(Icons.share, "30"),
                    const SizedBox(height: 5),
                    _socialIcon(Icons.more_vert, ""),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _socialIconButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: () {
            context.read<ReelsProviders>().postLikes("101");
            print("$icon pressed");
          },
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
