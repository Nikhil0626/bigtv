import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_catalog.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_puzzle_repository.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/providers/sudoku_game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SudokuGameProvider Gameplay & Rules Engine Tests (6x6 Sudoku)', () {
    test('Initializes 6x6 grid with exact givens locked and other cells empty', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      expect(game.size, equals(6));
      expect(game.grid.length, equals(6));

      for (int r = 0; r < 6; r++) {
        expect(game.grid[r].length, equals(6));
        for (int c = 0; c < 6; c++) {
          final cell = game.grid[r][c];
          final given = level.initialGrid[r][c];
          expect(cell.row, equals(r));
          expect(cell.col, equals(c));
          expect(cell.value, equals(given));
          expect(cell.isGiven, equals(given != 0));
          expect(cell.isError, isFalse);
        }
      }

      game.dispose();
    });

    test('Selecting cell updates selectedRow and selectedCol', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      expect(game.selectedRow, isNull);
      expect(game.selectedCol, isNull);

      game.selectCell(2, 4);
      expect(game.selectedRow, equals(2));
      expect(game.selectedCol, equals(4));

      game.dispose();
    });

    test('Entering digit in empty cell updates value; given cell is locked', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      // Find an empty cell
      int emptyR = -1, emptyC = -1;
      int givenR = -1, givenC = -1;
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (level.initialGrid[r][c] == 0 && emptyR == -1) {
            emptyR = r;
            emptyC = c;
          }
          if (level.initialGrid[r][c] != 0 && givenR == -1) {
            givenR = r;
            givenC = c;
          }
        }
      }

      // Enter digit in empty cell
      game.selectCell(emptyR, emptyC);
      game.enterDigit(5);
      expect(game.grid[emptyR][emptyC].value, equals(5));

      // Entering same digit again toggles it off
      game.enterDigit(5);
      expect(game.grid[emptyR][emptyC].value, equals(0));

      // Try entering digit in given cell (should be ignored)
      final originalGiven = level.initialGrid[givenR][givenC];
      game.selectCell(givenR, givenC);
      game.enterDigit((originalGiven % 6) + 1);
      expect(game.grid[givenR][givenC].value, equals(originalGiven));

      game.dispose();
    });

    test('Pencil Notes Mode toggles candidate marks in cell (digits 1-6)', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      // Find an empty cell
      int emptyR = -1, emptyC = -1;
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (level.initialGrid[r][c] == 0) {
            emptyR = r;
            emptyC = c;
            break;
          }
        }
        if (emptyR != -1) break;
      }

      game.selectCell(emptyR, emptyC);
      expect(game.isNoteMode, isFalse);

      game.toggleNoteMode();
      expect(game.isNoteMode, isTrue);

      // Add notes 2, 4, 6
      game.enterDigit(2);
      game.enterDigit(4);
      game.enterDigit(6);

      expect(game.grid[emptyR][emptyC].notes, containsAll([2, 4, 6]));
      expect(game.grid[emptyR][emptyC].value, equals(0));

      // Toggling 4 off
      game.enterDigit(4);
      expect(game.grid[emptyR][emptyC].notes.contains(4), isFalse);
      expect(game.grid[emptyR][emptyC].notes, containsAll([2, 6]));

      game.dispose();
    });

    test('Conflict detection marks duplicate numbers in row, col, or 2x3 box as error', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      // Find an empty cell in row 0
      int emptyC = -1;
      for (int c = 0; c < 6; c++) {
        if (level.initialGrid[0][c] == 0) {
          emptyC = c;
          break;
        }
      }

      // Find a given value that already exists in row 0
      int existingVal = 0;
      for (int c = 0; c < 6; c++) {
        if (level.initialGrid[0][c] != 0) {
          existingVal = level.initialGrid[0][c];
          break;
        }
      }

      expect(emptyC != -1 && existingVal != 0, isTrue);

      // Enter the duplicate value in the empty cell
      game.selectCell(0, emptyC);
      game.enterDigit(existingVal);

      // Both cells with this duplicate value should now have isError = true
      expect(game.grid[0][emptyC].isError, isTrue);

      game.dispose();
    });

    test('Undo reverts previous digit placement or note edit', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      int emptyR = -1, emptyC = -1;
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (level.initialGrid[r][c] == 0) {
            emptyR = r;
            emptyC = c;
            break;
          }
        }
        if (emptyR != -1) break;
      }

      game.selectCell(emptyR, emptyC);
      game.enterDigit(3);
      expect(game.grid[emptyR][emptyC].value, equals(3));
      expect(game.canUndo, isTrue);

      game.undo();
      expect(game.grid[emptyR][emptyC].value, equals(0));

      game.dispose();
    });

    test('Hint fills selected or first unsolved cell with correct solution digit', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      final game = SudokuGameProvider(level: level, repository: repo);

      int emptyR = -1, emptyC = -1;
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (level.initialGrid[r][c] == 0) {
            emptyR = r;
            emptyC = c;
            break;
          }
        }
        if (emptyR != -1) break;
      }

      game.selectCell(emptyR, emptyC);
      game.hint();

      final expectedSol = level.solutionGrid[emptyR][emptyC];
      expect(game.grid[emptyR][emptyC].value, equals(expectedSol));
      expect(game.grid[emptyR][emptyC].isError, isFalse);

      game.dispose();
    });

    test('Solving all 36 cells completes the level', () {
      final level = SudokuCatalog.getLevel(1);
      final repo = SudokuPuzzleRepository();
      bool completedCallbackFired = false;
      final game = SudokuGameProvider(
        level: level,
        repository: repo,
        onLevelCompleted: () => completedCallbackFired = true,
      );

      // Fill in all cells using the known solution
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (level.initialGrid[r][c] == 0) {
            game.selectCell(r, c);
            game.enterDigit(level.solutionGrid[r][c]);
          }
        }
      }

      expect(game.isCompleted, isTrue);
      expect(completedCallbackFired, isTrue);

      game.dispose();
    });
  });
}
