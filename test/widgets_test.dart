import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Widget Tests', () {
    testWidgets('AppNoData renders fallback message when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNoData(),
          ),
        ),
      );

      expect(find.text('No data Found'), findsOneWidget);
    });

    testWidgets('AppNoData renders provided text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNoData(data: 'Custom Message'),
          ),
        ),
      );

      expect(find.text('Custom Message'), findsOneWidget);
    });

    testWidgets('KeepAlivePage renders child widget properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeepAlivePage(
              child: Text('Keep Alive Content'),
            ),
          ),
        ),
      );

      expect(find.text('Keep Alive Content'), findsOneWidget);
    });

    test('TopRightWavePainter can be instantiated and compared', () {
      const painter1 = TopRightWavePainter(isDark: true, isRedHeader: false);
      const painter2 = TopRightWavePainter(isDark: false, isRedHeader: true);

      expect(painter1.isDark, isTrue);
      expect(painter2.isRedHeader, isTrue);
      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
