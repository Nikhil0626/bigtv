import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/grid_point.dart';
import '../../data/models/level_definition.dart';
import '../../data/repositories/zip_puzzle_repository.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';

class ZipGameProvider extends ChangeNotifier with WidgetsBindingObserver {
  final LevelDefinition level;
  final ZipPuzzleRepository _repository;
  final VoidCallback? onLevelCompleted;

  final List<GridPoint> _currentPath = [];
  int _lastVisitedCheckpoint = 0;
  bool _isCompleted = false;
  String? _feedbackMessage;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiTimer;
  int _finalElapsedMs = 0;
  bool _isPaused = false;
  bool _hasStarted = false;
  int _remainingHints = ZipPuzzleRepository.maxDailyHints;
  bool _isDisposed = false;
  final bool isViewOnly;

  ZipGameProvider({
    required this.level,
    ZipPuzzleRepository? repository,
    this.onLevelCompleted,
    this.isViewOnly = false,
    List<GridPoint>? initialPath,
    int? initialElapsedMs,
  }) : _repository = repository ?? ZipPuzzleRepository() {
    WidgetsBinding.instance.addObserver(this);
    if (isViewOnly && initialPath != null && initialPath.isNotEmpty) {
      _currentPath.addAll(initialPath);
      _isCompleted = true;
      _hasStarted = true;
      _finalElapsedMs = initialElapsedMs ?? 0;
      _lastVisitedCheckpoint = level.checkpoints.length;
      _isOrderCorrect = true;
    } else {
      _loadDailyHints();
    }
  }

  Future<void> _loadDailyHints() async {
    final hints = await _repository.getRemainingHintsToday();
    if (!_isDisposed) {
      _remainingHints = hints;
      notifyListeners();
    }
  }

  int _colorOffset = 0;

  ZipColorTheme get activeColorTheme =>
      LevelDefinition.palette[(level.levelNumber - 1 + _colorOffset) % LevelDefinition.palette.length];

  Color get pathColor => activeColorTheme.pathColor;
  Color get cellTintColor => activeColorTheme.cellTintColor;

  int get remainingHints => _remainingHints;
  bool get canUseHint => !_isCompleted && _remainingHints > 0;

  List<GridPoint> get currentPath => List.unmodifiable(_currentPath);
  int get lastVisitedCheckpoint => _lastVisitedCheckpoint;
  int get nextExpectedCheckpoint => _lastVisitedCheckpoint + 1;
  bool get isCompleted => _isCompleted;
  String? get feedbackMessage => _feedbackMessage;
  bool get hasStarted => _hasStarted;
  int get requiredCells => level.totalRequiredCells;
  int get filledCells => _currentPath.length;

  int get elapsedMilliseconds {
    if (_isCompleted) return _finalElapsedMs;
    return _stopwatch.elapsedMilliseconds;
  }

