import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
      body: Center(
        child: CardSwiper(
          allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
            cardsCount: videoData.length,
          onSwipe: (previousIndex, currentIndex, direction) {
            print("Swiped from $previousIndex to $currentIndex");
            return true;
          },
          numberOfCardsDisplayed: 4,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            final reel = videoData[index];
            return ReelCard(
              text: reel['text']!,
              thumbnailUrl: 'https://img.youtube.com/vi/${reel['url']}/maxresdefault.jpg',
            );
          },
        )
      ),
    );
  }
}

class ReelCard extends StatelessWidget {
  final String text;
  final String thumbnailUrl;

  const ReelCard({
    required this.text,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
