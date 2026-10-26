import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import '../../data/models/drawn_patch.dart';
import '../../data/models/patch_clue.dart';
import '../../data/models/patches_level_definition.dart';
import '../../data/repositories/patches_puzzle_repository.dart';

class PatchesGameProvider extends ChangeNotifier with WidgetsBindingObserver {
  final PatchesLevelDefinition level;
  final PatchesPuzzleRepository _repository;
  final VoidCallback? onLevelCompleted;

  final List<DrawnPatch> _placedPatches = [];
  GridPoint? _dragStart;
  GridPoint? _dragCurrent;
  bool _isCompleted = false;
  String? _feedbackMessage;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiTimer;
  int _finalElapsedMs = 0;
  bool _isPaused = false;
  bool _hasStarted = false;
  bool _isDisposed = false;
  int _remainingHints = PatchesPuzzleRepository.maxDailyHints;

  PatchesGameProvider({
    required this.level,
    PatchesPuzzleRepository? repository,
    this.onLevelCompleted,
  }) : _repository = repository ?? PatchesPuzzleRepository() {
    WidgetsBinding.instance.addObserver(this);
    _loadDailyHints();
  }

  Future<void> _loadDailyHints() async {
    final hints = await _repository.getRemainingHintsToday();
    if (!_isDisposed) {
      _remainingHints = hints;
      notifyListeners();
    }
  }

  List<DrawnPatch> get placedPatches => List.unmodifiable(_placedPatches);
  GridPoint? get dragStart => _dragStart;
  GridPoint? get dragCurrent => _dragCurrent;
  bool get isCompleted => _isCompleted;
  String? get feedbackMessage => _feedbackMessage;
  bool get hasStarted => _hasStarted;
  int get remainingHints => _remainingHints;
  bool get canUseHint => !_isCompleted && _remainingHints > 0;
  int get totalCells => level.totalCells;

  int get coveredCellsCount {
    final Set<GridPoint> covered = {};
    for (final patch in _placedPatches) {
      covered.addAll(patch.cells);
    }
    return covered.length;
  }

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
      return '$hours:${remMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isPreviewValid {
    if (_dragStart == null || _dragCurrent == null) return false;
    final p1 = _dragStart!;
    final p2 = _dragCurrent!;
    final r1 = p1.row < p2.row ? p1.row : p2.row;
    final r2 = p1.row > p2.row ? p1.row : p2.row;
    final c1 = p1.col < p2.col ? p1.col : p2.col;
    final c2 = p1.col > p2.col ? p1.col : p2.col;

    final cluesInside = <PatchClue>[];
    for (final clue in level.clues) {
      if (clue.point.row >= r1 &&
          clue.point.row <= r2 &&
          clue.point.col >= c1 &&
          clue.point.col <= c2) {
        cluesInside.add(clue);
      }
    }

    if (cluesInside.length != 1) return false;
    final clue = cluesInside.first;
    final w = (c2 - c1) + 1;
    final h = (r2 - r1) + 1;
    final area = w * h;

    if (clue.targetArea != null && area != clue.targetArea) return false;
    if (!clue.shapeType.matches(w, h)) return false;

