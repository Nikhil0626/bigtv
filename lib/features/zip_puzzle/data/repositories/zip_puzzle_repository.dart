import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';
import '../models/level_progress.dart';

class ZipPuzzleRepository {
  static const String _keyPrefix = 'zip_puzzle_v1_';
  static const String _keyHighestUnlocked = '${_keyPrefix}highest_unlocked';
  static const String _keyProgressMap = '${_keyPrefix}progress_map';
  static const String _keyLeaderboards = '${_keyPrefix}leaderboards';
  static const String _keyPlayerName = '${_keyPrefix}player_name';
  static const String _keyHintsDate = '${_keyPrefix}hints_date';
  static const String _keyHintsUsed = '${_keyPrefix}hints_used';

  static const int maxDailyHints = 3;

  final SharedPreferences? _injectedPrefs;

  ZipPuzzleRepository({SharedPreferences? prefs}) : _injectedPrefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  Future<int> getHighestUnlockedLevel() async {
    try {
      final prefs = await _getPrefs();
      final level = prefs.getInt(_keyHighestUnlocked) ?? 1;
      return level < 1 ? 1 : level;
    } catch (e) {
      debugPrint('ZipPuzzleRepository getHighestUnlockedLevel error: $e');
      return 1;
    }
  }

  Future<void> setHighestUnlockedLevel(int level) async {
    try {
      final prefs = await _getPrefs();
      final clamped = level < 1 ? 1 : level;
      await prefs.setInt(_keyHighestUnlocked, clamped);
    } catch (e) {
      debugPrint('ZipPuzzleRepository setHighestUnlockedLevel error: $e');
    }
  }

