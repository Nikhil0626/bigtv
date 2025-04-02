import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final List<Map<String, String>> videoData = [
    {'text': 'Rohith Sharma', 'url': 'D7DYyHbDJE4'},
    {'text': 'Virat Kohli', 'url': 'E8TtA-tg1Ps'},
    {'text': 'Sachin Tendulkar', 'url': 'tyC7zT5xWkE'},
    {'text': 'MS Dhoni', 'url': 'AsPdLV-e4Us'},
    {'text': 'AB de Villiers', 'url': 'kSeonA9eJi0'},
    {'text': 'Chris Gayle', 'url': 'BM0htuPE5pU'},
  ];

  late YoutubePlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoData[_currentIndex]['url']!,
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _controller.load(videoData[_currentIndex]['url']!);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned.fill(child: player),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      videoData[index]['text']!,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
