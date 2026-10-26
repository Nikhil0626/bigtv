import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/sudoku_puzzle/data/models/sudoku_model.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_game_screen.dart';
import 'package:chotanews/features/patches_puzzle/data/models/patch_model.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patch_game_screen.dart';
import 'package:chotanews/services/puzzle_api_service.dart';

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

  group('Sudoku and Patch Models Tests', () {
    test('SudokuLevel parses 6x6 JSON properly', () {
      final json = {
        'levelId': 'sudoku_01',
        'levelNumber': 1,
        'difficulty': 'easy',
        'content': {
          'grid': {'rows': 6, 'columns': 6},
          'initialGrid': [
            [1, 0, 3, 0, 5, 0],
            [0, 5, 0, 1, 0, 3],
            [2, 0, 1, 0, 6, 0],
            [0, 6, 0, 2, 0, 1],
            [3, 0, 2, 0, 4, 0],
            [0, 4, 0, 3, 0, 2],
          ],
          'solution': [
            [1, 2, 3, 4, 5, 6],
            [4, 5, 6, 1, 2, 3],
            [2, 3, 1, 5, 6, 4],
            [5, 6, 4, 2, 3, 1],
            [3, 1, 2, 6, 4, 5],
            [6, 4, 5, 3, 1, 2],
          ],
          'palette': {
            'gridBorder': '#BDC3C7',
            'blockBorder': '#1A252F',
            'cellBackground': '#FFFFFF',
            'selectedCell': '#D6EAF8',
            'highlightNumber': '#AED6F1',
            'clueText': '#1B2631',
            'userText': '#2980B9',
          },
        },
      };

      final level = SudokuLevel.fromJson(json);
      expect(level.levelId, 'sudoku_01');
      expect(level.rows, 6);
      expect(level.columns, 6);
      expect(level.boxRows, 2);
      expect(level.boxCols, 3);
      expect(level.initialGrid[0][0], 1);
      expect(level.solution[0][1], 2);
    });

    test('SudokuLevel parses 9x9 box dimensions accurately', () {
      final json = {
        'levelId': 'sudoku_99',
        'levelNumber': 2,
        'difficulty': 'hard',
        'content': {
          'grid': {'rows': 9, 'columns': 9},
          'initialGrid': List.generate(9, (_) => List.filled(9, 0)),
          'solution': List.generate(9, (_) => List.filled(9, 1)),
        },
      };

      final level = SudokuLevel.fromJson(json);
      expect(level.rows, 9);
      expect(level.boxRows, 3);
      expect(level.boxCols, 3);
    });

    test('PatchLevel parses polyomino partition level properly', () {
      final json = {
        'levelId': 'patch_01',
        'levelNumber': 1,
        'difficulty': 'easy',
        'content': {
          'grid': {'rows': 5, 'columns': 5},
          'palette': {
            'gridBorder': '#BDC3C7',
            'boardBackground': '#F4F6F7',
          },
          'pieces': [
            {
              'id': 'p1',
              'color': '#E74C3C',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 0, 'col': 1},
                {'row': 0, 'col': 2},
              ],
            },
            {
              'id': 'p2',
              'color': '#3498DB',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 1, 'col': 0},
              ],
            },
          ],
        },
      };

      final level = PatchLevel.fromJson(json);
      expect(level.rows, 5);
      expect(level.columns, 5);
      expect(level.pieces.length, 2);
      expect(level.pieces[0].id, 'p1');
      expect(level.pieces[0].cells.length, 3);
      expect(level.pieces[1].id, 'p2');
    });
  });

  group('PuzzleApiService Fallback & Method Tests', () {
    test('PuzzleApiService provides fallback for sudoku', () async {
      final data = await PuzzleApiService.getTodayGame(gameSlug: 'sudoku');
      expect(data['content'], isNotNull);
      final level = SudokuLevel.fromJson(data);
      expect(level.rows, 6);
      expect(level.columns, 6);
    });

    test('PuzzleApiService provides fallback for patch', () async {
      final data = await PuzzleApiService.getTodayGame(gameSlug: 'patch');
      expect(data['content'], isNotNull);
      final level = PatchLevel.fromJson(data);
      expect(level.rows, 5);
      expect(level.pieces.isNotEmpty, isTrue);
    });

    test('PuzzleApiService submitGame returns rank and streak', () async {
      final res = await PuzzleApiService.submitGame(
        gameSlug: 'sudoku',
        playerId: 'test_player',
        durationMs: 15000,
        score: 100,
      );
      expect(res['rank'], isNotNull);
      expect(res['streak'], isNotNull);
    });
  });

  group('UI Gameplay Screens Tests', () {
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

    testWidgets('SudokuGameScreen renders 6x6 grid and keypad', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SudokuGameScreen(playerId: 'test_player'),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sudoku (6x6)'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('6'), findsWidgets);
    });

    testWidgets('SudokuGameScreen shows red text and rule error when placing wrong number', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SudokuGameScreen(playerId: 'test_player'),
      ));
      await tester.pumpAndSettle();

      // Row 0 has: [1, 0, 3, 0, 5, 0]
      // Find empty cells
      final emptyCells = find.byWidgetPredicate((widget) {
        return widget is Text && widget.data == '';
      });
      expect(emptyCells, findsWidgets);

      // Tap first empty cell (which is (0, 1))
      await tester.tap(emptyCells.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Press '1' on keypad
      // Row 0 already has '1' at (0, 0), so this violates row & box rule!
      final keypadOne = find.widgetWithText(ElevatedButton, '1');
      await tester.tap(keypadOne);
      await tester.pumpAndSettle();

      // Expect error banner containing rule violation message
      expect(find.textContaining('Sudoku Rule Violation'), findsOneWidget);
      expect(find.textContaining('Number 1 is repeated in row 1'), findsOneWidget);

      // Verify the number is rendered in RED (Color(0xFFDC2626))
      final redText = find.byWidgetPredicate((widget) {
        return widget is Text && widget.data == '1' && widget.style?.color == const Color(0xFFDC2626);
      });
      expect(redText, findsOneWidget);

      // Also verify mistakes badge in appbar
      expect(find.text('Errors: 1'), findsOneWidget);

      // Press backspace to erase
      final backspace = find.byIcon(Icons.backspace_outlined);
      await tester.tap(backspace);
      await tester.pumpAndSettle();

      // Error banner and mistakes badge should be gone
      expect(find.textContaining('Sudoku Rule Violation'), findsNothing);
      expect(find.text('Errors: 1'), findsNothing);

      // Now enter the CORRECT number for (0, 1) which is '2'
      final keypadTwo = find.widgetWithText(ElevatedButton, '2');
      await tester.tap(keypadTwo);
      await tester.pumpAndSettle();

      // No error banner
      expect(find.textContaining('Sudoku Rule Violation'), findsNothing);
      expect(find.textContaining('Incorrect placement'), findsNothing);

      // Number '2' is NOT red (normal user text color #2980B9)
      final userTwo = find.byWidgetPredicate((widget) {
        return widget is Text && widget.data == '2' && widget.style?.color == const Color(0xFF2980B9);
      });
      expect(userTwo, findsOneWidget);
    });

    testWidgets('SudokuGameScreen in viewOnly mode shows completed status', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SudokuGameScreen(playerId: 'test_player', isViewOnly: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.textContaining('completed today\'s Sudoku puzzle'), findsOneWidget);
    });

    testWidgets('PatchGameScreen renders 5x5 board with on-board drag guidance', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PatchGameScreen(playerId: 'test_player'),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Patch (5x5)'), findsOneWidget);
      expect(find.textContaining('Tap a number & drag to select boxes'), findsOneWidget);
    });

    testWidgets('PatchGameScreen in viewOnly mode shows completed status', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PatchGameScreen(playerId: 'test_player', isViewOnly: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.textContaining('completed today\'s Patch puzzle'), findsOneWidget);
    });
  });
}
