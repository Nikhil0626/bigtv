import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chotanews/features/home/presentation/widgets/html_notification_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HtmlNotificationDialog Tests', () {
    testWidgets('renders basic HTML content, title, and buttons', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: HtmlNotificationDialog(
                title: 'Breaking News',
                content: '<p>This is a <b>bold</b> and <i>italic</i> announcement with <a href="https://example.com">link</a>.</p>',
                ctaText: 'Read More',
                ctaUrl: 'https://example.com/read',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Breaking News'), findsOneWidget);
      expect(find.text('Read More'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders with headers, lists and image', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: HtmlNotificationDialog(
                title: 'Header Test',
                content: '''
                  <h1>Heading 1</h1>
                  <h2>Heading 2</h2>
                  <h3>Heading 3</h3>
                  <ul>
                    <li>Bullet item 1</li>
                    <li>Bullet item 2</li>
                  </ul>
                  <img src="https://example.com/test.jpg" />
                ''',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Header Test'), findsOneWidget);
    });

    testWidgets('taps close button pops the dialog', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder: (_) => const HtmlNotificationDialog(
                        title: 'Dismissable',
                        content: '<p>Click close</p>',
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissable'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Dismissable'), findsNothing);
    });
  });
}
