import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_catalog.dart';

void main() {
  group('ZipCatalog & Schedule Specification Tests', () {
    test('Catalog contains exactly 100 unique levels', () {
      final levels = ZipCatalog.allLevels;
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
      final levels = ZipCatalog.allLevels;
      expect(levels.length, equals(100));

      // Level 1: Easy, Level 2: Hard, Level 3: Medium (as requested)
      expect(ZipCatalog.getLevel(1).difficulty, equals(ZipDifficulty.easy));
      expect(ZipCatalog.getLevel(2).difficulty, equals(ZipDifficulty.hard));
      expect(ZipCatalog.getLevel(3).difficulty, equals(ZipDifficulty.medium));
      expect(ZipCatalog.getLevel(4).difficulty, equals(ZipDifficulty.expert));

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
        'Every single shipped level has a mathematically verified, valid solution',
        () {
      for (int lvl = 1; lvl <= 100; lvl++) {
        final def = ZipCatalog.getLevel(lvl);
        final solution = def.solutionPath;

        // 1. Path must not be empty and must equal totalRequiredCells
        expect(solution.isNotEmpty, isTrue,
            reason: 'Level $lvl solution cannot be empty');
        expect(solution.length, equals(def.totalRequiredCells),
            reason: 'Level $lvl solution length must equal totalRequiredCells');

        // 2. All cells in path must be unique (no self-intersection)
        final uniqueCells = solution.toSet();
        expect(uniqueCells.length, equals(solution.length),
            reason: 'Level $lvl solution contains duplicate cells');

        // 3. Every adjacent step in solution must be orthogonally connected
        for (int i = 0; i < solution.length - 1; i++) {
          final curr = solution[i];
          final next = solution[i + 1];
          expect(curr.isAdjacent(next), isTrue,
              reason:
                  'Level $lvl step $i -> ${i + 1} ($curr -> $next) is not orthogonally adjacent');
        }

        // 4. Checkpoints must be ordered 1 to checkpointCount
        expect(def.checkpoints.length, equals(def.checkpointCount),
            reason:
                'Level $lvl checkpoints map count must equal checkpointCount');

        // Point 1 must be at the very start of the solution path
        expect(def.getCheckpointNumber(solution.first), equals(1),
            reason: 'Level $lvl start must be checkpoint 1');

        // Point N must be at the very end of the solution path
        expect(
            def.getCheckpointNumber(solution.last), equals(def.checkpointCount),
            reason: 'Level $lvl end must be checkpoint ${def.checkpointCount}');

        // Every checkpoint 1..N must appear along the solution in strictly increasing order
        int expectedNextCp = 1;
        for (final pt in solution) {
          final cp = def.getCheckpointNumber(pt);
          if (cp != null) {
            expect(cp, equals(expectedNextCp),
                reason:
                    'Level $lvl checkpoints must be visited in strict order 1..N');
            expectedNextCp++;
          }
        }
        expect(expectedNextCp - 1, equals(def.checkpointCount),
            reason: 'Level $lvl all checkpoints must be visited');
      }
    });
  });
}
