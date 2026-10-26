import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class OverlappingCardsView extends StatelessWidget {
  const OverlappingCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final ValueNotifier<double> currentPage = ValueNotifier<double>(0.0);
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    pageController.addListener(() {
      if (pageController.hasClients && pageController.page != null) {
        currentPage.value = pageController.page!;
      }
    });

    return Scaffold(
      body: ValueListenableBuilder<double>(
        valueListenable: currentPage,
        builder: (context, current, _) {
          final double screenHeight = MediaQuery.of(context).size.height;
          return Stack(
            children: [
              ...List.generate(colors.length, (index) {
                final double position = index - current;
                if (position < -1 || position > 1) return const SizedBox();

                if (position <= 0) {
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
              PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                itemCount: colors.length,
                itemBuilder: (_, __) => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  testWidgets('OverlappingCardsView renders initial card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OverlappingCardsView(),
      ),
    );

    expect(find.text('Card 1'), findsOneWidget);
  });
}
