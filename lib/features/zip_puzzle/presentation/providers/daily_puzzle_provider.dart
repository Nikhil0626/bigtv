import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/local_data.dart';
import '../../data/mappers/zip_level_definition_mapper.dart';
import '../../data/models/daily_puzzle_models.dart';
import '../../data/models/grid_point.dart';
import '../../data/models/level_definition.dart';
import '../../data/repositories/puzzle_games_api_client.dart';
import '../../data/repositories/zip_puzzle_repository.dart';

class DailyPuzzleProvider extends ChangeNotifier {
  final PuzzleGamesApiClient _apiClient;
  final ZipPuzzleRepository _repository;

  String _gameId = 'zip';
  String _playerId = '';
  String _displayName = 'You';

  // Per-game segregated state to prevent cross-game completion leaks
  final Map<String, DailyGameData> _todayPuzzleByGame = {};
  final Map<String, LevelDefinition> _todayLevelDefinitionByGame = {};
  final Map<String, StreakCalendarResponse> _streakCalendarByGame = {};
  final Map<String, DailyLeaderboardResponse> _dailyLeaderboardByGame = {};
  final Map<String, DailySubmissionResult> _lastSubmissionsByGame = {};
  final Map<String, List<GridPoint>> _completedPathByGame = {};

  bool _isLoadingToday = false;
  bool _isLoadingStreak = false;
  bool _isLoadingLeaderboard = false;
  bool _isSubmitting = false;
  bool _isRequestingRecovery = false;
  String? _errorMessage;

  DailyPuzzleProvider({
    PuzzleGamesApiClient? apiClient,
    ZipPuzzleRepository? repository,
  })  : _apiClient = apiClient ?? PuzzleGamesApiClient(),
        _repository = repository ?? ZipPuzzleRepository();

  String _normalizeGameId(String id) {
    final clean = id.trim().toLowerCase();
    if (clean == 'zip_puzzle' || clean.isEmpty) return 'zip';
    if (clean == 'patches') return 'patch';
    return clean;
  }

  String get gameId => _gameId;
  String get playerId => _playerId;
  String get displayName => _displayName;
  DailyGameData? get todayPuzzle => _todayPuzzleByGame[_gameId];
  LevelDefinition? get todayLevelDefinition => _todayLevelDefinitionByGame[_gameId];
  StreakCalendarResponse? get streakCalendar => _streakCalendarByGame[_gameId];
  DailyLeaderboardResponse? get dailyLeaderboard => _dailyLeaderboardByGame[_gameId];
  DailySubmissionResult? get lastSubmissionResult => _lastSubmissionsByGame[_gameId];
  List<GridPoint>? get completedPath => _completedPathByGame[_gameId];

  bool get isLoadingToday => _isLoadingToday;
  bool get isLoadingStreak => _isLoadingStreak;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isSubmitting => _isSubmitting;
  bool get isRequestingRecovery => _isRequestingRecovery;
  String? get errorMessage => _errorMessage;

  DailySubmissionResult? getLastSubmissionForGame(String gameId) {
    return _lastSubmissionsByGame[_normalizeGameId(gameId)];
  }

  StreakCalendarResponse? getStreakCalendarForGame(String gameId) {
    return _streakCalendarByGame[_normalizeGameId(gameId)];
  }

  bool isGameCompletedToday(String gameId) {
    final cleanId = _normalizeGameId(gameId);
    if (_lastSubmissionsByGame[cleanId] != null) return true;
    final calendar = _streakCalendarByGame[cleanId];
    if (calendar != null) {
      for (final day in calendar.last7Days) {
        if (day.isToday && day.completed) {
          return true;
        }
      }
    }
    return false;
  }

  bool get isTodayCompleted => isGameCompletedToday(_gameId);

  int get currentStreak =>
      _lastSubmissionsByGame[_gameId]?.streak.currentStreak ??
      _streakCalendarByGame[_gameId]?.currentStreak ??
      0;

  int get longestStreak =>
      _lastSubmissionsByGame[_gameId]?.streak.longestStreak ??
      _streakCalendarByGame[_gameId]?.longestStreak ??
      0;

  bool get monthlyFreeReviveAvailable =>
      _streakCalendarByGame[_gameId]?.monthlyFreeReviveAvailable ?? true;

  bool get canRequestRecovery =>
      _streakCalendarByGame[_gameId]?.canRequestRecovery ?? false;

