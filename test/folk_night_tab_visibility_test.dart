import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/events/presentation/widgets/folk_night_floating_button.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidget(HomeProvider homeProvider) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => ChangeNotifierProvider<HomeProvider>.value(
        value: homeProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: FolkNightFloatingButton(),
          ),
        ),
      ),
    );
  }

  group('Folk Night Tab Visibility Tests', () {
    testWidgets('Folk Night button is VISIBLE when on Home page news tab (selectedIndex == 1)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Button content should be rendered
      expect(find.byType(FolkNightFloatingButton), findsOneWidget);
      expect(find.text('Folk Night'), findsOneWidget);
    });

    testWidgets('Folk Night button is HIDDEN when on Search tab (selectedIndex == 0)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 0;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Folk Night button is HIDDEN when on Reels tab (selectedIndex == 2)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 2;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Folk Night button is HIDDEN when on Settings/More tab (selectedIndex == 3)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 3;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Folk Night button is HIDDEN when folkNight config is false or Malayalam', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = false;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);

      homeProvider.folkNight = true;
      homeProvider.langCode = 'ml';
      homeProvider.notifyListeners();
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Close icon is visible on Folk Night button and tapping it dismisses the button', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Verify Folk Night and close icon are rendered
      expect(find.text('Folk Night'), findsOneWidget);
      expect(find.byKey(const Key('folk_night_close_button')), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byKey(const Key('folk_night_close_button')));
      await tester.pump();

      // Button should now be dismissed / hidden
      expect(homeProvider.isFolkNightDismissed, isTrue);
      expect(find.text('Folk Night'), findsNothing);

      // Coming to All Posts tab again restores the button
      homeProvider.onItemTapped(1);
      await tester.pump();

      expect(homeProvider.isFolkNightDismissed, isFalse);
      expect(find.text('Folk Night'), findsOneWidget);
    });

    testWidgets('Switching to another tab and returning to All Posts tab restores dismissed button', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Dismiss button
      homeProvider.dismissFolkNight();
      await tester.pump();
      expect(find.text('Folk Night'), findsNothing);

      // User switches to Reels (tab 2)
      homeProvider.onItemTapped(2);
      await tester.pump();

      // User returns to All Posts (tab 1)
      homeProvider.onItemTapped(1);
      await tester.pump();

      expect(homeProvider.isFolkNightDismissed, isFalse);
      expect(find.text('Folk Night'), findsOneWidget);
    });
  });
}

