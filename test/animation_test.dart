import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: OverlappingCardsView()));

class OverlappingCardsView extends StatefulWidget {
  const OverlappingCardsView({super.key});

  @override
  State<OverlappingCardsView> createState() => _OverlappingCardsViewState();
}

class _OverlappingCardsViewState extends State<OverlappingCardsView> {
  final PageController _pageController = PageController();
  double _currentPage = 0.0;
  final int totalCards = 6;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          ...List.generate(colors.length, (index) {
            final double position = index - _currentPage;

            // Only show nearby cards
            if (position < -1 || position > 1) return const SizedBox();

            if (position <= 0) {
              // Current or previous card
              return Positioned.fill(
                child: Container(
                  color: colors[index],
                  child: Center(
                    child: Text(
                      "Card ${index + 1}",
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Next card during scroll
            double visiblePortion = (1 - position).clamp(0.0, 1.0);
            double topOffset = screenHeight * (1 - visiblePortion);

            return Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.25),
                      blurRadius: 8,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Card ${index + 1}",
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),

          // PageView - no snap hold
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            // smooth no bounce
            itemCount: colors.length,
            itemBuilder: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
