import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/sudoku_cell.dart';
import '../../data/models/sudoku_level_definition.dart';
import '../../data/repositories/sudoku_puzzle_repository.dart';

class SudokuGameProvider extends ChangeNotifier with WidgetsBindingObserver {
  final SudokuLevelDefinition level;
  final SudokuPuzzleRepository _repository;
  final VoidCallback? onLevelCompleted;

  late List<List<SudokuCell>> _grid;
  int? _selectedRow;
  int? _selectedCol;
  bool _isNoteMode = false;
  bool _isCompleted = false;

  final List<List<List<SudokuCell>>> _undoStack = [];

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiTimer;
  int _finalElapsedMs = 0;
  bool _isPaused = false;
  bool _hasStarted = false;
  bool _isDisposed = false;
  int _remainingHints = SudokuPuzzleRepository.maxDailyHints;

  SudokuGameProvider({
    required this.level,
    SudokuPuzzleRepository? repository,
    this.onLevelCompleted,
  }) : _repository = repository ?? SudokuPuzzleRepository() {
    WidgetsBinding.instance.addObserver(this);
    _initializeGrid();
    _loadDailyHints();
  }

  void _initializeGrid() {
    final s = level.size;
    _grid = List.generate(s, (r) {
      return List.generate(s, (c) {
        final val = level.initialGrid[r][c];
        return SudokuCell(
          row: r,
          col: c,
          value: val,
          isGiven: val != 0,
        );
      });
    });
  }

  Future<void> _loadDailyHints() async {
    final hints = await _repository.getRemainingHintsToday();
    if (!_isDisposed) {
      _remainingHints = hints;
      notifyListeners();
    }
  }

  List<List<SudokuCell>> get grid => _grid;
  int get size => level.size;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get isNoteMode => _isNoteMode;
  bool get isCompleted => _isCompleted;
  int get remainingHints => _remainingHints;
  bool get canUseHint => !_isCompleted && _remainingHints > 0;
  bool get hasStarted => _hasStarted;

