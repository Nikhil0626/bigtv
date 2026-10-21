import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_catalog.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_puzzle_repository.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/zip_catalog_provider.dart';
import 'package:chotanews/features/zip_puzzle/presentation/screens/zip_gameplay_screen.dart';
import 'package:chotanews/features/zip_puzzle/presentation/screens/zip_leaderboard_screen.dart';
import 'package:chotanews/features/zip_puzzle/presentation/screens/zip_level_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(Widget child,
      {ZipCatalogProvider? catalogProvider}) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: ChangeNotifierProvider<ZipCatalogProvider>.value(
        value: catalogProvider ??
            ZipCatalogProvider(repository: ZipPuzzleRepository()),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: child,
        ),
      ),
    );
  }

  group('Zip Puzzle UI & Widget Tests', () {
    testWidgets('Level selection screen renders overview and initial levels',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      final catalogProvider =
          ZipCatalogProvider(repository: ZipPuzzleRepository());
      await catalogProvider.loadProgress();

      await tester.pumpWidget(buildTestableWidget(
        const ZipLevelSelectionScreen(),
        catalogProvider: catalogProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Zip Puzzle'), findsOneWidget);
      expect(find.text('Progress Overview'), findsOneWidget);
      expect(find.text('0 / 100 Solved'), findsOneWidget);
      expect(find.text('Current: Lvl 1'), findsOneWidget);

      // Verify level 1 tile is present
      expect(find.text('1'), findsWidgets);
      // Verify level 2 tile is present
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('Tapping locked level shows informative message',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      final catalogProvider =
          ZipCatalogProvider(repository: ZipPuzzleRepository());
      await catalogProvider.loadProgress();

      await tester.pumpWidget(buildTestableWidget(
        const ZipLevelSelectionScreen(),
        catalogProvider: catalogProvider,
      ));
      await tester.pumpAndSettle();

      // Find tile with text '2' and tap it (it's locked)
      final level2Finder = find.widgetWithText(InkWell, '2');
      expect(level2Finder, findsOneWidget);
      await tester.tap(level2Finder);
      await tester.pump();

      expect(find.textContaining('Level 2 is locked'), findsOneWidget);
    });

    testWidgets('Gameplay screen renders board, timer, and checkpoint counters',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      final level1 = ZipCatalog.getLevel(1);

      await tester.pumpWidget(buildTestableWidget(
        ZipGameplayScreen(level: level1),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.textContaining('13'), findsWidgets); // 13 checkpoints
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
    });

    testWidgets('Leaderboard screen renders with local empty state',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(buildTestableWidget(
        const ZipLeaderboardScreen(initialLevel: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.textContaining('Device Local Leaderboard'), findsOneWidget);
      expect(find.text('No records yet for Level 1'), findsOneWidget);
    });
  });
}
