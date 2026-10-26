import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/sudoku_model.dart';
import '../../../../services/puzzle_api_service.dart';
import '../../../../services/game_share_helper.dart';
import '../../../../core/widgets/game_watermark_widget.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';

class SudokuCellValidation {
  final bool isWrong;
  final String? message;
  final Set<Point<int>> conflictingCells;

  const SudokuCellValidation({
    required this.isWrong,
    this.message,
    this.conflictingCells = const {},
  });

  static const empty = SudokuCellValidation(
    isWrong: false,
    message: null,
    conflictingCells: {},
  );
}

class SudokuGameScreen extends StatefulWidget {
  final String playerId;
  final bool isViewOnly;
  final List<List<int>>? completedGrid;

  const SudokuGameScreen({
    super.key,
    required this.playerId,
    this.isViewOnly = false,
    this.completedGrid,
  });

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  SudokuLevel? _level;
  late List<List<int>> _userGrid;
  int? _selectedRow;
  int? _selectedCol;
  bool _isLoading = true;
  bool _isCompleted = false;
  String? _errorMessage;
  Set<Point<int>> _conflictingCells = const {};
  int? _cachedRank;
  int? _cachedStreak;
  int? _cachedDurationMs;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDailySudoku();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_isCompleted && !widget.isViewOnly) {
      AnalyticsService.instance.track(AnalyticsEventName.gameIncomplete, properties: {
        'game_id': 'sudoku',
        'round_id': _level?.levelId ?? 'daily',
        'reason': 'user_exit',
      });
    }
    AnalyticsService.instance.track(AnalyticsEventName.gameExit, properties: {
      'game_id': 'sudoku',
      'round_id': _level?.levelId ?? 'daily',
    });
    super.dispose();
  }

  Future<void> _loadDailySudoku() async {
    try {
      final data = await PuzzleApiService.getTodayGame(
        gameSlug: 'sudoku',
        playerId: widget.playerId,
      );
      final level = SudokuLevel.fromJson(data);
      if (!mounted) return;

      setState(() {
        _level = level;
        if (widget.isViewOnly && widget.completedGrid != null) {
          _userGrid = widget.completedGrid!.map((row) => List<int>.from(row)).toList();
          _isCompleted = true;
        } else if (widget.isViewOnly) {
          _userGrid = level.solution.map((row) => List<int>.from(row)).toList();
          _isCompleted = true;
        } else {
          // Deep copy initialGrid to userGrid
          _userGrid = level.initialGrid.map((row) => List<int>.from(row)).toList();
        }
        _isLoading = false;
      });

      if (!widget.isViewOnly) {
        AnalyticsService.instance.track(AnalyticsEventName.gameStart, properties: {
          'game_id': 'sudoku',
          'round_id': level.levelId,
        });
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Sudoku: $e')),
        );
      }
    }
  }

  bool _isCellWrong(int r, int c) {
    if (_level == null) return false;
    final level = _level!;
    if (level.initialGrid[r][c] != 0) return false;
    final val = _userGrid[r][c];
    if (val == 0) return false;

    // 1. Solution mismatch check
    if (val != level.solution[r][c]) return true;

    // 2. Row conflict check
    for (int col = 0; col < level.columns; col++) {
      if (col != c && _userGrid[r][col] == val) return true;
    }

    // 3. Column conflict check
    for (int row = 0; row < level.rows; row++) {
      if (row != r && _userGrid[row][c] == val) return true;
    }

    // 4. Box conflict check
    final boxStartR = (r ~/ level.boxRows) * level.boxRows;
    final boxStartC = (c ~/ level.boxCols) * level.boxCols;
    for (int br = boxStartR; br < boxStartR + level.boxRows; br++) {
      for (int bc = boxStartC; bc < boxStartC + level.boxCols; bc++) {
        if ((br != r || bc != c) && _userGrid[br][bc] == val) return true;
      }
    }

    return false;
  }

  SudokuCellValidation _validateCell(int r, int c) {
    if (_level == null) return SudokuCellValidation.empty;
    final level = _level!;

    if (level.initialGrid[r][c] != 0) {
      return SudokuCellValidation.empty;
    }

    final val = _userGrid[r][c];
    if (val == 0) {
      return SudokuCellValidation.empty;
    }

    final conflicts = <Point<int>>{};
    bool hasRowConflict = false;
    bool hasColConflict = false;
    bool hasBoxConflict = false;

    // 1. Check Row Rule (Sudoku rule: each number only once per row)
    for (int col = 0; col < level.columns; col++) {
      if (col != c && _userGrid[r][col] == val) {
        hasRowConflict = true;
        conflicts.add(Point(r, col));
      }
    }

    // 2. Check Column Rule (Sudoku rule: each number only once per column)
    for (int row = 0; row < level.rows; row++) {
      if (row != r && _userGrid[row][c] == val) {
        hasColConflict = true;
        conflicts.add(Point(row, c));
      }
    }

    // 3. Check Box/Subgrid Rule (Sudoku rule: each number only once per block)
    final boxStartR = (r ~/ level.boxRows) * level.boxRows;
    final boxStartC = (c ~/ level.boxCols) * level.boxCols;
    for (int br = boxStartR; br < boxStartR + level.boxRows; br++) {
      for (int bc = boxStartC; bc < boxStartC + level.boxCols; bc++) {
        if ((br != r || bc != c) && _userGrid[br][bc] == val) {
          hasBoxConflict = true;
          conflicts.add(Point(br, bc));
        }
      }
    }

    if (hasRowConflict || hasColConflict || hasBoxConflict) {
      final list = <String>[];
      if (hasRowConflict) list.add('row ${r + 1}');
      if (hasColConflict) list.add('column ${c + 1}');
      if (hasBoxConflict) list.add('${level.boxRows}x${level.boxCols} block');

      return SudokuCellValidation(
        isWrong: true,
        message: 'Sudoku Rule Violation: Number $val is repeated in ${list.join(" & ")}',
        conflictingCells: conflicts,
      );
    }

    // 4. Check Solution Correctness
    if (val != level.solution[r][c]) {
      return SudokuCellValidation(
        isWrong: true,
        message: 'Incorrect placement: Number $val does not fit in this cell',
        conflictingCells: conflicts,
      );
    }

    return SudokuCellValidation.empty;
  }

  int get _totalErrorsCount {
    if (_level == null) return 0;
    int count = 0;
    for (int r = 0; r < _level!.rows; r++) {
      for (int c = 0; c < _level!.columns; c++) {
        if (_isCellWrong(r, c)) count++;
      }
    }
    return count;
  }

  void _onCellTapped(int row, int col) {
    if (widget.isViewOnly || _isCompleted) return;
    if (_level == null) return;

    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      final valResult = _validateCell(row, col);
      _errorMessage = valResult.message;
      _conflictingCells = valResult.conflictingCells;
    });
  }

  void _onNumberPressed(int number) {
    if (widget.isViewOnly || _isCompleted) return;
    if (_selectedRow == null || _selectedCol == null || _level == null) return;
    final r = _selectedRow!;
    final c = _selectedCol!;

    // Cannot overwrite initial clue
    if (_level!.initialGrid[r][c] != 0) return;

    setState(() {
      _userGrid[r][c] = number;
      final valResult = _validateCell(r, c);
      _errorMessage = valResult.message;
      _conflictingCells = valResult.conflictingCells;
    });

    _checkCompletion();
  }

  void _onErasePressed() {
    if (widget.isViewOnly || _isCompleted) return;
    if (_selectedRow == null || _selectedCol == null || _level == null) return;
    final r = _selectedRow!;
    final c = _selectedCol!;
    if (_level!.initialGrid[r][c] == 0) {
      setState(() {
        _userGrid[r][c] = 0;
        _errorMessage = null;
        _conflictingCells = const {};
      });
    }
  }

  void _checkCompletion() {
    if (_level == null) return;
    for (int r = 0; r < _level!.rows; r++) {
      for (int c = 0; c < _level!.columns; c++) {
        if (_userGrid[r][c] == 0 || _userGrid[r][c] != _level!.solution[r][c]) {
          return; // Still empty or incorrect cell
        }
      }
    }

    // Success!
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
      _errorMessage = null;
      _conflictingCells = const {};
    });
    _submitScore();
  }

  Future<void> _submitScore() async {
    final duration = _stopwatch.elapsedMilliseconds;
    AnalyticsService.instance.track(AnalyticsEventName.gameComplete, properties: {
      'game_id': 'sudoku',
      'round_id': _level?.levelId ?? 'daily',
      'score': 100,
      'duration_ms': duration,
    });
    final res = await PuzzleApiService.submitGame(
      gameSlug: 'sudoku',
      playerId: widget.playerId,
      durationMs: duration,
      score: 100,
    );

    if (!mounted) return;

    final rank = res['rank'] ?? 1;
    final streak = res['streak'] != null ? res['streak']['currentStreak'] ?? 1 : 1;
    AnalyticsService.instance.track(AnalyticsEventName.gameScoreRecorded, properties: {
      'game_id': 'sudoku',
      'score': 100,
      'rank': rank,
    });

    setState(() {
      _cachedDurationMs = duration;
      _cachedRank = rank;
      _cachedStreak = streak;
    });
  }

  void _showResultDialog() {
    final duration = _cachedDurationMs ?? _stopwatch.elapsedMilliseconds;
    final rank = _cachedRank ?? 1;
    final streak = _cachedStreak ?? 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🎉 Sudoku Solved!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${(duration / 1000).toStringAsFixed(1)}s', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Rank: #$rank', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 6),
            Text('Streak: $streak days!', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share Game', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              GameShareHelper.shareGame(
                context: context,
                gameSlug: 'sudoku',
                gameTitle: 'Sudoku',
                formattedTime: '${(duration / 1000).toStringAsFixed(1)}s',
                rank: rank,
                streak: streak,
              );
            },
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('View Game'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to dashboard / sheet
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _shareCurrentGame() {
    final elapsedSec = _stopwatch.elapsed.inSeconds;
    final formattedTime = '${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}';
    GameShareHelper.shareGame(
      context: context,
      gameSlug: 'sudoku',
      gameTitle: 'Sudoku',
      formattedTime: widget.isViewOnly ? null : formattedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final level = _level!;
    final palette = level.palette;
    final elapsedSec = _stopwatch.elapsed.inSeconds;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedValue = (_selectedRow != null && _selectedCol != null)
        ? _userGrid[_selectedRow!][_selectedCol!]
        : null;

    final totalErrors = _totalErrorsCount;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.isViewOnly
                ? 'Sudoku (${level.rows}x${level.columns}) - Solved'
                : 'Sudoku (${level.rows}x${level.columns})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!widget.isViewOnly)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _shareCurrentGame,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.share_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (totalErrors > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cancel_outlined, size: 13, color: Colors.red),
                          const SizedBox(width: 3),
                          Text(
                            'Errors: $totalErrors',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2024) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 3),
                        Text(
                          '${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.green, size: 20),
                tooltip: 'Share Game',
                onPressed: () {
                  GameShareHelper.shareGame(
                    context: context,
                    gameSlug: 'sudoku',
                    gameTitle: 'Sudoku',
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- LIVE ERROR BANNER / RULES GUIDE ---
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF991B1B) : const Color(0xFFF87171),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (!widget.isViewOnly && !_isCompleted)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 15,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Each row, column & ${level.boxRows}x${level.boxCols} block must contain 1-${level.rows}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 4),

            // --- SUDOKU GRID ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = min(constraints.maxWidth, constraints.maxHeight);
                    if (size <= 0) return const SizedBox.shrink();
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: palette.blockBorder, width: 2.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: List.generate(level.rows, (r) {
                          return Expanded(
                            child: Row(
                              children: List.generate(level.columns, (c) {
                                final isClue = level.initialGrid[r][c] != 0;
                                final value = _userGrid[r][c];
                                final isSelected = _selectedRow == r && _selectedCol == c;
                                final isHighlighted = selectedValue != null &&
                                    selectedValue != 0 &&
                                    value == selectedValue;

                                final isWrong = !isClue && value != 0 && _isCellWrong(r, c);
                                final isConflicting = _conflictingCells.contains(Point(r, c));

                                // Dynamic block border detection
                                final isBottomBlockBorder =
                                    (r + 1) % level.boxRows == 0 && r != level.rows - 1;
                                final isRightBlockBorder =
                                    (c + 1) % level.boxCols == 0 && c != level.columns - 1;

                                Color cellBg = isDark ? const Color(0xFF1E2024) : palette.cellBackground;
                                if (isSelected) {
                                  if (isWrong) {
                                    cellBg = isDark ? const Color(0xFF4C1D1D) : const Color(0xFFFEE2E2);
                                  } else {
                                    cellBg = palette.selectedCell;
                                  }
                                } else if (isWrong) {
                                  cellBg = isDark ? const Color(0xFF381414) : const Color(0xFFFEF2F2);
                                } else if (isConflicting) {
                                  cellBg = isDark ? const Color(0xFF382314) : const Color(0xFFFEF3C7);
                                } else if (isHighlighted) {
                                  cellBg = palette.highlightNumber;
                                }

                                Color textColor;
                                if (isClue) {
                                  textColor = isDark ? Colors.white : palette.clueText;
                                } else if (isWrong) {
                                  textColor = const Color(0xFFDC2626); // VIBRANT ERROR RED
                                } else {
                                  textColor = palette.userText;
                                }

                                final fontWeight = isClue
                                    ? FontWeight.w900
                                    : (isWrong ? FontWeight.w800 : FontWeight.w600);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onCellTapped(r, c),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cellBg,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: isBottomBlockBorder
                                                ? palette.blockBorder
                                                : (isWrong
                                                    ? const Color(0xFFF87171)
                                                    : palette.gridBorder),
                                            width: isBottomBlockBorder ? 2.0 : (isWrong ? 1.0 : 0.8),
                                          ),
                                          right: BorderSide(
                                            color: isRightBlockBorder
                                                ? palette.blockBorder
                                                : (isWrong
                                                    ? const Color(0xFFF87171)
                                                    : palette.gridBorder),
                                            width: isRightBlockBorder ? 2.0 : (isWrong ? 1.0 : 0.8),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          value == 0 ? '' : '$value',
                                          style: TextStyle(
                                            fontSize: level.rows == 6 ? 26 : 20,
                                            fontWeight: fontWeight,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (_isCompleted || widget.isViewOnly)
                      Positioned.fill(
                        child: GameWatermarkWidget(
                          logoUrl: level.logoUrl,
                          size: size * 0.55,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),

            if (_isCompleted && !widget.isViewOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 22),
                        label: const Text(
                          'Done',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _showResultDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _shareCurrentGame,
                    ),
                  ],
                ),
              )
            else if (widget.isViewOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You have completed today\'s Sudoku puzzle!',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: _showResultDialog,
                        child: const Text('Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: _shareCurrentGame,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share_rounded, size: 14),
                            SizedBox(width: 4),
                            Text('Share', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              )
            else
              // --- NUMBER KEYPAD ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: Row(
                  children: [
                    ...List.generate(level.rows, (index) {
                      final num = index + 1;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: isDark ? const Color(0xFF262A30) : Colors.white,
                                foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              onPressed: () => _onNumberPressed(num),
                              child: Text(
                                '$num',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: isDark ? const Color(0xFF262A30) : Colors.white,
                              foregroundColor: Colors.redAccent,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: _onErasePressed,
                            child: const Icon(Icons.backspace_outlined, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

