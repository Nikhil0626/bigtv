import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/models/leaderboard_entry.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_puzzle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZipPuzzleRepository Persistence Tests', () {
    test('Clean save starts with Level 1 unlocked and higher levels locked',
        () async {
      final repo = ZipPuzzleRepository();

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
      final repo = ZipPuzzleRepository();

      await repo.saveLevelCompletion(level: 1, elapsedMs: 45000);

      final highest = await repo.getHighestUnlockedLevel();
      expect(highest, equals(2));

      final p1 = await repo.getLevelProgress(1);
      expect(p1.isCompleted, isTrue);
      expect(p1.bestTimeMs, equals(45000));
      expect(p1.formattedBestTime, equals('00:45'));

      final p2 = await repo.getLevelProgress(2);
      expect(p2.isUnlocked, isTrue);
      expect(p2.isCompleted, isFalse);
    });

    test('Best time updates only when a faster valid attempt is recorded',
        () async {
      final repo = ZipPuzzleRepository();

      await repo.saveLevelCompletion(level: 1, elapsedMs: 50000);
      var p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(50000));

      // Slower attempt (60s) should NOT overwrite best time
      await repo.saveLevelCompletion(level: 1, elapsedMs: 60000);
      p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(50000));
      expect(p.attemptsCount, equals(2));

      // Faster attempt (35s) SHOULD overwrite best time
      await repo.saveLevelCompletion(level: 1, elapsedMs: 35000);
      p = await repo.getLevelProgress(1);
      expect(p.bestTimeMs, equals(35000));
      expect(p.attemptsCount, equals(3));
    });

    test('Per-level leaderboard sorts fastest first with stable tie-breaking',
        () async {
      final repo = ZipPuzzleRepository();

      final t1 = DateTime(2026, 1, 1, 12, 0);
      final t2 = DateTime(2026, 1, 1, 12, 5);
      final t3 = DateTime(2026, 1, 1, 12, 10);

      await repo.addLeaderboardEntry(LeaderboardEntry(
        id: '1',
        levelNumber: 1,
        playerName: 'Alice',
        elapsedMs: 40000,
        timestamp: t1,
      ));

      await repo.addLeaderboardEntry(LeaderboardEntry(
        id: '2',
        levelNumber: 1,
        playerName: 'Bob',
        elapsedMs: 25000,
        timestamp: t2,
      ));

      await repo.addLeaderboardEntry(LeaderboardEntry(
        id: '3',
        levelNumber: 1,
        playerName: 'Charlie',
        elapsedMs: 25000, // tie with Bob on duration, but later timestamp
        timestamp: t3,
      ));

      // Add entry for level 2 to confirm no mixing
      await repo.addLeaderboardEntry(LeaderboardEntry(
        id: '4',
        levelNumber: 2,
        playerName: 'David',
        elapsedMs: 15000,
        timestamp: t1,
      ));

      final lb1 = await repo.getLeaderboardForLevel(1);
      expect(lb1.length, equals(3));
      expect(lb1[0].playerName, equals('Bob')); // 25s, earlier
      expect(lb1[1].playerName, equals('Charlie')); // 25s, later
      expect(lb1[2].playerName, equals('Alice')); // 40s

      final lb2 = await repo.getLeaderboardForLevel(2);
      expect(lb2.length, equals(1));
      expect(lb2[0].playerName, equals('David'));
    });

    test(
        'Corrupt saved data recovers gracefully without crashing or resetting valid progress',
        () async {
      SharedPreferences.setMockInitialValues({
        'zip_puzzle_v1_highest_unlocked': 5,
        'zip_puzzle_v1_progress_map': '{invalid_json_corrupted',
      });

      final repo = ZipPuzzleRepository();
      final highest = await repo.getHighestUnlockedLevel();
      expect(highest, equals(5));

      final all = await repo.getAllLevelProgress();
      expect(all.length, equals(100));
      expect(all[1]!.isUnlocked, isTrue);
      expect(all[5]!.isUnlocked, isTrue);
      expect(all[6]!.isUnlocked, isFalse);
    });

    test('Player name customization persists and defaults to "You"', () async {
      final repo = ZipPuzzleRepository();
      expect(await repo.getPlayerName(), equals('You'));

      await repo.setPlayerName('ProPlayer');
      expect(await repo.getPlayerName(), equals('ProPlayer'));
    });

    test('Daily hints limit allows exactly 3 hints per day and rejects 4th',
        () async {
      final repo = ZipPuzzleRepository();
      expect(await repo.getRemainingHintsToday(), equals(3));

      expect(await repo.useHintToday(), isTrue);
      expect(await repo.getRemainingHintsToday(), equals(2));

      expect(await repo.useHintToday(), isTrue);
      expect(await repo.getRemainingHintsToday(), equals(1));

      expect(await repo.useHintToday(), isTrue);
      expect(await repo.getRemainingHintsToday(), equals(0));

      // 4th attempt must be rejected
      expect(await repo.useHintToday(), isFalse);
      expect(await repo.getRemainingHintsToday(), equals(0));
    });
  });
}