  Future<Map<int, LevelProgress>> getAllLevelProgress(
      {int? totalLevels}) async {
    final Map<int, LevelProgress> result = {};
    try {
      final prefs = await _getPrefs();
      final highestUnlocked = prefs.getInt(_keyHighestUnlocked) ?? 1;
      final ceiling =
          totalLevels ?? (highestUnlocked > 100 ? highestUnlocked : 100);

      // Populate base unlock states
      for (int i = 1; i <= ceiling; i++) {
        result[i] = LevelProgress(
          levelNumber: i,
          isUnlocked: i <= highestUnlocked,
        );
      }

      final rawJson = prefs.getString(_keyProgressMap);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final lvl = int.tryParse(entry.key);
          if (lvl != null && lvl >= 1) {
            final data = entry.value as Map<String, dynamic>;
            final parsed = LevelProgress.fromJson(data);
            result[lvl] = parsed.copyWith(
              isUnlocked: parsed.isUnlocked || lvl <= highestUnlocked,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('ZipPuzzleRepository getAllLevelProgress error: $e');
    }
    return result;
  }

  Future<LevelProgress> getLevelProgress(int level) async {
    final all = await getAllLevelProgress();
    return all[level] ??
        LevelProgress(levelNumber: level, isUnlocked: level == 1);
  }

  Future<void> saveLevelCompletion({
    required int level,
    required int elapsedMs,
    String? playerName,
  }) async {
    if (elapsedMs < 0) return;
    try {
      final prefs = await _getPrefs();
      final currentHighest = prefs.getInt(_keyHighestUnlocked) ?? 1;
      int newHighest = currentHighest;
      if (level >= currentHighest) {
        newHighest = level + 1;
        await prefs.setInt(_keyHighestUnlocked, newHighest);
      }

      final all = await getAllLevelProgress();
      final currentProgress =
          all[level] ?? LevelProgress(levelNumber: level, isUnlocked: true);

      final int? newBest = (currentProgress.bestTimeMs == null ||
              elapsedMs < currentProgress.bestTimeMs!)
          ? elapsedMs
          : currentProgress.bestTimeMs;

      final updatedProgress = currentProgress.copyWith(
        isCompleted: true,
        isUnlocked: true,
        bestTimeMs: newBest,
        attemptsCount: currentProgress.attemptsCount + 1,
        firstCompletedAt: currentProgress.firstCompletedAt ?? DateTime.now(),
      );
      all[level] = updatedProgress;

      // Save updated progress map
      final serializedMap =
          all.map((k, v) => MapEntry(k.toString(), v.toJson()));
      await prefs.setString(_keyProgressMap, jsonEncode(serializedMap));

      // Record leaderboard entry
      final name = playerName ?? await getPlayerName();
      final entry = LeaderboardEntry(
        id: '${level}_${DateTime.now().millisecondsSinceEpoch}',
        levelNumber: level,
        playerName: name,
        elapsedMs: elapsedMs,
        timestamp: DateTime.now(),
      );
      await addLeaderboardEntry(entry);
    } catch (e) {
      debugPrint('ZipPuzzleRepository saveLevelCompletion error: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboardForLevel(int level) async {
    try {
      final prefs = await _getPrefs();
      final rawJson = prefs.getString('${_keyLeaderboards}_$level');
      if (rawJson == null || rawJson.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      final List<LeaderboardEntry> entries = decoded
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .where((e) => e.elapsedMs >= 0)
          .toList();

      // Sort ascending by elapsedMs, then by timestamp
      entries.sort((a, b) {
        final cmp = a.elapsedMs.compareTo(b.elapsedMs);
        if (cmp != 0) return cmp;
        return a.timestamp.compareTo(b.timestamp);
      });

      return entries;
    } catch (e) {
      debugPrint('ZipPuzzleRepository getLeaderboardForLevel error: $e');
      return [];
    }
  }

  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    if (entry.elapsedMs < 0) return;
    try {
      final prefs = await _getPrefs();
      final currentEntries = await getLeaderboardForLevel(entry.levelNumber);
      currentEntries.add(entry);

      currentEntries.sort((a, b) {
        final cmp = a.elapsedMs.compareTo(b.elapsedMs);
        if (cmp != 0) return cmp;
        return a.timestamp.compareTo(b.timestamp);
      });

      // Keep top 50 records per level
      final capped = currentEntries.take(50).toList();
      final serialized = capped.map((e) => e.toJson()).toList();
      await prefs.setString(
          '${_keyLeaderboards}_${entry.levelNumber}', jsonEncode(serialized));
    } catch (e) {
      debugPrint('ZipPuzzleRepository addLeaderboardEntry error: $e');
    }
  }

  Future<String> getPlayerName() async {
    try {
      final prefs = await _getPrefs();
      final name = prefs.getString(_keyPlayerName);
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    } catch (e) {
      debugPrint('ZipPuzzleRepository getPlayerName error: $e');
    }
    return 'You';
  }

  Future<void> setPlayerName(String name) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
          _keyPlayerName, name.trim().isEmpty ? 'You' : name.trim());
    } catch (e) {
      debugPrint('ZipPuzzleRepository setPlayerName error: $e');
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> getRemainingHintsToday() async {
    try {
      final prefs = await _getPrefs();
      final today = _todayKey();
      final savedDate = prefs.getString(_keyHintsDate);
      if (savedDate != today) {
        // Brand new day: reset daily hint counter to 3
        await prefs.setString(_keyHintsDate, today);
        await prefs.setInt(_keyHintsUsed, 0);
        return maxDailyHints;
      }
      final used = prefs.getInt(_keyHintsUsed) ?? 0;
      return (maxDailyHints - used).clamp(0, maxDailyHints);
    } catch (e) {
      debugPrint('ZipPuzzleRepository getRemainingHintsToday error: $e');
      return maxDailyHints;
    }
  }

  Future<bool> useHintToday() async {
    try {
      final prefs = await _getPrefs();
      final today = _todayKey();
      final savedDate = prefs.getString(_keyHintsDate);
      int used = 0;
      if (savedDate == today) {
        used = prefs.getInt(_keyHintsUsed) ?? 0;
      } else {
        await prefs.setString(_keyHintsDate, today);
      }

      if (used >= maxDailyHints) {
        return false; // Limit reached: exactly 3 hints a day
      }

      used++;
      await prefs.setInt(_keyHintsUsed, used);
      return true;
    } catch (e) {
      debugPrint('ZipPuzzleRepository useHintToday error: $e');
      return false;
    }
  }

  Future<void> resetDailyHintsForTesting({int? remaining}) async {
    try {
      final prefs = await _getPrefs();
      final today = _todayKey();
      await prefs.setString(_keyHintsDate, today);
      final used = remaining != null ? (maxDailyHints - remaining) : 0;
      await prefs.setInt(_keyHintsUsed, used.clamp(0, maxDailyHints));
    } catch (_) {}
  }
}
