import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../reels_provider/reels_providers.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late YoutubePlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reelsDataList = context.watch<ReelsProviders>().reelsDataList;

    if (reelsDataList == null || reelsDataList.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: CardSwiper(
          allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
          cardsCount: reelsDataList.length,
          onSwipe: (previousIndex, currentIndex, direction) {
            if (currentIndex != null) {
              setState(() {
                _currentIndex = currentIndex;
                final videoUrl = reelsDataList[_currentIndex]['videoUrl'] ?? '';
                _controller.load(videoUrl);
              });
            }
            return true;
          },
          numberOfCardsDisplayed: 4,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            final reel = reelsDataList[index];

            // Extract data for ReelCard
            final thumbnailUrl = reel['thumbnailUrl'] ?? '';
            final publisherImage = reel['publisherImage'] ?? '';
            final publisher = reel['publisher'] ?? 'Unknown';

            return ReelCard(
              thumbnailUrl: thumbnailUrl,
              publisherImage: publisherImage,
              publisher: publisher,
            );
          },
        ),
      ),
    );
  }
}

class ReelCard extends StatelessWidget {
  final String thumbnailUrl;
  final String publisherImage;
  final String publisher;

  const ReelCard({
    required this.thumbnailUrl,
    required this.publisherImage,
    required this.publisher,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity, // Full width
                  height: 400.h, // Set a fixed height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(thumbnailUrl),
                      fit: BoxFit.cover, // Cover the container
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(publisherImage),
                      radius: 20, 
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        publisher,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 24.sp),
                        SizedBox(width: 8),
                        Text("1.2K", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment, color: Colors.grey, size: 24.sp),
                        SizedBox(width: 8),
                        Text("345", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.share, color: Colors.grey, size: 24.sp),
                        SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              radius: 20,
              child: Icon(
                Icons.bookmark,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