  int get gapDays => _streakCalendarByGame[_gameId]?.gapDays ?? 0;

  int get autoApproveRemaining =>
      _streakCalendarByGame[_gameId]?.autoApproveRemaining ?? 2;

  List<StreakDayItem> get last7Days =>
      _streakCalendarByGame[_gameId]?.last7Days ?? const [];

  /// Initialize provider with game ID, resolves player ID and loads daily overview
  Future<void> init({String gameId = 'zip'}) async {
    final cleanId = _normalizeGameId(gameId);
    _gameId = cleanId;
    notifyListeners();
    await _resolvePlayerIdentity();
    await Future.wait([
      loadTodayGame(),
      loadStreakCalendar(),
    ]);
  }

  /// Preload streak calendars for all active games in parallel to prevent UI lag & false states
  Future<void> preloadAllGamesStreak() async {
    await _resolvePlayerIdentity();
    final games = ['patch', 'sudoku', 'zip'];
    await Future.wait(
      games.map((g) async {
        try {
          final streak = await _apiClient.getStreakCalendar(
            gameId: g,
            playerId: _playerId,
          );
          _streakCalendarByGame[g] = streak;

          bool isTodayDone = false;
          for (final day in streak.last7Days) {
            if (day.isToday) {
              isTodayDone = day.completed;
              break;
            }
          }
          final today = DateTime.now().toIso8601String().substring(0, 10);
          final prefs = await SharedPreferences.getInstance();
          if (isTodayDone) {
            await prefs.setBool('puzzle_completed_${g}_$today', true);
          } else if (_lastSubmissionsByGame[g] == null) {
            await prefs.setBool('puzzle_completed_${g}_$today', false);
          }
        } catch (_) {}
      }),
    );
    notifyListeners();
  }

