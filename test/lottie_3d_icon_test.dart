import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/home/presentation/widgets/lottie_3d_icon.dart';

void main() {
  testWidgets('Lottie3DIcon renders and animates without errors', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Lottie3DIcon(
              imagePath: 'assets/images/game_3d_icon.png',
              width: 50,
              height: 50,
              index: 2,
              shadowColor: Colors.green,
              onTap: () {
                tapped = true;
              },
              fallback: const Icon(Icons.games),
            ),
          ),
        ),
      ),
    );

    // Initial frame
    expect(find.byType(Lottie3DIcon), findsOneWidget);

    // Pump a few animation ticks (simulating 1.5 seconds of floating & breathing loop)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify tap triggers spring press and onTap callback
    await tester.tap(find.byType(Lottie3DIcon));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tapped, isTrue);
  });
}