  SudokuCell? get selectedCell {
    if (_selectedRow == null || _selectedCol == null) return null;
    return _grid[_selectedRow!][_selectedCol!];
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

  Map<int, int> get remainingCounts {
    final s = level.size;
    final counts = <int, int>{for (int i = 1; i <= s; i++) i: s};
    for (int r = 0; r < s; r++) {
      for (int c = 0; c < s; c++) {
        final val = _grid[r][c].value;
        if (val != 0 && counts.containsKey(val)) {
          counts[val] = (counts[val]! - 1).clamp(0, s);
        }
      }
    }
    return counts;
  }

  void selectCell(int r, int c) {
    if (_isCompleted) return;
    _startTimerIfNeeded();
    _selectedRow = r;
    _selectedCol = c;
    notifyListeners();
  }

  void toggleNoteMode() {
    _isNoteMode = !_isNoteMode;
    notifyListeners();
  }

  List<List<SudokuCell>> _cloneGrid() {
    final s = level.size;
    return List.generate(s, (r) {
      return List.generate(s, (c) => _grid[r][c]);
    });
  }

  void _pushUndo() {
    _undoStack.add(_cloneGrid());
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  bool get canUndo => _undoStack.isNotEmpty && !_isCompleted;

  void undo() {
    if (!canUndo) return;
    _grid = _undoStack.removeLast();
    _validateConflicts();
    notifyListeners();
  }

  void enterDigit(int digit) {
    if (_isCompleted || _selectedRow == null || _selectedCol == null) return;
    final r = _selectedRow!;
    final c = _selectedCol!;
    final currentCell = _grid[r][c];

    if (currentCell.isGiven) return;
    _startTimerIfNeeded();
    _pushUndo();

    if (_isNoteMode) {
      final newNotes = Set<int>.from(currentCell.notes);
      if (newNotes.contains(digit)) {
        newNotes.remove(digit);
      } else {
        newNotes.add(digit);
      }
      _grid[r][c] = currentCell.copyWith(notes: newNotes, value: 0);
    } else {
      final newValue = currentCell.value == digit ? 0 : digit;
      _grid[r][c] = currentCell.copyWith(value: newValue, notes: const {});

      if (newValue != 0) {
        // Auto-clear this note from peer cells in same row, column, and 3x3 box
        _clearPeerNote(r, c, newValue);
      }
    }

    _validateConflicts();
    _checkCompletion();
    notifyListeners();
  }

  void erase() {
    if (_isCompleted || _selectedRow == null || _selectedCol == null) return;
    final r = _selectedRow!;
    final c = _selectedCol!;
    final currentCell = _grid[r][c];

    if (currentCell.isGiven) return;
    if (currentCell.value == 0 && currentCell.notes.isEmpty) return;

    _pushUndo();
    _grid[r][c] = currentCell.copyWith(value: 0, notes: const {});
    _validateConflicts();
    notifyListeners();
  }

  void hint() {
    if (_isCompleted || _remainingHints <= 0) return;

    _startTimerIfNeeded();
    _pushUndo();

    // Prioritize selected cell if not given and empty or wrong
    int targetR = -1;
    int targetC = -1;

    if (_selectedRow != null && _selectedCol != null) {
      final sr = _selectedRow!;
      final sc = _selectedCol!;
      final cell = _grid[sr][sc];
      if (!cell.isGiven && cell.value != level.solutionGrid[sr][sc]) {
        targetR = sr;
        targetC = sc;
      }
    }

    // If no candidate yet, find the first empty or wrong cell
    if (targetR == -1) {
      final s = level.size;
      for (int r = 0; r < s; r++) {
        for (int c = 0; c < s; c++) {
          if (!_grid[r][c].isGiven &&
              _grid[r][c].value != level.solutionGrid[r][c]) {
            targetR = r;
            targetC = c;
            break;
          }
        }
        if (targetR != -1) break;
      }
    }

    if (targetR != -1) {
      _remainingHints =
          (_remainingHints - 1).clamp(0, SudokuPuzzleRepository.maxDailyHints);
      _repository.useHintToday();

      final correctVal = level.solutionGrid[targetR][targetC];
      _grid[targetR][targetC] = _grid[targetR][targetC].copyWith(
        value: correctVal,
        notes: const {},
      );
      _clearPeerNote(targetR, targetC, correctVal);
      _selectedRow = targetR;
      _selectedCol = targetC;

      _validateConflicts();
      _checkCompletion();
      notifyListeners();
    }
  }

  void reset() {
    _initializeGrid();
    _selectedRow = null;
    _selectedCol = null;
    _isNoteMode = false;
    _undoStack.clear();
    _stopwatch.reset();
    _stopwatch.stop();
    _uiTimer?.cancel();
    _hasStarted = false;
    _isPaused = false;
    _isCompleted = false;
    _finalElapsedMs = 0;
    notifyListeners();
  }

  void _clearPeerNote(int row, int col, int digit) {
    final s = level.size;
    // Row and column
    for (int i = 0; i < s; i++) {
      if (_grid[row][i].notes.contains(digit)) {
        final updated = Set<int>.from(_grid[row][i].notes)..remove(digit);
        _grid[row][i] = _grid[row][i].copyWith(notes: updated);
      }
      if (_grid[i][col].notes.contains(digit)) {
        final updated = Set<int>.from(_grid[i][col].notes)..remove(digit);
        _grid[i][col] = _grid[i][col].copyWith(notes: updated);
      }
    }
    // 2x3 box (2 rows x 3 columns)
    final br = (row ~/ 2) * 2;
    final bc = (col ~/ 3) * 3;
    for (int dr = 0; dr < 2; dr++) {
      for (int dc = 0; dc < 3; dc++) {
        final r = br + dr;
        final c = bc + dc;
        if (_grid[r][c].notes.contains(digit)) {
          final updated = Set<int>.from(_grid[r][c].notes)..remove(digit);
          _grid[r][c] = _grid[r][c].copyWith(notes: updated);
        }
      }
    }
  }

  void _validateConflicts() {
    final s = level.size;
    // Reset errors
    for (int r = 0; r < s; r++) {
      for (int c = 0; c < s; c++) {
        if (_grid[r][c].isError) {
          _grid[r][c] = _grid[r][c].copyWith(isError: false);
        }
      }
    }

    // Check rows
    for (int r = 0; r < s; r++) {
      final seen = <int, List<int>>{};
      for (int c = 0; c < s; c++) {
        final val = _grid[r][c].value;
        if (val != 0) {
          seen.putIfAbsent(val, () => []).add(c);
        }
      }
      for (final cols in seen.values) {
        if (cols.length > 1) {
          for (final c in cols) {
            _grid[r][c] = _grid[r][c].copyWith(isError: true);
          }
        }
      }
    }

    // Check cols
    for (int c = 0; c < s; c++) {
      final seen = <int, List<int>>{};
      for (int r = 0; r < s; r++) {
        final val = _grid[r][c].value;
        if (val != 0) {
          seen.putIfAbsent(val, () => []).add(r);
        }
      }
      for (final rows in seen.values) {
        if (rows.length > 1) {
          for (final r in rows) {
            _grid[r][c] = _grid[r][c].copyWith(isError: true);
          }
        }
      }
    }

    // Check 2x3 boxes
    for (int br = 0; br < s; br += 2) {
      for (int bc = 0; bc < s; bc += 3) {
        final seen = <int, List<List<int>>>{};
        for (int dr = 0; dr < 2; dr++) {
          for (int dc = 0; dc < 3; dc++) {
            final r = br + dr;
            final c = bc + dc;
            final val = _grid[r][c].value;
            if (val != 0) {
              seen.putIfAbsent(val, () => []).add([r, c]);
            }
          }
        }
        for (final cells in seen.values) {
          if (cells.length > 1) {
            for (final cell in cells) {
              _grid[cell[0]][cell[1]] =
                  _grid[cell[0]][cell[1]].copyWith(isError: true);
            }
          }
        }
      }
    }
  }

  void _checkCompletion() {
    // All cells must be non-zero and no cell can be in error
    final s = level.size;
    for (int r = 0; r < s; r++) {
      for (int c = 0; c < s; c++) {
        if (_grid[r][c].value == 0 || _grid[r][c].isError) {
          return;
        }
      }
    }

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
