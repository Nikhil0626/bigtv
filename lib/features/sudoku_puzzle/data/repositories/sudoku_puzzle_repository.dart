import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_level_progress.dart';
import 'sudoku_catalog.dart';

class SudokuLeaderboardEntry {
  final String playerName;
  final int timeMs;
  final DateTime achievedAt;
  final bool isUser;

  const SudokuLeaderboardEntry({
    required this.playerName,
    required this.timeMs,
    required this.achievedAt,
    this.isUser = false,
  });

  String get formattedTime {
    final totalSec = (timeMs / 1000).floor();
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'timeMs': timeMs,
        'achievedAt': achievedAt.toIso8601String(),
        'isUser': isUser,
      };

  factory SudokuLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return SudokuLeaderboardEntry(
      playerName: json['playerName'] as String,
      timeMs: json['timeMs'] as int,
      achievedAt: DateTime.tryParse(json['achievedAt'] as String? ?? '') ??
          DateTime.now(),
      isUser: json['isUser'] as bool? ?? false,
    );
  }
}

class SudokuPuzzleRepository {
  static const String _progressKey = 'sudoku_progress_v1';
  static const String _hintsDateKey = 'sudoku_hints_date';
  static const String _hintsCountKey = 'sudoku_hints_count';
  static const String _leaderboardKey = 'sudoku_leaderboard_v1';
  static const String _displayNameKey = 'sudoku_player_display_name';

  static const int maxDailyHints = 3;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> getRemainingHintsToday() async {
    final prefs = await _prefs;
    final today = _todayDateString();
    final lastDate = prefs.getString(_hintsDateKey);

    if (lastDate != today) {
      await prefs.setString(_hintsDateKey, today);
      await prefs.setInt(_hintsCountKey, 0);
      return maxDailyHints;
    }

    final used = prefs.getInt(_hintsCountKey) ?? 0;
    return (maxDailyHints - used).clamp(0, maxDailyHints);
  }

  Future<bool> useHintToday() async {
    final prefs = await _prefs;
    final remaining = await getRemainingHintsToday();
    if (remaining <= 0) return false;

    final used = prefs.getInt(_hintsCountKey) ?? 0;
    await prefs.setInt(_hintsCountKey, used + 1);
    return true;
  }

  Future<Map<int, SudokuLevelProgress>> getAllProgress() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_progressKey);
    final map = <int, SudokuLevelProgress>{};

    // Default: Level 1 is unlocked
    map[1] = const SudokuLevelProgress(levelNumber: 1, isUnlocked: true, isCompleted: false);
    for (int i = 2; i <= SudokuCatalog.totalLevels; i++) {
      map[i] = SudokuLevelProgress(levelNumber: i, isUnlocked: false, isCompleted: false);
    }

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final levelNum = int.tryParse(entry.key);
          if (levelNum != null) {
            map[levelNum] = SudokuLevelProgress.fromJson(
                entry.value as Map<String, dynamic>);
          }
        }
      } catch (_) {}
    }

    return map;
  }

  Future<SudokuLevelProgress> getLevelProgress(int levelNumber) async {
    final all = await getAllProgress();
    return all[levelNumber] ??
        SudokuLevelProgress(
          levelNumber: levelNumber,
          isUnlocked: levelNumber == 1,
          isCompleted: false,
        );
  }

  Future<void> saveLevelCompletion({
    required int level,
    required int elapsedMs,
    int stars = 3,
  }) async {
    final prefs = await _prefs;
    final all = await getAllProgress();
    final current = all[level] ??
        SudokuLevelProgress(levelNumber: level, isUnlocked: true, isCompleted: false);

    final newBestTime = (current.bestTimeMs == null || elapsedMs < current.bestTimeMs!)
        ? elapsedMs
        : current.bestTimeMs;

    all[level] = current.copyWith(
      isCompleted: true,
      bestTimeMs: newBestTime,
      stars: stars > current.stars ? stars : current.stars,
    );

    // Automatically unlock the next level
    if (level < SudokuCatalog.totalLevels) {
      final next = all[level + 1] ??
          SudokuLevelProgress(levelNumber: level + 1, isUnlocked: false, isCompleted: false);
      all[level + 1] = next.copyWith(isUnlocked: true);
    }

    final encoded = jsonEncode(
      all.map((key, value) => MapEntry(key.toString(), value.toJson())),
    );
    await prefs.setString(_progressKey, encoded);

    // Save to local device leaderboard
    await recordLeaderboardScore(level: level, timeMs: elapsedMs);
  }

  Future<String> getPlayerDisplayName() async {
    final prefs = await _prefs;
    return prefs.getString(_displayNameKey) ?? 'Player';
  }

  Future<void> setPlayerDisplayName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_displayNameKey, name.trim().isEmpty ? 'Player' : name.trim());
  }

  Future<List<SudokuLeaderboardEntry>> getLeaderboard(int level) async {
    final prefs = await _prefs;
    final raw = prefs.getString('${_leaderboardKey}_$level');
    final entries = <SudokuLeaderboardEntry>[];

    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          entries.add(
              SudokuLeaderboardEntry.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    entries.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    return entries;
  }

  Future<void> recordLeaderboardScore({
    required int level,
    required int timeMs,
  }) async {
    final prefs = await _prefs;
    final currentList = await getLeaderboard(level);
    final playerName = await getPlayerDisplayName();

    currentList.add(SudokuLeaderboardEntry(
      playerName: playerName,
      timeMs: timeMs,
      achievedAt: DateTime.now(),
      isUser: true,
    ));

    currentList.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    final capped = currentList.take(20).toList();

    final encoded = jsonEncode(capped.map((e) => e.toJson()).toList());
    await prefs.setString('${_leaderboardKey}_$level', encoded);
  }
}
