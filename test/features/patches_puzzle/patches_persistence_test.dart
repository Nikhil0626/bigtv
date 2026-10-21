import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/models/leaderboard_entry.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_puzzle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PatchesPuzzleRepository Persistence Tests', () {
    test('Clean save starts with Level 1 unlocked and higher levels locked',
        () async {
      final repo = PatchesPuzzleRepository();

      final highest = await repo.getHighestUnlockedLevel();
      expect(highest, equals(1));

      final all = await repo.getAllLevelProgress();
      expect(all.length, equals(100));
      expect(all[1]!.isUnlocked, isTrue);
      expect(all[1]!.isCompleted, isFalse);
      expect(all[2]!.isUnlocked, isFalse);
      expect(all[100]!.isUnlocked, isFalse);
    });

    test('Completing Level 1 unlocks Level 2 and records best time', () async {
      final repo = PatchesPuzzleRepository();

      await repo.saveLevelCompletion(level: 1, elapsedMs: 42000);

      final highest = await repo.getHighestUnlockedLevel();
      expect(highest, equals(2));

      final p1 = await repo.getLevelProgress(1);
      expect(p1.isCompleted, isTrue);
      expect(p1.bestTimeMs, equals(42000));
      expect(p1.formattedBestTime, equals('00:42'));

      final p2 = await repo.getLevelProgress(2);
      expect(p2.isUnlocked, isTrue);
      expect(p2.isCompleted, isFalse);
    });

    test('Best time updates only when a faster valid attempt is recorded',
        () async {
      final repo = PatchesPuzzleRepository();

      await repo.saveLevelCompletion(level: 1, elapsedMs: 50000);
      var p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(50000));

      // Slower attempt (60s) should NOT overwrite best time
      await repo.saveLevelCompletion(level: 1, elapsedMs: 60000);
      p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(50000));
      expect(p.attemptsCount, equals(2));

      // Faster attempt (38s) SHOULD overwrite best time
      await repo.saveLevelCompletion(level: 1, elapsedMs: 38000);
      p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(38000));
      expect(p.attemptsCount, equals(3));
    });

    test('Daily hint quota allows max 3 hints per day and resets on date change',
        () async {
      final repo = PatchesPuzzleRepository();

      // Fresh day: 3 hints available
      var remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(3));

      // Use 1 hint
      await repo.useHintToday();
      remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(2));

      // Use 2nd hint
      await repo.useHintToday();
      remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(1));

      // Use 3rd hint
      await repo.useHintToday();
      remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(0));

      // Trying to use a 4th hint should remain capped at 0
      await repo.useHintToday();
      remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(0));

      // Simulate next day in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'patches_puzzle_v1_hints_date', '2020-01-01'); // Past date
      remaining = await repo.getRemainingHintsToday();
      expect(remaining, equals(3),
          reason: 'Daily hints must reset to 3 on new day');
    });

    test('Player name getter and setter works correctly', () async {
      final repo = PatchesPuzzleRepository();

      var name = await repo.getPlayerName();
      expect(name, equals('You'));

      await repo.setPlayerName('Champion');
      name = await repo.getPlayerName();
      expect(name, equals('Champion'));
    });

    test('Leaderboard records multiple entries and sorts ascending by elapsedMs',
        () async {
      final repo = PatchesPuzzleRepository();

      await repo.addLeaderboardEntry(
        LeaderboardEntry(
          id: '1_1',
          levelNumber: 1,
          playerName: 'Alice',
          elapsedMs: 65000,
          timestamp: DateTime.now(),
        ),
      );

      await repo.addLeaderboardEntry(
        LeaderboardEntry(
          id: '1_2',
          levelNumber: 1,
          playerName: 'Bob',
          elapsedMs: 25000,
          timestamp: DateTime.now(),
        ),
      );

      await repo.addLeaderboardEntry(
        LeaderboardEntry(
          id: '1_3',
          levelNumber: 1,
          playerName: 'Charlie',
          elapsedMs: 40000,
          timestamp: DateTime.now(),
        ),
      );

      final entries = await repo.getLeaderboardForLevel(1);
      expect(entries.length, equals(3));

      // Ascending sort: Bob (25s) -> Charlie (40s) -> Alice (65s)
      expect(entries[0].playerName, equals('Bob'));
      expect(entries[0].elapsedMs, equals(25000));
      expect(entries[1].playerName, equals('Charlie'));
      expect(entries[1].elapsedMs, equals(40000));
      expect(entries[2].playerName, equals('Alice'));
      expect(entries[2].elapsedMs, equals(65000));
    });
  });
}
