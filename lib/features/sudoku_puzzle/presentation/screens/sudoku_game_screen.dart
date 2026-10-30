import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import '../../../../core/widgets/game_profile_prompt_dialog.dart';
import '../../data/models/sudoku_model.dart';
import '../../../../services/puzzle_api_service.dart';
import '../../../../services/game_share_helper.dart';
import '../../../../core/widgets/game_watermark_widget.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'sudoku_dashboard_screen.dart';

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

  // Board screenshot & completion flow tracking
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _hasHandledCompletionFlow = false;

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

    // 1. Check Row Rule
    for (int col = 0; col < level.columns; col++) {
      if (col != c && _userGrid[r][col] == val) {
        hasRowConflict = true;
        conflicts.add(Point(r, col));
      }
    }

    // 2. Check Column Rule
    for (int row = 0; row < level.rows; row++) {
      if (row != r && _userGrid[row][c] == val) {
        hasColConflict = true;
        conflicts.add(Point(row, c));
      }
    }

    // 3. Check Box Rule
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
          return;
        }
      }
    }

    // Solved!
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
      _errorMessage = null;
      _conflictingCells = const {};
    });

    final duration = _stopwatch.elapsedMilliseconds;
    AnalyticsService.instance.track(AnalyticsEventName.gameComplete, properties: {
      'game_id': 'sudoku',
      'round_id': _level?.levelId ?? 'daily',
      'score': 100,
      'duration_ms': duration,
    });

    PuzzleApiService.submitGame(
      gameSlug: 'sudoku',
      playerId: widget.playerId,
      durationMs: duration > 0 ? duration : 30000,
      score: 100,
    ).then((res) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      SharedPreferences.getInstance().then((p) => p.setBool('puzzle_completed_sudoku_$today', true));

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
    });
  }

  Future<void> _shareCurrentGame() async {
    final duration = _cachedDurationMs ?? _stopwatch.elapsedMilliseconds;
    final formattedTime = '${(duration / 1000).toStringAsFixed(1)}s';

    XFile? screenshotXFile;
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 20),
      );
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imageFile = File('${directory.path}/sudoku_game_${DateTime.now().millisecondsSinceEpoch}.png');
        await imageFile.writeAsBytes(imageBytes);
        screenshotXFile = XFile(imageFile.path);
      }
    } catch (e) {
      debugPrint('Error capturing Sudoku screenshot: $e');
    }

    if (!mounted) return;
    await GameShareHelper.shareGame(
      context: context,
      gameSlug: 'sudoku',
      gameTitle: 'Sudoku Puzzle',
      formattedTime: formattedTime,
      rank: _cachedRank,
      streak: _cachedStreak,
      screenshotFile: screenshotXFile,
    );
  }

  Future<void> _handleDoneOrBack({required bool isDone}) async {
    final profileProvider = context.read<ProfileProvider>();
    final profile = await GameProfileManager.getUnifiedProfile(profileProvider: profileProvider);

    if (profile.hasValidName) {
      // User has ALREADY updated their name in profile or any game!
      // Navigate immediately with 0ms delay!
      _navigateAfterDoneOrBack();
      _fireBackgroundSync(displayName: profile.name, photoUrl: profile.photoUrl);
    } else {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GameProfilePromptDialog(
          initialName: '',
          initialPhotoUrl: profile.photoUrl,
          userId: widget.playerId,
          onProfileSaved: (savedName, savedPhoto) async {
            _navigateAfterDoneOrBack();
            _fireBackgroundSync(
              displayName: savedName,
              photoUrl: savedPhoto,
            );
          },
        ),
      );
    }
  }

  void _navigateAfterDoneOrBack() {
    _hasHandledCompletionFlow = true;
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SudokuDashboardScreen(playerId: widget.playerId),
        ),
      );
    }
  }

  void _fireBackgroundSync({
    required String displayName,
    required String photoUrl,
  }) {
    final duration = _cachedDurationMs ?? _stopwatch.elapsedMilliseconds;

    try {
      GameProfileManager.saveUnifiedProfile(
        name: displayName,
        photoUrl: photoUrl,
      );
    } catch (_) {}

    PuzzleApiService.submitGame(
      gameSlug: 'sudoku',
      playerId: widget.playerId,
      durationMs: duration > 0 ? duration : 30000,
      score: 100,
      displayName: displayName,
      avatarUrl: photoUrl,
    ).catchError((e) {
      debugPrint('Error syncing Sudoku score: $e');
      return <String, dynamic>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context, null),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE50914),
            strokeWidth: 2.5,
          ),
        ),
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
    final bool canDirectPop = (!_isCompleted && !widget.isViewOnly) || _hasHandledCompletionFlow;

    return PopScope(
      canPop: canDirectPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if ((_isCompleted || widget.isViewOnly) && !_hasHandledCompletionFlow) {
          _handleDoneOrBack(isDone: false);
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
        appBar: _buildAppBar(context, level, elapsedSec: elapsedSec, totalErrors: totalErrors),
        body: SafeArea(
          child: Column(
            children: [
              // Live error banner / Guide
              if (_errorMessage != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF991B1B) : const Color(0xFFF87171),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (!widget.isViewOnly && !_isCompleted)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 15.sp,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Each row, column & ${level.boxRows}x${level.boxCols} block must contain 1-${level.rows}',
                          style: TextStyle(
                            fontSize: 11.5.sp,
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

              SizedBox(height: 4.h),

              // SUDOKU GRID with Screenshot wrapping
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = min(constraints.maxWidth, constraints.maxHeight);
                      if (size <= 0) return const SizedBox.shrink();
                      return Center(
                        child: Screenshot(
                          controller: _screenshotController,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: SizedBox(
                              width: size,
                              height: size,
                              child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: palette.blockBorder, width: 2.5),
                                    borderRadius: BorderRadius.circular(4.r),
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
                                              textColor = const Color(0xFFDC2626);
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
                                                        fontSize: level.rows == 6 ? 26.sp : 20.sp,
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

                                // Background watermark image tilted 45 degrees covering container when completed
                                if (_isCompleted || widget.isViewOnly)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Transform.rotate(
                                          angle: 45 * pi / 180,
                                          child: SizedBox(
                                            width: size * 1.5,
                                            height: size * 1.5,
                                            child: GameWatermarkWidget(
                                              logoUrl: level.logoUrl,
                                              size: size * 1.5,
                                              fit: BoxFit.cover,
                                              opacity: 0.52,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom status & controls
              if (_isCompleted || widget.isViewOnly)
                _buildCompletedBanner(context, isDark)
              else
                _buildNumberKeypad(level, isDark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SudokuLevel? level, {
    int elapsedSec = 0,
    int totalErrors = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: InkWell(
          onTap: () {
            if ((_isCompleted || widget.isViewOnly) && !_hasHandledCompletionFlow) {
              _handleDoneOrBack(isDone: false);
            } else {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E222D).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/sudoku_puzzle_3d_icon.png',
              width: 22.w,
              height: 22.w,
              errorBuilder: (_, __, ___) => const Icon(Icons.grid_on_rounded, color: Colors.blueAccent, size: 20),
            ),
            SizedBox(width: 6.w),
            Text(
              level != null ? 'Sudoku (${level.rows}x${level.columns})' : 'Sudoku Puzzle',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16.5.sp,
                letterSpacing: 0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!widget.isViewOnly && !_isCompleted) ...[
          if (totalErrors > 0)
            Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel_outlined, size: 13, color: Colors.red),
                    SizedBox(width: 3.w),
                    Text(
                      '$totalErrors',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2024) : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.blueAccent),
                  SizedBox(width: 3.w),
                  Text(
                    '${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ] else if (_isCompleted || widget.isViewOnly) ...[
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w900,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'You have completed today\'s Sudoku puzzle!',
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(Icons.share_rounded, size: 13.sp, color: const Color(0xFF10B981)),
                  label: const Text('Share', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: _shareCurrentGame,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _handleDoneOrBack(isDone: true),
                  child: const Text('Done', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _handleDoneOrBack(isDone: false),
                  child: const Text('Back', style: TextStyle(fontSize: 11)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SudokuDashboardScreen(playerId: widget.playerId),
                      ),
                    );
                  },
                  child: const Text('Dashboard', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberKeypad(SudokuLevel level, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        children: [
          ...List.generate(level.rows, (index) {
            final num = index + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isDark ? const Color(0xFF262A30) : Colors.white,
                      foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => _onNumberPressed(num),
                    child: Text(
                      '$num',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: isDark ? const Color(0xFF262A30) : Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: _onErasePressed,
                  child: Icon(Icons.backspace_outlined, size: 18.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
