import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MaterialApp(home: DemoSwipeStack()));
}

class DemoSwipeStack extends StatelessWidget {
  const DemoSwipeStack({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        "title":
            "Electric Vehicles Dominate Auto Expo 2025 India Launches Its First Space Station Module India Launches Its First Space Station Module India  India Launches Its First Space Station Module India Launches Its First Space Station Module Launches Its First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://chotanews-wordpress-files.s3.ap-south-1.amazonaws.com/2025/06/aaaaaaaaaaaaaaaa.jpg",
        "source": "AutoCar · 1h ago"
      },
      {
        "title":
            "India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "source": "ISRO News · 2h ago"
      },
      {
        "title":
            "AI Breakthrough: GPT-5 Understands Emotions India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://images.pexels.com/photos/326055/pexels-photo-326055.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "source": "Tech Today · 3h ago"
      },
      {
        "title":
            "Stock Markets Rally Amid Global Optimism India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://chotanews-wordpress-files.s3.ap-south-1.amazonaws.com/2025/06/aaaaaaaaaaaaaaaa.jpg",
        "source": "Bloomberg · 4h ago"
      },
      {
        "title":
            "Climate Summit 2025: Key Takeaways India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "source": "Nature Times · 5h ago"
      },
      {
        "title":
            "Top 10 Travel Destinations for 2025 India Launches Its First Space Station Module India Launches India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station ModuleIts First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://images.pexels.com/photos/757889/pexels-photo-757889.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "source": "Wanderlust · 6h ago"
      },
      {
        "title":
            "Olympics 2028: New Sports Introduced India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station Module India Launches Its First Space Station ModuleIts First Space Station Module India Launches Its First Space Station Module",
        "imageUrl": "https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=800&q=60",
        "source": "Sports Daily · 7h ago"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: LoopingStackedSwiper(articles: articles),
    );
  }
}

class LoopingStackedSwiper extends StatefulWidget {
  final List<Map<String, String>> articles;

  const LoopingStackedSwiper({super.key, required this.articles});

  @override
  State<LoopingStackedSwiper> createState() => _LoopingStackedSwiperState();
}

class _LoopingStackedSwiperState extends State<LoopingStackedSwiper> with TickerProviderStateMixin {
  int currentIndex = 0;
  bool isSwiping = false;
  bool isSwipeDown = false;
  bool showBackCard = false;

  late AnimationController _swipeAnimationController;
  late Animation<double> _fadeAnimation;

  double dragOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeInOut),
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragOffsetY += details.delta.dy;
      if (details.delta.dy < 0 && currentIndex < widget.articles.length - 1) {
        isSwipeDown = false;
        showBackCard = true;
      } else if (details.delta.dy > 0 && currentIndex > 0) {
        isSwipeDown = true;
        showBackCard = true;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null || isSwiping) return;

    if (details.primaryVelocity! < -200 && currentIndex < widget.articles.length - 1) {
      _swipe(true);
    } else if (details.primaryVelocity! > 200 && currentIndex > 0) {
      _swipe(false);
    } else {
      setState(() {
        dragOffsetY = 0.0;
        showBackCard = false;
      });
    }
  }

  void _swipe(bool toNext) {
    isSwiping = true;
    _swipeAnimationController.forward().then((_) {
      setState(() {
        currentIndex += toNext ? 1 : -1;
        _swipeAnimationController.reset();
        dragOffsetY = 0.0;
        isSwiping = false;
        showBackCard = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.articles[currentIndex];
    final next = currentIndex < widget.articles.length - 1 ? widget.articles[currentIndex + 1] : null;
    final previous = currentIndex > 0 ? widget.articles[currentIndex - 1] : null;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Stack(
        children: [
          if (showBackCard && next != null && !isSwipeDown) _buildCard(next, isBehind: true),
          if (showBackCard && previous != null && isSwipeDown) _buildCard(previous, isBehind: true),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, dragOffsetY),
                  child: _buildCard(current),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, String> article, {bool isBehind = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // margin: EdgeInsets.all(isBehind ? 24 : 12),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: article['imageUrl']!,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              article['title']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(article['source']!, style: TextStyle(color: Colors.grey[600])),
                const Icon(Icons.share),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }
}


