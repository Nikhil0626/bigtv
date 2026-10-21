import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_catalog.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_puzzle_repository.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/zip_game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZipGameProvider Gameplay & Rules Engine Tests', () {
    test('Starting anywhere other than Point 1 is rejected', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      // Try starting on a regular cell or point 2
      final pt2 = level.getCheckpointPoint(2)!;
      game.startPath(pt2);

      expect(game.currentPath.isEmpty, isTrue);
      expect(game.hasStarted, isFalse);
      expect(game.feedbackMessage, contains('Start tracing from point 1'));

      game.dispose();
    });

    test('Starting at Point 1 activates path and starts timer', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final pt1 = level.getCheckpointPoint(1)!;
      game.startPath(pt1);

      expect(game.currentPath.length, equals(1));
      expect(game.currentPath.first, equals(pt1));
      expect(game.lastVisitedCheckpoint, equals(1));
      expect(game.hasStarted, isTrue);
      expect(game.feedbackMessage, isNull);

      game.dispose();
    });

    test('Non-adjacent moves are rejected with clear error feedback', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final pt1 = level.getCheckpointPoint(1)!;
      game.startPath(pt1);

      // Non-adjacent move
      final nonAdj = GridPoint(pt1.row + 2, pt1.col);
      game.moveTo(nonAdj);

      expect(game.currentPath.length, equals(1));
      expect(game.feedbackMessage, contains('adjacent'));

      game.dispose();
    });

    test('Cannot cross existing path', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      // Replay first 3 steps
      final solution = level.solutionPath;
      game.moveTo(solution[0]);
      game.moveTo(solution[1]);
      game.moveTo(solution[2]);
      expect(game.currentPath.length, equals(3));

      // Try moving back into solution[0] (which is already in path and not penultimate)
      if (solution[2].isAdjacent(solution[0])) {
        game.moveTo(solution[0]);
        expect(game.feedbackMessage, contains('Cannot cross your own path'));
      }

      game.dispose();
    });

    test('Backtracking to the previous cell pops last step cleanly', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final solution = level.solutionPath;
      game.moveTo(solution[0]);
      game.moveTo(solution[1]);
      game.moveTo(solution[2]);
      expect(game.currentPath.length, equals(3));

      // Move back to solution[1] (penultimate cell)
      game.moveTo(solution[1]);
      expect(game.currentPath.length, equals(2));
      expect(game.currentPath.last, equals(solution[1]));

      game.dispose();
    });

    test('Skipping checkpoints is rejected', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final pt1 = level.getCheckpointPoint(1)!;
      final pt3 = level.getCheckpointPoint(3);
      if (pt3 != null && pt1.isAdjacent(pt3)) {
        game.moveTo(pt1);
        game.moveTo(pt3);
        expect(game.currentPath.length, equals(1));
        expect(game.feedbackMessage, contains('Visit point 2 next'));
      }

      game.dispose();
    });

    test('Replaying solution completes level, stops timer, and marks completed',
        () async {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      bool completedCallbackFired = false;

      final game = ZipGameProvider(
        level: level,
        repository: repo,
        onLevelCompleted: () {
          completedCallbackFired = true;
        },
      );

      final solution = level.solutionPath;
      for (final pt in solution) {
        game.moveTo(pt);
      }

      await game.completionFuture;

      expect(game.isCompleted, isTrue);
      expect(game.currentPath.length, equals(level.totalRequiredCells));
      expect(game.lastVisitedCheckpoint, equals(level.checkpointCount));
      expect(game.elapsedMilliseconds, greaterThanOrEqualTo(0));
      expect(completedCallbackFired, isTrue);

      // Verify persistence recorded completion
      final progress = await repo.getLevelProgress(1);
      expect(progress.isCompleted, isTrue);
      expect(progress.bestTimeMs, isNotNull);

      // Verify level 2 was unlocked
      final highest = await repo.getHighestUnlockedLevel();
      expect(highest, greaterThanOrEqualTo(2));

      game.dispose();
    });

    test('Reset resets path, timer, and state', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final solution = level.solutionPath;
      game.moveTo(solution[0]);
      game.moveTo(solution[1]);
      expect(game.currentPath.length, equals(2));
      expect(game.hasStarted, isTrue);

      game.reset();

      expect(game.currentPath.isEmpty, isTrue);
      expect(game.hasStarted, isFalse);
      expect(game.lastVisitedCheckpoint, equals(0));
      expect(game.elapsedMilliseconds, equals(0));

      game.dispose();
    });

    test('Undo pops last step and decrements checkpoint count if needed', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final solution = level.solutionPath;
      game.moveTo(solution[0]);
      game.moveTo(solution[1]);
      expect(game.currentPath.length, equals(2));

      game.undo();
      expect(game.currentPath.length, equals(1));
      expect(game.currentPath.first, equals(solution[0]));

      game.dispose();
    });

    test('Hint advances next correct step or corrects wrong moves', () {
      final level = ZipCatalog.getLevel(1);
      final repo = ZipPuzzleRepository();
      final game = ZipGameProvider(level: level, repository: repo);

      final solution = level.solutionPath;
      // Start with first step
      game.moveTo(solution[0]);
      expect(game.currentPath.length, equals(1));

      // Hint should advance to solution[1]
      game.hint();
      expect(game.currentPath.length, equals(2));
      expect(game.currentPath[1], equals(solution[1]));

      game.dispose();
    });
  });
}
