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

  DailyGameData? _todayPuzzle;
  LevelDefinition? _todayLevelDefinition;
  StreakCalendarResponse? _streakCalendar;
  DailyLeaderboardResponse? _dailyLeaderboard;
  DailySubmissionResult? _lastSubmissionResult;
  List<GridPoint>? _completedPath;

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

  String get gameId => _gameId;
  String get playerId => _playerId;
  String get displayName => _displayName;
  DailyGameData? get todayPuzzle => _todayPuzzle;
  LevelDefinition? get todayLevelDefinition => _todayLevelDefinition;
  StreakCalendarResponse? get streakCalendar => _streakCalendar;
  DailyLeaderboardResponse? get dailyLeaderboard => _dailyLeaderboard;
  DailySubmissionResult? get lastSubmissionResult => _lastSubmissionResult;
  List<GridPoint>? get completedPath => _completedPath;

  bool get isLoadingToday => _isLoadingToday;
  bool get isLoadingStreak => _isLoadingStreak;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isSubmitting => _isSubmitting;
  bool get isRequestingRecovery => _isRequestingRecovery;
  String? get errorMessage => _errorMessage;

  bool get isTodayCompleted {
    if (_lastSubmissionResult != null) return true;
    final calendar = _streakCalendar;
    if (calendar != null) {
      for (final day in calendar.last7Days) {
        if (day.isToday && day.completed) {
          return true;
        }
      }
    }
    return false;
  }

  int get currentStreak =>
      _lastSubmissionResult?.streak.currentStreak ??
      _streakCalendar?.currentStreak ??
      0;

  int get longestStreak =>
      _lastSubmissionResult?.streak.longestStreak ??
      _streakCalendar?.longestStreak ??
      0;

  bool get monthlyFreeReviveAvailable =>
      _streakCalendar?.monthlyFreeReviveAvailable ?? true;

  bool get canRequestRecovery =>
      _streakCalendar?.canRequestRecovery ?? false;

  int get gapDays => _streakCalendar?.gapDays ?? 0;

  int get autoApproveRemaining =>
      _streakCalendar?.autoApproveRemaining ?? 2;

  List<StreakDayItem> get last7Days =>
      _streakCalendar?.last7Days ?? const [];

  /// Initialize provider with game ID, resolves player ID and loads daily overview
  Future<void> init({String gameId = 'zip'}) async {
    _gameId = (gameId == 'zip_puzzle' || gameId.isEmpty) ? 'zip' : gameId;
    await _resolvePlayerIdentity();
    await Future.wait([
      loadTodayGame(),
      loadStreakCalendar(),
    ]);
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
    _isLoadingToday = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final puzzleData = await _apiClient.getTodayGame(_gameId, date: date);
      _todayPuzzle = puzzleData;

      // Map API model to LevelDefinition for gameplay if game is zip
      if (_gameId == 'zip' || _gameId == 'zip_puzzle') {
        try {
          final apiModel = puzzleData.toApiModel();
          _todayLevelDefinition =
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
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isLoadingStreak = true;
    notifyListeners();

    try {
      final streak = await _apiClient.getStreakCalendar(
        gameId: _gameId,
        playerId: _playerId,
      );
      _streakCalendar = streak;
      for (final day in streak.last7Days) {
        if (day.isToday && day.completed) {
          final today = DateTime.now().toIso8601String().substring(0, 10);
          SharedPreferences.getInstance().then((p) => p.setBool('puzzle_completed_${_gameId}_$today', true));
          break;
        }
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
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isLoadingLeaderboard = true;
    notifyListeners();

    try {
      final lb = await _apiClient.getTodayLeaderboard(
        gameId: _gameId,
        playerId: _playerId,
        page: page,
        limit: limit,
      );
      _dailyLeaderboard = lb;
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
    if (_playerId.isEmpty) {
      await _resolvePlayerIdentity();
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _apiClient.submitTodayCompletion(
        gameId: _gameId,
        playerId: _playerId,
        durationMs: durationMs,
        score: score,
        displayName: _displayName,
        moves: moves,
      );
      _lastSubmissionResult = result;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      SharedPreferences.getInstance().then((p) => p.setBool('puzzle_completed_${_gameId}_$today', true));

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
    _completedPath = List.unmodifiable(path);
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = _todayPuzzle?.puzzleDate ?? '';
      if (date.isNotEmpty) {
        final encoded = jsonEncode(path.map((p) => {'row': p.row, 'col': p.col}).toList());
        await prefs.setString('daily_completed_path_$date', encoded);
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.saveCompletedPath error: $e');
    }
    notifyListeners();
  }

  /// Retrieve the user's completed trace path or fallback to solution path
  Future<List<GridPoint>> getCompletedPath() async {
    if (_completedPath != null && _completedPath!.isNotEmpty) {
      return _completedPath!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = _todayPuzzle?.puzzleDate ?? '';
      if (date.isNotEmpty) {
        final raw = prefs.getString('daily_completed_path_$date');
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
            _completedPath = list;
            return list;
          }
        }
      }
    } catch (e) {
      debugPrint('DailyPuzzleProvider.getCompletedPath error: $e');
    }

    if (_todayLevelDefinition != null &&
        _todayLevelDefinition!.solutionPath.isNotEmpty) {
      return _todayLevelDefinition!.solutionPath;
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
