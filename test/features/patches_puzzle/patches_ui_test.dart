import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_catalog.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_puzzle_repository.dart';
import 'package:chotanews/features/patches_puzzle/presentation/providers/patches_catalog_provider.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patches_gameplay_screen.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patches_leaderboard_screen.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patches_level_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(Widget child,
      {PatchesCatalogProvider? catalogProvider}) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: ChangeNotifierProvider<PatchesCatalogProvider>.value(
        value: catalogProvider ??
            PatchesCatalogProvider(repository: PatchesPuzzleRepository()),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: child,
        ),
      ),
    );
  }

  group('Patches Puzzle UI & Widget Tests', () {
    testWidgets('Level selection screen renders overview, filters, and initial levels',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      final catalogProvider =
          PatchesCatalogProvider(repository: PatchesPuzzleRepository());
      await catalogProvider.loadProgress();

      await tester.pumpWidget(buildTestableWidget(
        const PatchesLevelSelectionScreen(),
        catalogProvider: catalogProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Patches Puzzle'), findsOneWidget);
      expect(find.text('Progress Overview'), findsOneWidget);
      expect(find.text('0 / 100 Solved'), findsOneWidget);
      expect(find.text('Current: Lvl 1'), findsOneWidget);

      // Verify level 1 tile is present
      expect(find.text('1'), findsWidgets);
      // Verify level 2 tile is present
      expect(find.text('2'), findsWidgets);
    });

    testWidgets(
        'Gameplay screen renders top bar, board, pill buttons, and how to play card',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 850));
      final level = PatchesCatalog.getLevel(1);

      await tester.pumpWidget(buildTestableWidget(
        PatchesGameplayScreen(level: level),
      ));
      await tester.pumpAndSettle();

      // Top Bar: Timer, Difficulty badge, Reset pill button
      expect(find.text('0:00'), findsOneWidget);
      expect(find.text('Difficulty ${level.difficulty.name.toUpperCase()}'),
          findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Pill controls: Undo and Hint
      expect(find.text('Undo'), findsOneWidget);
      expect(find.textContaining('Hint'), findsOneWidget);

      // How to Play card
      expect(find.text('How to play'), findsOneWidget);
      expect(find.textContaining('Complete each'), findsOneWidget);
      expect(find.text('Square'), findsOneWidget);
      expect(find.text('Tall rectangle'), findsOneWidget);
      expect(find.text('Wide rectangle'), findsOneWidget);
      expect(find.text('Any of the above'), findsOneWidget);
      expect(
          find.text('If a shape has a number, it must be that size.'),
          findsOneWidget);

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('0:00'), findsOneWidget);
    });

    testWidgets('Leaderboard screen renders dropdown and honest labeling',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(buildTestableWidget(
        const PatchesLeaderboardScreen(initialLevel: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Patches Leaderboard'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.textContaining('Device Local Leaderboard'), findsOneWidget);
      expect(find.text('No records yet for Level 1'), findsOneWidget);
    });
  });
}