  String get formattedTime {
    final ms = elapsedMilliseconds;
    final totalSeconds = (ms / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final hours = minutes ~/ 60;
    if (hours > 0) {
      final remMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      resumeTimer();
    }
  }

  void _startTimerIfNeeded() {
    if (!_hasStarted) {
      _hasStarted = true;
      _stopwatch.start();
      _uiTimer?.cancel();
      _uiTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!_isCompleted && !_isPaused) {
          notifyListeners();
        }
      });
    }
  }

  void pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _isPaused = true;
      AnalyticsService.instance.track(AnalyticsEventName.gamePause, properties: {
        'game_id': 'zip_puzzle',
        'round_id': level.levelNumber.toString(),
      });
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (_isPaused && !_isCompleted && _hasStarted) {
      _stopwatch.start();
      _isPaused = false;
      AnalyticsService.instance.track(AnalyticsEventName.gameResume, properties: {
        'game_id': 'zip_puzzle',
        'round_id': level.levelNumber.toString(),
      });
      notifyListeners();
    }
  }

  bool _isOrderCorrect = true;
  bool get isCheckpointOrderCorrect => _isOrderCorrect;

  List<int> get visitedCheckpointNumbers {
    final list = <int>[];
    for (final pt in _currentPath) {
      final cp = level.getCheckpointNumber(pt);
      if (cp != null) {
        list.add(cp);
      }
    }
    return list;
  }

  void _updateOrderAndFeedback() {
    final visited = visitedCheckpointNumbers;
    bool orderOk = true;
    for (int i = 0; i < visited.length; i++) {
      if (visited[i] != i + 1) {
        orderOk = false;
        break;
      }
    }

    _isOrderCorrect = orderOk;

    if (!orderOk) {
      _feedbackMessage = 'Order of numbers is incorrect';
    } else {
      _feedbackMessage = null;
    }

    if (visited.isNotEmpty) {
      _lastVisitedCheckpoint = visited.last;
    } else {
      _lastVisitedCheckpoint = 0;
    }
  }

  void startPath(GridPoint point) {
    if (_isCompleted) return;

    final cpNumber = level.getCheckpointNumber(point);
    if (cpNumber != 1) {
      _feedbackMessage = 'Start tracing from point 1';
      notifyListeners();
      return;
    }

    _startTimerIfNeeded();
    _currentPath.clear();
    _currentPath.add(point);
    _lastVisitedCheckpoint = 1;
    _isOrderCorrect = true;
    _feedbackMessage = null;
    notifyListeners();
  }

  void moveTo(GridPoint point) {
    if (_isCompleted) return;

    if (_currentPath.isEmpty) {
      startPath(point);
      return;
    }

    final currentHead = _currentPath.last;

    // Same cell, do nothing
    if (currentHead == point) return;

    // Backtrack detection: if the user moves to the previous cell
    if (_currentPath.length >= 2 &&
        _currentPath[_currentPath.length - 2] == point) {
      _currentPath.removeLast();
      _updateOrderAndFeedback();
      _checkCompletion();
      notifyListeners();
      return;
    }

    // Must be orthogonally adjacent to current head
    if (!currentHead.isAdjacent(point)) {
      return;
    }

    // Cannot cross wall barriers
    if (level.hasWall(currentHead, point)) {
      _feedbackMessage = 'Blocked by wall';
      notifyListeners();
      return;
    }

    // Check if cell is already in path (cannot intersect)
    if (_currentPath.contains(point)) {
      _feedbackMessage = 'Cannot cross your own path';
      notifyListeners();
      return;
    }

    // Allow user to move into any cell starting from 1
    _currentPath.add(point);
    _updateOrderAndFeedback();
    _checkCompletion();
    notifyListeners();
  }

  Future<void>? _completionFuture;
  Future<void>? get completionFuture => _completionFuture;

  void _checkCompletion() {
    if (_isCompleted) return;

    if (_isOrderCorrect &&
        visitedCheckpointNumbers.length == level.checkpointCount &&
        _currentPath.length == level.totalRequiredCells) {
      _isCompleted = true;
      _stopwatch.stop();
      _uiTimer?.cancel();
      _finalElapsedMs = _stopwatch.elapsedMilliseconds;

      _completionFuture = _repository
          .saveLevelCompletion(
        level: level.levelNumber,
        elapsedMs: _finalElapsedMs,
      )
          .then((_) {
        onLevelCompleted?.call();
      });
    }
  }

  void undo() {
    if (_isCompleted || _currentPath.isEmpty) return;

    _currentPath.removeLast();
    _updateOrderAndFeedback();
    _checkCompletion();
    notifyListeners();
  }

  void hint() {
    if (_isCompleted) return;
    if (_remainingHints <= 0) {
      _feedbackMessage = 'Daily hint limit reached (3/3)';
      notifyListeners();
      return;
    }

    _remainingHints =
        (_remainingHints - 1).clamp(0, ZipPuzzleRepository.maxDailyHints);
    _repository.useHintToday();

    _startTimerIfNeeded();

    final solution = level.solutionPath;
    if (solution.isEmpty) return;

    // Check how many steps match the verified solution from the beginning
    int matchCount = 0;
    while (matchCount < _currentPath.length &&
        matchCount < solution.length &&
        _currentPath[matchCount] == solution[matchCount]) {
      matchCount++;
    }

    String? hintMsg;
    // If player made wrong moves that diverge from the solution, roll back to last correct step
    if (matchCount < _currentPath.length) {
      _currentPath.removeRange(matchCount, _currentPath.length);
      hintMsg = 'Rolled back to last correct step';
    }

    // Advance by adding the next correct step from the verified solution
    if (_currentPath.length < solution.length) {
      final nextPt = solution[_currentPath.length];
      _currentPath.add(nextPt);
      hintMsg = 'Hint: advanced next correct step';
    }

    _updateOrderAndFeedback();
    if (_isOrderCorrect && hintMsg != null) {
      _feedbackMessage = hintMsg;
    }

    _checkCompletion();
    notifyListeners();
  }

  void reset() {
    _colorOffset++;
    _stopwatch.reset();
    _stopwatch.stop();
    _uiTimer?.cancel();
    _hasStarted = false;
    _isPaused = false;
    _isCompleted = false;
    _currentPath.clear();
    _lastVisitedCheckpoint = 0;
    _isOrderCorrect = true;
    _feedbackMessage = null;
    _finalElapsedMs = 0;
    notifyListeners();
  }

  void clearFeedback() {
    if (_feedbackMessage != null) {
      _feedbackMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _uiTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
