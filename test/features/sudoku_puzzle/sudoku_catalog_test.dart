import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_catalog.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';

void main() {
  group('SudokuCatalog Specification & Validation Tests (6x6 Sudoku)', () {
    test('Catalog contains exactly 100 levels', () {
      expect(SudokuCatalog.totalLevels, equals(100));
      expect(SudokuCatalog.allLevels.length, equals(100));
    });

    test('All 100 levels have valid 6x6 dimensions and 6 numbers in each 2x3 box', () {
      for (int i = 1; i <= SudokuCatalog.totalLevels; i++) {
        final level = SudokuCatalog.getLevel(i);
        expect(level.levelNumber, equals(i));
        expect(level.size, equals(6));
        expect(level.initialGrid.length, equals(6));
        expect(level.solutionGrid.length, equals(6));

        int givensCount = 0;
        for (int r = 0; r < 6; r++) {
          expect(level.initialGrid[r].length, equals(6));
          expect(level.solutionGrid[r].length, equals(6));

          for (int c = 0; c < 6; c++) {
            final initVal = level.initialGrid[r][c];
            final solVal = level.solutionGrid[r][c];

            expect(solVal, inInclusiveRange(1, 6),
                reason: 'Level $i solution at ($r, $c) must be 1..6');

            if (initVal != 0) {
              givensCount++;
              expect(initVal, equals(solVal),
                  reason: 'Level $i given at ($r, $c) must match solution');
            }
          }
        }

        // Validate Solution Grid: Rows (1..6)
        for (int r = 0; r < 6; r++) {
          final rowSet = level.solutionGrid[r].toSet();
          expect(rowSet.length, equals(6),
              reason: 'Level $i Row $r has duplicates');
        }

        // Validate Solution Grid: Columns (1..6)
        for (int c = 0; c < 6; c++) {
          final colSet = {for (int r = 0; r < 6; r++) level.solutionGrid[r][c]};
          expect(colSet.length, equals(6),
              reason: 'Level $i Col $c has duplicates');
        }

        // Validate Solution Grid: 2x3 Boxes (exactly 6 numbers in each box: 1..6)
        for (int br = 0; br < 6; br += 2) {
          for (int bc = 0; bc < 6; bc += 3) {
            final blockSet = <int>{};
            for (int dr = 0; dr < 2; dr++) {
              for (int dc = 0; dc < 3; dc++) {
                blockSet.add(level.solutionGrid[br + dr][bc + dc]);
              }
            }
            expect(blockSet.length, equals(6),
                reason: 'Level $i 2x3 Box at ($br, $bc) must have 6 unique numbers');
          }
        }

        expect(givensCount, inInclusiveRange(8, 24),
            reason: 'Level $i has unexpected givens count: $givensCount');
      }
    });

    test('Catalog contains interleaved difficulties', () {
      final diffs = SudokuCatalog.allLevels.map((l) => l.difficulty).toSet();
      expect(diffs.contains(ZipDifficulty.easy), isTrue);
      expect(diffs.contains(ZipDifficulty.medium), isTrue);
      expect(diffs.contains(ZipDifficulty.hard), isTrue);
      expect(diffs.contains(ZipDifficulty.expert), isTrue);
    });
  });
}
