import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/models/leaderboard_entry.dart';
import '../models/patches_level_progress.dart';

class PatchesPuzzleRepository {
  static const String _keyPrefix = 'patches_puzzle_v1_';
  static const String _keyHighestUnlocked = '${_keyPrefix}highest_unlocked';
  static const String _keyProgressMap = '${_keyPrefix}progress_map';
  static const String _keyLeaderboards = '${_keyPrefix}leaderboards';
  static const String _keyPlayerName = '${_keyPrefix}player_name';
  static const String _keyHintsDate = '${_keyPrefix}hints_date';
  static const String _keyHintsUsed = '${_keyPrefix}hints_used';

  static const int maxDailyHints = 3;

  final SharedPreferences? _injectedPrefs;

  PatchesPuzzleRepository({SharedPreferences? prefs})
      : _injectedPrefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  Future<int> getHighestUnlockedLevel() async {
    try {
      final prefs = await _getPrefs();
      final level = prefs.getInt(_keyHighestUnlocked) ?? 1;
      return level.clamp(1, 100);
    } catch (e) {
      debugPrint('PatchesPuzzleRepository getHighestUnlockedLevel error: $e');
      return 1;
    }
  }

  Future<void> setHighestUnlockedLevel(int level) async {
    try {
      final prefs = await _getPrefs();
      final clamped = level.clamp(1, 100);
      await prefs.setInt(_keyHighestUnlocked, clamped);
    } catch (e) {
      debugPrint('PatchesPuzzleRepository setHighestUnlockedLevel error: $e');
    }
  }

  Future<Map<int, PatchesLevelProgress>> getAllLevelProgress() async {
    final Map<int, PatchesLevelProgress> result = {};
    try {
      final prefs = await _getPrefs();
      final highestUnlocked = prefs.getInt(_keyHighestUnlocked) ?? 1;

      for (int i = 1; i <= 100; i++) {
        result[i] = PatchesLevelProgress(
          levelNumber: i,
          isUnlocked: i <= highestUnlocked,
        );
      }

      final rawJson = prefs.getString(_keyProgressMap);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final lvl = int.tryParse(entry.key);
          if (lvl != null && lvl >= 1 && lvl <= 100) {
            final data = entry.value as Map<String, dynamic>;
            final parsed = PatchesLevelProgress.fromJson(data);
            result[lvl] = parsed.copyWith(
              isUnlocked: parsed.isUnlocked || lvl <= highestUnlocked,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('PatchesPuzzleRepository getAllLevelProgress error: $e');
    }
    return result;
  }

  Future<PatchesLevelProgress> getLevelProgress(int level) async {
    final all = await getAllLevelProgress();
    return all[level] ??
        PatchesLevelProgress(levelNumber: level, isUnlocked: level == 1);
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
      if (level >= currentHighest && level < 100) {
        newHighest = level + 1;
        await prefs.setInt(_keyHighestUnlocked, newHighest);
      }

      final all = await getAllLevelProgress();
      final currentProgress = all[level] ??
          PatchesLevelProgress(levelNumber: level, isUnlocked: true);

      final isBetter = currentProgress.bestTimeMs == null ||
          elapsedMs < currentProgress.bestTimeMs!;
      final updatedBest =
          isBetter ? elapsedMs : currentProgress.bestTimeMs;

      final updatedProgress = currentProgress.copyWith(
        isCompleted: true,
        isUnlocked: true,
        bestTimeMs: updatedBest,
        attemptsCount: currentProgress.attemptsCount + 1,
        lastCompletedAt: DateTime.now(),
      );

      all[level] = updatedProgress;

      final serialized = <String, dynamic>{};
      all.forEach((lvl, p) {
        if (p.isCompleted || p.isUnlocked) {
          serialized['$lvl'] = p.toJson();
        }
      });
      await prefs.setString(_keyProgressMap, jsonEncode(serialized));

      final resolvedName = playerName ?? await getPlayerName();
      await addLeaderboardEntry(
        LeaderboardEntry(
          id: '${level}_${DateTime.now().millisecondsSinceEpoch}',
          levelNumber: level,
          playerName: resolvedName,
          elapsedMs: elapsedMs,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('PatchesPuzzleRepository saveLevelCompletion error: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboardForLevel(int level) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('${_keyLeaderboards}_$level');
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.elapsedMs.compareTo(b.elapsedMs));
      return list;
    } catch (e) {
      debugPrint('PatchesPuzzleRepository getLeaderboardForLevel error: $e');
      return [];
    }
  }

  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    try {
      final prefs = await _getPrefs();
      final currentEntries =
          await getLeaderboardForLevel(entry.levelNumber);
      currentEntries.add(entry);
      currentEntries.sort((a, b) {
        final cmp = a.elapsedMs.compareTo(b.elapsedMs);
        if (cmp != 0) return cmp;
        return a.timestamp.compareTo(b.timestamp);
      });

      final capped = currentEntries.take(50).toList();
      final serialized = capped.map((e) => e.toJson()).toList();
      await prefs.setString(
          '${_keyLeaderboards}_${entry.levelNumber}', jsonEncode(serialized));
    } catch (e) {
      debugPrint('PatchesPuzzleRepository addLeaderboardEntry error: $e');
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
      debugPrint('PatchesPuzzleRepository getPlayerName error: $e');
    }
    return 'You';
  }

  Future<void> setPlayerName(String name) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
          _keyPlayerName, name.trim().isEmpty ? 'You' : name.trim());
    } catch (e) {
      debugPrint('PatchesPuzzleRepository setPlayerName error: $e');
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
        await prefs.setString(_keyHintsDate, today);
        await prefs.setInt(_keyHintsUsed, 0);
        return maxDailyHints;
      }
      final used = prefs.getInt(_keyHintsUsed) ?? 0;
      return (maxDailyHints - used).clamp(0, maxDailyHints);
    } catch (e) {
      debugPrint('PatchesPuzzleRepository getRemainingHintsToday error: $e');
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
        return false;
      }

      used++;
      await prefs.setInt(_keyHintsUsed, used);
      return true;
    } catch (e) {
      debugPrint('PatchesPuzzleRepository useHintToday error: $e');
      return false;
    }
  }
}