  Future<void> _resolvePlayerIdentity() async {
    try {
      final loggedInId = await getUserid();
      if (loggedInId != null && loggedInId.trim().isNotEmpty) {
        _playerId = loggedInId.trim();
      } else {
        final prefs = await SharedPreferences.getInstance();
        const guestKey = 'games_player_guest_id';
        var guestId = prefs.getString(guestKey);
        if (guestId == null || guestId.trim().isEmpty) {
          guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString(guestKey, guestId);
        }
        _playerId = guestId;
      }

      final prefs = await SharedPreferences.getInstance();
      final unifiedName = prefs.getString('game_profile_name') ??
          prefs.getString('userName') ??
          prefs.getString('zip_puzzle_v1_player_name') ??
          prefs.getString('patches_puzzle_v1_player_name') ??
          prefs.getString('sudoku_player_display_name');

      if (unifiedName != null &&
          unifiedName.trim().isNotEmpty &&
          unifiedName.trim().toLowerCase() != 'player' &&
          unifiedName.trim().toLowerCase() != 'you' &&
          !unifiedName.trim().toLowerCase().startsWith('guest')) {
        _displayName = unifiedName.trim();
      } else {
        _displayName = await _repository.getPlayerName();
        if (_displayName.isEmpty) {
          _displayName = 'You';
        }
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider._resolvePlayerIdentity error: $e');
      if (_playerId.isEmpty) {
        _playerId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      }
    }
  }

  /// Load today's single daily puzzle
  Future<void> loadTodayGame({String? date}) async {
    final targetGameId = _gameId;
    _isLoadingToday = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final puzzleData = await _apiClient.getTodayGame(targetGameId, date: date);
      _todayPuzzleByGame[targetGameId] = puzzleData;

      // Map API model to LevelDefinition for gameplay if game is zip
      if (targetGameId == 'zip') {
        try {
          final apiModel = puzzleData.toApiModel();
          _todayLevelDefinitionByGame[targetGameId] =
              ZipLevelDefinitionMapper.mapApiLevelToDefinition(apiModel);
        } catch (e) {
          debugPrint('ZipLevelDefinitionMapper mapping error: $e');
        }
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.loadTodayGame error: $e');
      _errorMessage = 'Failed to load today\'s puzzle: $e';
    } finally {
      _isLoadingToday = false;
      notifyListeners();
    }
  }

  /// Load 7-day streak calendar and recovery status
  Future<void> loadStreakCalendar() async {
    final targetGameId = _gameId;
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isLoadingStreak = true;
    notifyListeners();

    try {
      final streak = await _apiClient.getStreakCalendar(
        gameId: targetGameId,
        playerId: _playerId,
      );
      _streakCalendarByGame[targetGameId] = streak;

      bool isTodayDone = false;
      for (final day in streak.last7Days) {
        if (day.isToday) {
          isTodayDone = day.completed;
          break;
        }
      }
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final prefs = await SharedPreferences.getInstance();
      if (isTodayDone) {
        await prefs.setBool('puzzle_completed_${targetGameId}_$today', true);
      } else if (_lastSubmissionsByGame[targetGameId] == null) {
        await prefs.setBool('puzzle_completed_${targetGameId}_$today', false);
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.loadStreakCalendar error: $e');
    } finally {
      _isLoadingStreak = false;
      notifyListeners();
    }
  }

  /// Load today's daily speed leaderboard
  Future<void> loadTodayLeaderboard({int page = 1, int limit = 50}) async {
    final targetGameId = _gameId;
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isLoadingLeaderboard = true;
    notifyListeners();

    try {
      final lb = await _apiClient.getTodayLeaderboard(
        gameId: targetGameId,
        playerId: _playerId,
        page: page,
        limit: limit,
      );
      _dailyLeaderboardByGame[targetGameId] = lb;
    } catch (e) {
      debugPrint('DailyPuzzleProvider.loadTodayLeaderboard error: $e');
    } finally {
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  /// Submit today's puzzle completion to calculate rank and update streak
  Future<DailySubmissionResult?> submitDailyCompletion({
    required int durationMs,
    int score = 100,
    int? moves,
  }) async {
    final targetGameId = _gameId;
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _apiClient.submitTodayCompletion(
        gameId: targetGameId,
        playerId: _playerId,
        durationMs: durationMs,
        score: score,
        displayName: _displayName,
        moves: moves,
      );
      _lastSubmissionsByGame[targetGameId] = result;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('puzzle_completed_${targetGameId}_$today', true);

      // Refresh streak calendar and leaderboard in background
      loadStreakCalendar();
      loadTodayLeaderboard();

      return result;
    } catch (e) {
      debugPrint('DailyPuzzleProvider.submitDailyCompletion error: $e');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Save completed trace path for "View Game"
  Future<void> saveCompletedPath(List<GridPoint> path) async {
    final targetGameId = _gameId;
    _completedPathByGame[targetGameId] = List.unmodifiable(path);
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = todayPuzzle?.puzzleDate ?? '';
      if (date.isNotEmpty) {
        final encoded = jsonEncode(path.map((p) => {'row': p.row, 'col': p.col}).toList());
        await prefs.setString('daily_completed_path_${targetGameId}_$date', encoded);
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.saveCompletedPath error: $e');
    }
    notifyListeners();
  }

  /// Retrieve the user's completed trace path or fallback to solution path
  Future<List<GridPoint>> getCompletedPath() async {
    final targetGameId = _gameId;
    final cached = _completedPathByGame[targetGameId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = todayPuzzle?.puzzleDate ?? '';
      if (date.isNotEmpty) {
        final raw = prefs.getString('daily_completed_path_${targetGameId}_$date');
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as List;
          final list = decoded
              .whereType<Map>()
              .map((e) => GridPoint(
                    (e['row'] as num).toInt(),
                    (e['col'] as num).toInt(),
                  ))
              .toList();
          if (list.isNotEmpty) {
            _completedPathByGame[targetGameId] = list;
            return list;
          }
        }
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.getCompletedPath error: $e');
    }

    final levelDef = todayLevelDefinition;
    if (levelDef != null && levelDef.solutionPath.isNotEmpty) {
      return levelDef.solutionPath;
    }
    return const [];
  }

  /// Request streak recovery for 2+ missed days
  Future<StreakRecoveryResponse> requestStreakRecovery({String? reason}) async {
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isRequestingRecovery = true;
    notifyListeners();

    try {
      final response = await _apiClient.requestStreakRecovery(
        gameId: _gameId,
        playerId: _playerId,
        reason: reason ?? 'Recover missed days',
      );

      // Re-fetch streak calendar after recovery request
      await loadStreakCalendar();
      return response;
    } catch (e) {
      debugPrint('DailyPuzzleProvider.requestStreakRecovery error: $e');
      return StreakRecoveryResponse(
        success: false,
        status: 'ERROR',
        message: 'Network error: $e',
      );
    } finally {
      _isRequestingRecovery = false;
      notifyListeners();
    }
  }
}
