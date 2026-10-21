import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_catalog.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_puzzle_repository.dart';
import 'package:chotanews/features/patches_puzzle/data/models/drawn_patch.dart';
import 'package:chotanews/features/patches_puzzle/data/models/patch_clue.dart';
import 'package:chotanews/features/patches_puzzle/data/models/patches_level_definition.dart';
import 'package:chotanews/features/patches_puzzle/presentation/providers/patches_game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PatchesGameProvider Gameplay & Rules Engine Tests', () {
    test('Placing a patch with no clue inside is rejected', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      // Find cells where there are no clues
      final cluePoints = level.clues.map((c) => c.point).toSet();
      GridPoint? emptyPt;
      for (int r = 0; r < level.rows; r++) {
        for (int c = 0; c < level.cols; c++) {
          final pt = GridPoint(r, c);
          if (!cluePoints.contains(pt)) {
            emptyPt = pt;
            break;
          }
        }
        if (emptyPt != null) break;
      }

      expect(emptyPt, isNotNull);
      game.startDrag(emptyPt!);
      game.updateDrag(emptyPt);
      game.endDrag();

      expect(game.placedPatches.isEmpty, isTrue);
      expect(game.feedbackMessage, contains('must contain 1 clue'));

      game.dispose();
    });

    test('Placing a patch containing multiple clues is rejected', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      // Drag covering the entire grid (which definitely contains multiple clues)
      game.startDrag(const GridPoint(0, 0));
      game.updateDrag(GridPoint(level.rows - 1, level.cols - 1));
      game.endDrag();

      expect(game.placedPatches.isEmpty, isTrue);
      expect(game.feedbackMessage, contains('multiple clues'));

      game.dispose();
    });

    test('Drawing valid patch for a clue places the patch successfully', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      final sol = level.solutionPatches.first;
      game.startDrag(GridPoint(sol.minRow, sol.minCol));
      game.updateDrag(GridPoint(sol.maxRow, sol.maxCol));
      game.endDrag();

      expect(game.placedPatches.length, equals(1));
      expect(game.placedPatches.first.clueId, equals(sol.clueId));
      expect(game.feedbackMessage, isNull);
      expect(game.hasStarted, isTrue);

      game.dispose();
    });

    test('Patch with incorrect area is rejected', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      // Find a clue with targetArea > 1
      final multiCellClue =
          level.clues.firstWhere((c) => c.targetArea != null && c.targetArea! > 1);

      // Draw only 1 cell on top of this clue
      game.startDrag(multiCellClue.point);
      game.updateDrag(multiCellClue.point);
      game.endDrag();

      expect(game.placedPatches.isEmpty, isTrue);
      expect(game.feedbackMessage, contains('Area must be'));

      game.dispose();
    });

    test('Patch with incorrect shape constraint is rejected', () {
      const clue = PatchClue(
        id: 'c1',
        point: GridPoint(0, 0),
        targetArea: 4,
        shapeType: PatchShapeType.square,
        color: Color(0xFFEF4444),
        tintColor: Color(0xFFFEE2E2),
      );
      final level = PatchesLevelDefinition(
        levelNumber: 999,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [clue],
        solutionPatches: const [
          DrawnPatch(
            clueId: 'c1',
            minRow: 0,
            maxRow: 1,
            minCol: 0,
            maxCol: 1,
            color: Color(0xFFEF4444),
            tintColor: Color(0xFFFEE2E2),
          ),
        ],
      );

      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      // Draw 1x4 tall rectangle covering the clue at (0,0)
      // Clues inside: exactly 1 (c1)
      // Area: 4 (matches targetArea 4)
      // Shape: 1x4 tall rectangle, but clue requires square!
      game.startDrag(const GridPoint(0, 0));
      game.updateDrag(const GridPoint(3, 0));
      game.endDrag();

      expect(game.placedPatches.isEmpty, isTrue);
      expect(game.feedbackMessage, contains('Shape must be a Square'));

      game.dispose();
    });

    test('Undo removes the last placed patch cleanly', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      final sol1 = level.solutionPatches[0];
      final sol2 = level.solutionPatches[1];

      game.startDrag(GridPoint(sol1.minRow, sol1.minCol));
      game.updateDrag(GridPoint(sol1.maxRow, sol1.maxCol));
      game.endDrag();

      game.startDrag(GridPoint(sol2.minRow, sol2.minCol));
      game.updateDrag(GridPoint(sol2.maxRow, sol2.maxCol));
      game.endDrag();

      expect(game.placedPatches.length, equals(2));

      game.undo();
      expect(game.placedPatches.length, equals(1));
      expect(game.placedPatches.first.clueId, equals(sol1.clueId));

      game.undo();
      expect(game.placedPatches.isEmpty, isTrue);

      game.dispose();
    });

    test('Reset clears all placed patches and resets game timer state', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      final sol1 = level.solutionPatches[0];
      game.startDrag(GridPoint(sol1.minRow, sol1.minCol));
      game.updateDrag(GridPoint(sol1.maxRow, sol1.maxCol));
      game.endDrag();

      expect(game.placedPatches.length, equals(1));
      expect(game.hasStarted, isTrue);

      game.reset();
      expect(game.placedPatches.isEmpty, isTrue);
      expect(game.hasStarted, isFalse);

      game.dispose();
    });

    test('Hint reveals next missing solution patch and enforces daily limit of 3',
        () async {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      final game = PatchesGameProvider(level: level, repository: repo);

      // Wait a tick for hint initialization
      await Future<void>.delayed(Duration.zero);

      expect(game.remainingHints, equals(3));

      // Hint 1
      game.hint();
      expect(game.placedPatches.length, equals(1));
      expect(game.remainingHints, equals(2));

      // Hint 2
      game.hint();
      expect(game.placedPatches.length, equals(2));
      expect(game.remainingHints, equals(1));

      // Hint 3
      game.hint();
      expect(game.placedPatches.length, equals(3));
      expect(game.remainingHints, equals(0));

      // Hint 4: limit reached
      final countBefore = game.placedPatches.length;
      game.hint();
      expect(game.placedPatches.length, equals(countBefore));
      expect(game.feedbackMessage, contains('Daily hint limit reached'));

      game.dispose();
    });

    test('Placing all solution patches triggers completion callback', () {
      final level = PatchesCatalog.getLevel(1);
      final repo = PatchesPuzzleRepository();
      var completed = false;
      final game = PatchesGameProvider(
        level: level,
        repository: repo,
        onLevelCompleted: () => completed = true,
      );

      for (final sol in level.solutionPatches) {
        game.startDrag(GridPoint(sol.minRow, sol.minCol));
        game.updateDrag(GridPoint(sol.maxRow, sol.maxCol));
        game.endDrag();
      }

      expect(game.placedPatches.length, equals(level.solutionPatches.length));
      expect(game.isCompleted, isTrue);
      expect(completed, isTrue);

      game.dispose();
    });
  });
}
