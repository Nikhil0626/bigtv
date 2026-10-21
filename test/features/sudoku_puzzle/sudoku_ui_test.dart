import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_catalog.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/providers/sudoku_catalog_provider.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_gameplay_screen.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_leaderboard_screen.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_level_selection_screen.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/widgets/sudoku_board_widget.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/widgets/sudoku_how_to_play_card.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/widgets/sudoku_number_pad.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SudokuCatalogProvider>(
          create: (_) => SudokuCatalogProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Sudoku Puzzle UI & Widget Tests', () {
    testWidgets('Level selection screen renders overview, filters, and initial levels', (tester) async {
      await tester.pumpWidget(buildTestApp(const SudokuLevelSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sudoku Puzzle'), findsOneWidget);
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('All (100)'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('Gameplay screen renders top bar, board, action pills, number pad, and how to play card', (tester) async {
      final level = SudokuCatalog.getLevel(1);
      await tester.pumpWidget(buildTestApp(SudokuGameplayScreen(level: level)));
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Difficulty ${level.difficulty.displayName.toUpperCase()}'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      // Board
      expect(find.byType(SudokuBoardWidget), findsOneWidget);

      // Action Pills
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Erase'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.textContaining('Hint'), findsOneWidget);

      // Number Pad (6 numbers only)
      expect(find.byType(SudokuNumberPad), findsOneWidget);
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsWidgets);
      }

      // How to Play card
      expect(find.byType(SudokuHowToPlayCard), findsOneWidget);
      expect(find.text('How to play'), findsOneWidget);
    });

    testWidgets('Leaderboard screen renders dropdown and honest labeling', (tester) async {
      await tester.pumpWidget(buildTestApp(const SudokuLeaderboardScreen(initialLevel: 1)));
      await tester.pumpAndSettle();

      expect(find.text('Sudoku Leaderboards'), findsOneWidget);
      expect(find.text('Player'), findsOneWidget);
      expect(find.text('Leaderboard shows best finish times on this device.'), findsOneWidget);
    });
  });
}
