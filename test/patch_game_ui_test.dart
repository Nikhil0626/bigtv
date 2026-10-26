import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/patches_puzzle/data/models/patch_model.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patch_game_screen.dart';
import 'package:chotanews/features/patches_puzzle/presentation/widgets/patch_completion_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithMaterial(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    );
  }

  group('Patch Game API Data & Model Parsing Tests', () {
    test('Parses full API response with clues, pieces, palette, and solution', () {
      final json = {
        'gameId': 'patch',
        'levelId': 'patch_003',
        'levelNumber': 3,
        'difficulty': 'medium',
        'content': {
          'grid': {'rows': 5, 'columns': 5},
          'clues': [
            {'col': 3, 'row': 4, 'shape': 'wide', 'value': 2},
            {'col': 0, 'row': 1, 'shape': 'sq', 'value': 4},
            {'col': 2, 'row': 0, 'shape': 'wide', 'value': 3},
          ],
          'pieces': [
            {
              'h': 1,
              'w': 2,
              'id': 'p_1',
              'cells': [
                {'col': 0, 'row': 0},
                {'col': 1, 'row': 0},
              ],
              'color': '#489d6a',
            },
            {
              'h': 2,
              'w': 2,
              'id': 'p_5',
              'cells': [
                {'col': 0, 'row': 0},
                {'col': 1, 'row': 0},
                {'col': 0, 'row': 1},
                {'col': 1, 'row': 1},
              ],
              'color': '#e07a22',
            },
          ],
          'palette': {
            'gridBorder': '#BDC3C7',
            'boardBackground': '#F4F6F7',
          },
          'solution': [
            {
              'pieceId': 'p_1',
              'anchor': {'row': 4, 'col': 3},
              'cells': [
                {'row': 4, 'col': 3},
                {'row': 4, 'col': 4},
              ],
            },
          ],
        },
      };

      final level = PatchLevel.fromJson(json);
      expect(level.rows, 5);
      expect(level.columns, 5);
      expect(level.difficulty, 'medium');
      expect(level.clues.length, 3);
      expect(level.getClueAt(4, 3)?.value, 2);
      expect(level.getClueAt(4, 3)?.shape, 'wide');
      expect(level.getClueAt(1, 0)?.value, 4);
      expect(level.getClueAt(1, 0)?.shape, 'sq');
      expect(level.getClueAt(0, 0), isNull);

      expect(level.pieces.length, 2);
      expect(level.pieces[0].id, 'p_1');
      expect(level.pieces[0].width, 2);
      expect(level.pieces[0].height, 1);
      expect(level.pieces[1].id, 'p_5');
      expect(level.pieces[1].width, 2);
      expect(level.pieces[1].height, 2);

      expect(level.solution.length, 1);
      expect(level.solution[0].pieceId, 'p_1');
      expect(level.solution[0].cells.length, 2);
    });
  });

  group('PatchGameScreen UI & Interaction Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
      binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('Renders header, timer, controls row, clues, and on-board drag guidance without bottom cards', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PatchGameScreen(playerId: 'test_player'),
      ));
      await tester.pumpAndSettle();

      // Check header and difficulty
      expect(find.textContaining('Patch (5x5)'), findsOneWidget);
      expect(find.textContaining('Difficulty'), findsOneWidget);

      // Check Undo and Reset controls
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Check guidance for direct board drag
      expect(find.textContaining('Tap a number & drag to select boxes'), findsOneWidget);

      // Clue values rendered in the grid
      expect(find.text('5'), findsWidgets);

      // Verify NO bottom patch cards or hint boxes exist
      expect(find.byKey(const ValueKey('patch_card_p1')), findsNothing);
      expect(find.textContaining('Select a patch below'), findsNothing);
    });

    testWidgets('Interaction guidance card shows progress and handles controls', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PatchGameScreen(playerId: 'test_player'),
      ));
      await tester.pumpAndSettle();

      // Verify initial progress pill
      expect(find.textContaining('/5'), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Tap Undo button
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tap placed patch to remove it'), findsOneWidget);
    });

    testWidgets('PatchCompletionDialog renders rank, streak, time and View Game/Dashboard buttons', (tester) async {
      bool viewGameTapped = false;
      bool dashboardTapped = false;

      await tester.pumpWidget(wrapWithMaterial(
        PatchCompletionDialog(
          formattedTime: '18.4s',
          rank: 2,
          streak: 4,
          onViewGame: () => viewGameTapped = true,
          onDashboard: () => dashboardTapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Today's Patch Solved!"), findsOneWidget);
      expect(find.text('Rank #2'), findsOneWidget);
      expect(find.text('4 Day Streak'), findsOneWidget);
      expect(find.text('18.4s'), findsOneWidget);
      expect(find.text('View Game'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.text('View Game'));
      expect(viewGameTapped, isTrue);

      await tester.tap(find.text('Dashboard'));
      expect(dashboardTapped, isTrue);
    });
  });
}