    return true;
  }

  DrawnPatch? get previewPatch {
    if (_dragStart == null || _dragCurrent == null) return null;
    final p1 = _dragStart!;
    final p2 = _dragCurrent!;
    final r1 = p1.row < p2.row ? p1.row : p2.row;
    final r2 = p1.row > p2.row ? p1.row : p2.row;
    final c1 = p1.col < p2.col ? p1.col : p2.col;
    final c2 = p1.col > p2.col ? p1.col : p2.col;

    // Find clue inside candidate
    PatchClue? foundClue;
    int clueCount = 0;
    for (final clue in level.clues) {
      if (clue.point.row >= r1 &&
          clue.point.row <= r2 &&
          clue.point.col >= c1 &&
          clue.point.col <= c2) {
        foundClue = clue;
        clueCount++;
      }
    }

    final isValid = isPreviewValid;
    Color previewColor = const Color(0xFF9CA3AF);
    Color tintColor = const Color(0xFFF3F4F6);

    if (foundClue != null && clueCount == 1) {
      if (isValid) {
        previewColor = foundClue.color;
        tintColor = foundClue.tintColor;
      } else {
        // While dragging before completing valid shape, keep neutral guide
        previewColor = const Color(0xFF9CA3AF);
        tintColor = const Color(0xFFF3F4F6);
      }
    } else if (clueCount > 1) {
      previewColor = const Color(0xFFEF4444);
      tintColor = const Color(0xFFFEE2E2);
    }

    return DrawnPatch(
      clueId: 'preview',
      minRow: r1,
      maxRow: r2,
      minCol: c1,
      maxCol: c2,
      color: previewColor,
      tintColor: tintColor,
    );
  }

  DrawnPatch? patchAt(GridPoint pt) {
    for (final patch in _placedPatches) {
      if (patch.contains(pt)) return patch;
    }
    return null;
  }

  void startDrag(GridPoint pt) {
    if (_isCompleted) return;
    _startTimerIfNeeded();
    _dragStart = pt;
    _dragCurrent = pt;
    _feedbackMessage = null;
    notifyListeners();
  }

  void updateDrag(GridPoint pt) {
    if (_isCompleted || _dragStart == null) return;
    if (_dragCurrent != pt) {
      _dragCurrent = pt;
      notifyListeners();
    }
  }

  void endDrag() {
    if (_isCompleted || _dragStart == null || _dragCurrent == null) {
      _dragStart = null;
      _dragCurrent = null;
      notifyListeners();
      return;
    }

    final p1 = _dragStart!;
    final p2 = _dragCurrent!;
    final isTap = (p1 == p2);

    _dragStart = null;
    _dragCurrent = null;

    // Tap to remove existing patch (LinkedIn feature)
    if (isTap) {
      final existing = patchAt(p1);
      if (existing != null) {
        _placedPatches.remove(existing);
        _feedbackMessage = null;
        notifyListeners();
        return;
      }
    }

    final r1 = p1.row < p2.row ? p1.row : p2.row;
    final r2 = p1.row > p2.row ? p1.row : p2.row;
    final c1 = p1.col < p2.col ? p1.col : p2.col;
    final c2 = p1.col > p2.col ? p1.col : p2.col;

    final w = (c2 - c1) + 1;
    final h = (r2 - r1) + 1;
    final area = w * h;

    // 1. Find which clues are inside this candidate patch
    final cluesInside = <PatchClue>[];
    for (final clue in level.clues) {
      if (clue.point.row >= r1 &&
          clue.point.row <= r2 &&
          clue.point.col >= c1 &&
          clue.point.col <= c2) {
        cluesInside.add(clue);
      }
    }

    if (cluesInside.isEmpty) {
      _feedbackMessage = 'Each patch must contain 1 clue';
      notifyListeners();
      return;
    }

    if (cluesInside.length > 1) {
      _feedbackMessage = 'Patches cannot contain multiple clues';
      notifyListeners();
      return;
    }

    final clue = cluesInside.first;

    // 2. Validate area if clue has a specific number
    if (clue.targetArea != null && area != clue.targetArea) {
      _feedbackMessage = 'Area must be ${clue.targetArea} (drew $area)';
      notifyListeners();
      return;
    }

    // 3. Validate shape constraint
    if (!clue.shapeType.matches(w, h)) {
      _feedbackMessage = 'Shape must be a ${clue.shapeType.displayName}';
      notifyListeners();
      return;
    }

    // 4. Overlap resolution
    final newPatch = DrawnPatch(
      clueId: clue.id,
      minRow: r1,
      maxRow: r2,
      minCol: c1,
      maxCol: c2,
      color: clue.color,
      tintColor: clue.tintColor,
    );

    // Remove any previous patch for this same clue OR overlapping patches
    _placedPatches
        .removeWhere((p) => p.clueId == clue.id || p.overlaps(newPatch));
    _placedPatches.add(newPatch);

    _feedbackMessage = null;
    _checkCompletion();
    notifyListeners();
  }

  void removePatchAt(GridPoint pt) {
    if (_isCompleted) return;
    final existing = patchAt(pt);
    if (existing != null) {
      _placedPatches.remove(existing);
      _feedbackMessage = null;
      notifyListeners();
    }
  }

  void undo() {
    if (_isCompleted || _placedPatches.isEmpty) return;
    _placedPatches.removeLast();
    _feedbackMessage = null;
    notifyListeners();
  }

  void reset() {
    _placedPatches.clear();
    _dragStart = null;
    _dragCurrent = null;
    _stopwatch.reset();
    _stopwatch.stop();
    _uiTimer?.cancel();
    _hasStarted = false;
    _isPaused = false;
    _isCompleted = false;
    _feedbackMessage = null;
    _finalElapsedMs = 0;
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
        (_remainingHints - 1).clamp(0, PatchesPuzzleRepository.maxDailyHints);
    _repository.useHintToday();

    _startTimerIfNeeded();

    // Find the first solution patch not yet correctly placed
    DrawnPatch? nextTargetPatch;
    for (final sol in level.solutionPatches) {
      final placed = _placedPatches.any((p) => p == sol);
      if (!placed) {
        nextTargetPatch = sol;
        break;
      }
    }

    if (nextTargetPatch != null) {
      // Remove any conflicting overlapping placed patch
      _placedPatches.removeWhere((p) =>
          p.clueId == nextTargetPatch!.clueId || p.overlaps(nextTargetPatch));
      _placedPatches.add(nextTargetPatch);
      _feedbackMessage = null;
      _checkCompletion();
      notifyListeners();
    }
  }

  void _checkCompletion() {
    if (_placedPatches.length != level.clues.length) return;

    // Check full grid coverage
    final Set<GridPoint> covered = {};
    for (final patch in _placedPatches) {
      covered.addAll(patch.cells);
    }

    if (covered.length == level.totalCells) {
      _isCompleted = true;
      _stopwatch.stop();
      _uiTimer?.cancel();
      _finalElapsedMs = _stopwatch.elapsedMilliseconds;
      _repository.saveLevelCompletion(
        level: level.levelNumber,
        elapsedMs: _finalElapsedMs,
      );
      onLevelCompleted?.call();
      notifyListeners();
    }
  }

  void _startTimerIfNeeded() {
    if (!_hasStarted) {
      _hasStarted = true;
      _stopwatch.start();
      _uiTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (!_isPaused && !_isCompleted) {
          notifyListeners();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_hasStarted && !_isCompleted) {
        _stopwatch.stop();
        _isPaused = true;
        notifyListeners();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_hasStarted && !_isCompleted && _isPaused) {
        _stopwatch.start();
        _isPaused = false;
        notifyListeners();
      }
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
