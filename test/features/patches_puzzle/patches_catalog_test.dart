import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_catalog.dart';

void main() {
  group('PatchesCatalog & Verification Specification Tests', () {
    test('Catalog contains exactly 100 unique levels', () {
      final levels = PatchesCatalog.allLevels;
      expect(levels.length, equals(100));

      final uniqueLevelNumbers = levels.map((l) => l.levelNumber).toSet();
      expect(uniqueLevelNumbers.length, equals(100));
      for (int i = 1; i <= 100; i++) {
        expect(uniqueLevelNumbers.contains(i), isTrue);
      }
    });

    test(
        'All 100 levels feature an interleaved difficulty distribution matching user spec',
        () {
      final levels = PatchesCatalog.allLevels;
      expect(levels.length, equals(100));

      expect(PatchesCatalog.getLevel(1).difficulty, equals(ZipDifficulty.hard));
      expect(PatchesCatalog.getLevel(2).difficulty, equals(ZipDifficulty.easy));
      expect(PatchesCatalog.getLevel(3).difficulty, equals(ZipDifficulty.medium));
      expect(PatchesCatalog.getLevel(4).difficulty, equals(ZipDifficulty.hard));

      // Verify overall counts across 100 levels
      final easyCount =
          levels.where((l) => l.difficulty == ZipDifficulty.easy).length;
      final mediumCount =
          levels.where((l) => l.difficulty == ZipDifficulty.medium).length;
      final hardCount =
          levels.where((l) => l.difficulty == ZipDifficulty.hard).length;
      final expertCount =
          levels.where((l) => l.difficulty == ZipDifficulty.expert).length;

      expect(easyCount, equals(20));
      expect(mediumCount, equals(30));
      expect(hardCount, equals(30));
      expect(expertCount, equals(20));
    });

    test(
        'Every single shipped level has a mathematically verified, valid solution tiling',
        () {
      for (int lvl = 1; lvl <= 100; lvl++) {
        final def = PatchesCatalog.getLevel(lvl);
        final totalGridCells = def.rows * def.cols;

        // 1. Solution patches must tile the grid
        int totalPatchArea = 0;
        final coveredCells = <String>{};

        for (final patch in def.solutionPatches) {
          totalPatchArea += patch.area;

          // Bounds check
          expect(patch.minRow >= 0 && patch.maxRow < def.rows, isTrue,
              reason: 'Level $lvl patch row out of bounds');
          expect(patch.minCol >= 0 && patch.maxCol < def.cols, isTrue,
              reason: 'Level $lvl patch col out of bounds');

          for (final cell in patch.cells) {
            final key = '${cell.row},${cell.col}';
            expect(coveredCells.contains(key), isFalse,
                reason: 'Level $lvl patches overlap at $key');
            coveredCells.add(key);
          }

          // 2. Clue consistency check
          final matchingClue =
              def.clues.where((c) => c.id == patch.clueId).toList();
          expect(matchingClue.length, equals(1),
              reason: 'Level $lvl patch must correspond to exactly one clue');
          final clue = matchingClue.first;

          // Patch must cover its own clue point
          expect(patch.contains(clue.point), isTrue,
              reason: 'Level $lvl patch must contain its clue position');

          // Patch area must match clue size if targetArea is specified
          if (clue.targetArea != null) {
            expect(patch.area, equals(clue.targetArea),
                reason: 'Level $lvl patch area must match clue targetArea');
          }

          // Shape constraint must be satisfied
          expect(clue.shapeType.matches(patch.width, patch.height), isTrue,
              reason: 'Level $lvl shape constraint not satisfied');
        }

        // Total area must equal grid area
        expect(totalPatchArea, equals(totalGridCells),
            reason: 'Level $lvl solution patches must cover entire grid');
        expect(coveredCells.length, equals(totalGridCells),
            reason: 'Level $lvl all grid cells must be covered');
      }
    });
  });
}
