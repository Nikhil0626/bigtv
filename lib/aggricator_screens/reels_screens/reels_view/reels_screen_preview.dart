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
  late List<YoutubePlayerController> _controllers;

  final List<Map<String, dynamic>> _cardData = [
    {
      'postid': '101',
      'text': 'Rohith Sharma',
      'subtext': 'BIG TV',
      'url': 'https://www.youtube.com/watch?v=D7DYyHbDJE4'
    },
    {
      'postid': '102',
      'text': 'Virat Kohli',
      'subtext': 'V6 Telugu',
      'url': 'https://youtube.com/shorts/kjqKDjjLuc8?si=e-KfiWAwHEm0mXWY'
    },
    {
      'postid': '103',
      'text': 'Sachin Tendulkar',
      'subtext': 'BIG TV',
      'url': 'https://www.youtube.com/watch?v=tyC7zT5xWkE'
    },
    {
      'postid': '104',
      'text': 'MS Dhoni',
      'subtext': 'BIG TV',
      'url': 'https://www.youtube.com/watch?v=AsPdLV-e4Us'
    },
    {
      'postid': '105',
      'text': 'AB de Villiers',
      'subtext': 'BIG TV',
      'url': 'https://www.youtube.com/watch?v=kSeonA9eJi0'
    },
    {
      'postid': '106',
      'text': 'Chris Gayle',
      'subtext': 'BIG TV',
      'url': 'https://www.youtube.com/watch?v=BM0htuPE5pU'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    _controllers = List.generate(
      _cardData.length,
          (index) => YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(_cardData[index]['url'])!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: true,
          enableCaption: false,
          controlsVisibleAtStart: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _cardData.length,
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
}
