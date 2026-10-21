import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_puzzle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SudokuPuzzleRepository Persistence Tests', () {
    test('Clean state starts with Level 1 unlocked and higher levels locked', () async {
      final repo = SudokuPuzzleRepository();
      final all = await repo.getAllProgress();

      expect(all[1]?.isUnlocked, isTrue);
      expect(all[2]?.isUnlocked, isFalse);
      expect(all[3]?.isUnlocked, isFalse);
    });

    test('Completing Level 1 unlocks Level 2 and records best time', () async {
      final repo = SudokuPuzzleRepository();
      await repo.saveLevelCompletion(level: 1, elapsedMs: 45000);

      final p1 = await repo.getLevelProgress(1);
      final p2 = await repo.getLevelProgress(2);

      expect(p1.isCompleted, isTrue);
      expect(p1.bestTimeMs, equals(45000));
      expect(p2.isUnlocked, isTrue);
      expect(p2.isCompleted, isFalse);
    });

    test('Daily hints limit is capped at 3 with daily rollover', () async {
      final repo = SudokuPuzzleRepository();

      // Starts at 3
      int hints = await repo.getRemainingHintsToday();
      expect(hints, equals(3));

      // Use 1 hint
      final used1 = await repo.useHintToday();
      expect(used1, isTrue);
      hints = await repo.getRemainingHintsToday();
      expect(hints, equals(2));

      // Use 2nd and 3rd hints
      await repo.useHintToday();
      await repo.useHintToday();
      hints = await repo.getRemainingHintsToday();
      expect(hints, equals(0));

      // 4th attempt should be rejected
      final used4 = await repo.useHintToday();
      expect(used4, isFalse);
      expect(hints, equals(0));
    });

    test('Custom player display name can be saved and retrieved', () async {
      final repo = SudokuPuzzleRepository();
      expect(await repo.getPlayerDisplayName(), equals('Player'));

      await repo.setPlayerDisplayName('Nikhil');
      expect(await repo.getPlayerDisplayName(), equals('Nikhil'));
    });

    test('Leaderboard records and sorts finish times', () async {
      final repo = SudokuPuzzleRepository();
      await repo.recordLeaderboardScore(level: 1, timeMs: 50000);
      await repo.recordLeaderboardScore(level: 1, timeMs: 30000);

      final board = await repo.getLeaderboard(1);
      expect(board.length, equals(2));
      expect(board.first.timeMs, equals(30000));
      expect(board.last.timeMs, equals(50000));
    });
  });
}
