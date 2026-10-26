import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/patch_model.dart';
import '../../../../services/puzzle_api_service.dart';
import 'patch_dashboard_screen.dart';
import '../widgets/patch_completion_dialog.dart';
import '../../../zip_puzzle/presentation/screens/zip_leaderboard_screen.dart';
import '../../../../services/game_share_helper.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';

class PatchGameScreen extends StatefulWidget {
  final String playerId;
  final bool isViewOnly;

  const PatchGameScreen({
    super.key,
    required this.playerId,
    this.isViewOnly = false,
  });

  @override
  State<PatchGameScreen> createState() => _PatchGameScreenState();
}

class _PatchGameScreenState extends State<PatchGameScreen> {
  PatchLevel? _level;
  final List<PlacedPatch> _placedPatches = [];
  final List<List<PlacedPatch>> _undoHistory = [];
  bool _isLoading = true;
  bool _isCompleted = false;
  String? _errorMessage;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // Board pointer drag tracking
  final GlobalKey _boardKey = GlobalKey();
  Point<int>? _dragStart;
  Point<int>? _dragCurrent;
  bool _isDragging = false;

  static const List<Color> _paletteColors = [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFF7C3AED), // Violet
    Color(0xFFE11D48), // Rose
    Color(0xFF0891B2), // Cyan
    Color(0xFFEA580C), // Orange
    Color(0xFF4F46E5), // Indigo
    Color(0xFF16A34A), // Green
    Color(0xFF9333EA), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyPatch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_isCompleted && !widget.isViewOnly) {
      AnalyticsService.instance.track(AnalyticsEventName.gameIncomplete, properties: {
        'game_id': 'patch_puzzle',
        'round_id': _level?.levelId ?? 'daily',
        'reason': 'user_exit',
      });
    }
    AnalyticsService.instance.track(AnalyticsEventName.gameExit, properties: {
      'game_id': 'patch_puzzle',
      'round_id': _level?.levelId ?? 'daily',
    });
    super.dispose();
  }

  Future<void> _loadDailyPatch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PuzzleApiService.getTodayGame(
        gameSlug: 'patch',
        playerId: widget.playerId,
      );
      final level = PatchLevel.fromJson(data);
      if (!mounted) return;

      setState(() {
        _level = level;
        _placedPatches.clear();
        _undoHistory.clear();

        if (widget.isViewOnly) {
          if (level.solution.isNotEmpty) {
            for (int i = 0; i < level.solution.length; i++) {
              final sol = level.solution[i];
              int minR = sol.cells.map((c) => c.row).reduce((a, b) => a < b ? a : b);
              int maxR = sol.cells.map((c) => c.row).reduce((a, b) => a > b ? a : b);
              int minC = sol.cells.map((c) => c.col).reduce((a, b) => a < b ? a : b);
              int maxC = sol.cells.map((c) => c.col).reduce((a, b) => a > b ? a : b);

              PatchClueData? clue;
              for (final c in level.clues) {
                if (c.row >= minR && c.row <= maxR && c.col >= minC && c.col <= maxC) {
                  clue = c;
                  break;
                }
              }

              final piece = level.pieces.firstWhere(
                (p) => p.id == sol.pieceId,
                orElse: () => PatchPiece(
                  id: sol.pieceId,
                  color: _paletteColors[i % _paletteColors.length],
                  cells: [],
                ),
              );

              _placedPatches.add(PlacedPatch(
                id: sol.pieceId,
                minRow: minR,
                maxRow: maxR,
                minCol: minC,
                maxCol: maxC,
                color: piece.color,
                clueValue: clue?.value ?? ((maxR - minR + 1) * (maxC - minC + 1)),
                clueRow: clue?.row ?? minR,
                clueCol: clue?.col ?? minC,
              ));
            }
          }
          _isCompleted = true;
        }

        _isLoading = false;
      });

      if (!widget.isViewOnly) {
        AnalyticsService.instance.track(AnalyticsEventName.gameStart, properties: {
          'game_id': 'patch_puzzle',
          'round_id': level.levelId,
        });
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Patch game: $e')),
        );
      }
    }
  }

  PlacedPatch? _getPatchAt(int r, int c) {
    for (final patch in _placedPatches) {
      if (patch.contains(r, c)) return patch;
    }
    return null;
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600),
        ),
        duration: const Duration(milliseconds: 1700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event, double boardSize, PatchLevel level) {
    if (widget.isViewOnly || _isCompleted) return;

    final RenderBox? box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(event.position);

    final innerSize = boardSize - (8.w);
    final cellW = innerSize / level.columns;
    final cellH = innerSize / level.rows;

    final x = localPos.dx - 4.w;
    final y = localPos.dy - 4.w;

    if (x < 0 || x >= innerSize || y < 0 || y >= innerSize) return;

    final col = (x / cellW).floor().clamp(0, level.columns - 1);
    final row = (y / cellH).floor().clamp(0, level.rows - 1);

    setState(() {
      _dragStart = Point<int>(col, row);
      _dragCurrent = Point<int>(col, row);
      _isDragging = true;
    });
  }

  void _onPointerMove(PointerMoveEvent event, double boardSize, PatchLevel level) {
    if (!_isDragging || _dragStart == null) return;

    final RenderBox? box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(event.position);

    final innerSize = boardSize - (8.w);
    final cellW = innerSize / level.columns;
    final cellH = innerSize / level.rows;

    final x = localPos.dx - 4.w;
    final y = localPos.dy - 4.w;

    final col = (x / cellW).floor().clamp(0, level.columns - 1);
    final row = (y / cellH).floor().clamp(0, level.rows - 1);

    if (_dragCurrent?.x != col || _dragCurrent?.y != row) {
      setState(() {
        _dragCurrent = Point<int>(col, row);
      });
    }
  }

  void _onPointerUp(PointerUpEvent event, PatchLevel level) {
    if (!_isDragging || _dragStart == null || _dragCurrent == null) {
      setState(() {
        _isDragging = false;
        _dragStart = null;
        _dragCurrent = null;
      });
      return;
    }

    final startCol = _dragStart!.x;
    final startRow = _dragStart!.y;
    final endCol = _dragCurrent!.x;
    final endRow = _dragCurrent!.y;

    final minR = min(startRow, endRow);
    final maxR = max(startRow, endRow);
    final minC = min(startCol, endCol);
    final maxC = max(startCol, endCol);

    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragCurrent = null;
    });

    _onSelectionCompleted(minR, maxR, minC, maxC, level);
  }

  void _onSelectionCompleted(int minR, int maxR, int minC, int maxC, PatchLevel level) {
    final area = (maxR - minR + 1) * (maxC - minC + 1);

    // Single box tapped
    if (area == 1) {
      final existingPatch = _getPatchAt(minR, minC);
      if (existingPatch != null) {
        // Tap on placed patch removes it
        _removePatch(existingPatch);
        return;
      }

      final clue = level.getClueAt(minR, minC);
      if (clue != null) {
        if (clue.value == 1) {
          _placePatch(minR, maxR, minC, maxC, clue, level);
        } else {
          _showFeedback('Drag from ${clue.value} across ${clue.value} boxes to form this patch');
        }
      }
      return;
    }

    // Dragged across multiple boxes
    final cluesInside = <PatchClueData>[];
    for (int r = minR; r <= maxR; r++) {
      for (int c = minC; c <= maxC; c++) {
        final clue = level.getClueAt(r, c);
        if (clue != null) {
          cluesInside.add(clue);
        }
      }
    }

    if (cluesInside.isEmpty) {
      _showFeedback('Patch must contain a clue number');
      return;
    }

    if (cluesInside.length > 1) {
      _showFeedback('Cannot cover multiple numbers in one patch');
      return;
    }

    final clue = cluesInside.first;
    final w = maxC - minC + 1;
    final h = maxR - minR + 1;

    if (area != clue.value) {
      _showFeedback('Clue requires ${clue.value} boxes (selected $area)');
      return;
    }

    final shape = clue.shape.toLowerCase();
    if (shape == 'wide' && w <= h && clue.value > 1) {
      _showFeedback('Clue requires a wide (horizontal) patch');
      return;
    }
    if (shape == 'tall' && h <= w && clue.value > 1) {
      _showFeedback('Clue requires a tall (vertical) patch');
      return;
    }
    if ((shape == 'sq' || shape == 'square') && w != h) {
      _showFeedback('Clue requires a square patch');
      return;
    }

    _placePatch(minR, maxR, minC, maxC, clue, level);
  }

  void _placePatch(int minR, int maxR, int minC, int maxC, PatchClueData clue, PatchLevel level) {
    // 1. Remove any overlapping patches or patch previously covering this clue
    _placedPatches.removeWhere((p) {
      if (p.clueRow == clue.row && p.clueCol == clue.col) return true;
      for (int r = minR; r <= maxR; r++) {
        for (int c = minC; c <= maxC; c++) {
          if (p.contains(r, c)) return true;
        }
      }
      return false;
    });

    // 2. Select color
    final clueIndex = level.clues.indexOf(clue);
    Color patchColor;
    if (clueIndex >= 0 && clueIndex < level.pieces.length) {
      patchColor = level.pieces[clueIndex].color;
    } else {
      final idx = clueIndex >= 0 ? clueIndex : _placedPatches.length;
      patchColor = _paletteColors[idx % _paletteColors.length];
    }

    // 3. Create patch
    final newPatch = PlacedPatch(
      id: 'patch_${clue.row}_${clue.col}',
      minRow: minR,
      maxRow: maxR,
      minCol: minC,
      maxCol: maxC,
      color: patchColor,
      clueValue: clue.value,
      clueRow: clue.row,
      clueCol: clue.col,
    );

    setState(() {
      _placedPatches.add(newPatch);
      _undoHistory.add(List.from(_placedPatches));
    });

    _checkWinCondition();
  }

  void _removePatch(PlacedPatch patch) {
    setState(() {
      _placedPatches.remove(patch);
      _undoHistory.add(List.from(_placedPatches));
    });
  }

  void _onUndo() {
    if (_undoHistory.isEmpty || _isCompleted || widget.isViewOnly) return;
    setState(() {
      _undoHistory.removeLast();
      _placedPatches.clear();
      if (_undoHistory.isNotEmpty) {
        _placedPatches.addAll(_undoHistory.last);
      }
    });
  }

  void _onReset() {
    if (_placedPatches.isEmpty || _isCompleted || widget.isViewOnly) return;
    setState(() {
      _placedPatches.clear();
      _undoHistory.clear();
    });
  }

  void _checkWinCondition() {
    final level = _level;
    if (level == null) return;

    final totalCells = level.rows * level.columns;
    int coveredCells = 0;
    for (final p in _placedPatches) {
      coveredCells += p.area;
    }

    if (coveredCells < totalCells) return;

    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.columns; c++) {
        if (_getPatchAt(r, c) == null) return;
      }
    }

    _stopwatch.stop();
    _timer?.cancel();
    setState(() => _isCompleted = true);

    final duration = _stopwatch.elapsedMilliseconds;
    AnalyticsService.instance.track(AnalyticsEventName.gameComplete, properties: {
      'game_id': 'patch_puzzle',
      'round_id': _level?.levelId ?? 'daily',
      'score': 100,
      'duration_ms': duration,
    });
    PuzzleApiService.submitGame(
      gameSlug: 'patch',
      playerId: widget.playerId,
      durationMs: duration > 0 ? duration : 30000,
      score: 100,
    ).then((res) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      SharedPreferences.getInstance().then((p) => p.setBool('puzzle_completed_patch_$today', true));

      if (!mounted) return;
      final rank = res['rank'] ?? 1;
      final streak = res['streak'] != null ? res['streak']['currentStreak'] ?? 1 : 1;
      AnalyticsService.instance.track(AnalyticsEventName.gameScoreRecorded, properties: {
        'game_id': 'patch_puzzle',
        'score': 100,
        'rank': rank,
      });

      final formattedTime = '${(duration / 1000).toStringAsFixed(1)}s';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => PatchCompletionDialog(
          formattedTime: formattedTime,
          rank: rank,
          streak: streak,
          onViewGame: () {
            Navigator.pop(dialogCtx);
          },
          onDashboard: () {
            Navigator.pop(dialogCtx);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PatchDashboardScreen(playerId: widget.playerId),
              ),
            );
          },
          onReplay: () {
            Navigator.pop(dialogCtx);
            _onReset();
            _stopwatch.reset();
            _stopwatch.start();
            setState(() => _isCompleted = false);
          },
          onViewLeaderboard: () {
            Navigator.pop(dialogCtx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ZipLeaderboardScreen(
                  isDailyLeaderboard: true,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
        appBar: _buildAppBar(context, isDark, null),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFE50914),
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading today\'s Patch puzzle...',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _level == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
        appBar: _buildAppBar(context, isDark, null),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey),
                SizedBox(height: 14.h),
                Text(
                  'Failed to load Patch puzzle',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: _loadDailyPatch,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final level = _level!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
      appBar: _buildAppBar(context, isDark, level),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double availableHeight = constraints.maxHeight;

            final double horizontalPadding = 16.w;
            final double maxBoardWidth = (availableWidth - (horizontalPadding * 2)).clamp(200.0, 360.0);
            final double maxBoardHeight = (availableHeight - 190.h).clamp(200.0, 360.0);
            final double boardSize = min(maxBoardWidth, maxBoardHeight);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),

                      // Controls Row: [Difficulty Pill] | [Undo] [Reset]
                      _buildControlsRow(context, level, isDark),

                      SizedBox(height: 10.h),

                      // Main Game Board with direct drag-to-select
                      _buildBoard(context, level, boardSize, isDark),

                      SizedBox(height: 14.h),

                      // Interactive Status Card or View-Only Completion Banner
                      _buildInteractionStatusArea(context, level, isDark),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    PatchLevel? level,
  ) {
    final elapsedSec = _stopwatch.elapsed.inSeconds;

    return AppBar(
      title: Text(
        level != null
            ? (widget.isViewOnly
                ? 'Patch (${level.rows}x${level.columns}) - Solved'
                : 'Patch (${level.rows}x${level.columns})')
            : 'Patch Game',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
      ),
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (level != null && !widget.isViewOnly)
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2024) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF33363D) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                    SizedBox(width: 4.w),
                    Text(
                      '${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (level != null && widget.isViewOnly) ...[
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.green, size: 20),
              tooltip: 'Share Game',
              onPressed: () {
                GameShareHelper.shareGame(
                  context: context,
                  gameSlug: 'patch',
                  gameTitle: 'Patch Puzzle',
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlsRow(BuildContext context, PatchLevel level, bool isDark) {
    final bool canUndo = _undoHistory.isNotEmpty && !_isCompleted && !widget.isViewOnly;
    final bool canReset = _placedPatches.isNotEmpty && !_isCompleted && !widget.isViewOnly;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Difficulty Capsule
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF33363D) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Flexible(
                    child: Text(
                      'Difficulty ${level.difficulty.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Undo & Reset Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Undo Button
              InkWell(
                onTap: canUndo ? _onUndo : null,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: canUndo
                        ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                        : (isDark ? const Color(0xFF16181C) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: canUndo
                          ? (isDark ? const Color(0xFF33363D) : const Color(0xFFCBD5E1))
                          : (isDark ? const Color(0xFF22252B) : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.undo_rounded,
                        size: 14.sp,
                        color: canUndo
                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                            : const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Undo',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: canUndo
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Reset Button
              InkWell(
                onTap: canReset ? _onReset : null,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: canReset
                        ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                        : (isDark ? const Color(0xFF16181C) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: canReset
                          ? (isDark ? const Color(0xFF33363D) : const Color(0xFFCBD5E1))
                          : (isDark ? const Color(0xFF22252B) : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 14.sp,
                        color: canReset
                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                            : const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: canReset
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(
    BuildContext context,
    PatchLevel level,
    double boardSize,
    bool isDark,
  ) {
    final double innerSize = boardSize - (8.w);
    final double cellW = innerSize / level.columns;
    final double cellH = innerSize / level.rows;

    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => _onPointerDown(event, boardSize, level),
        onPointerMove: (event) => _onPointerMove(event, boardSize, level),
        onPointerUp: (event) => _onPointerUp(event, level),
        child: Container(
          key: _boardKey,
          width: boardSize,
          height: boardSize,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2024) : level.boardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF33363D) : level.gridBorder,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(level.rows, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(level.columns, (c) {
                    return Expanded(
                      child: _buildBoardCell(context, level, r, c, cellW, cellH, isDark),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCell(
    BuildContext context,
    PatchLevel level,
    int r,
    int c,
    double cellW,
    double cellH,
    bool isDark,
  ) {
    // Check if cell is within the active drag bounding box
    bool isDragSelected = false;
    if (_isDragging && _dragStart != null && _dragCurrent != null) {
      final minR = min(_dragStart!.y, _dragCurrent!.y);
      final maxR = max(_dragStart!.y, _dragCurrent!.y);
      final minC = min(_dragStart!.x, _dragCurrent!.x);
      final maxC = max(_dragStart!.x, _dragCurrent!.x);
      isDragSelected = r >= minR && r <= maxR && c >= minC && c <= maxC;
    }

    final PlacedPatch? placedPatch = _getPatchAt(r, c);
    final clue = level.getClueAt(r, c);

    // Color logic
    Color cellBgColor;
    if (isDragSelected) {
      cellBgColor = const Color(0xFF2563EB).withValues(alpha: 0.32);
    } else if (placedPatch != null) {
      cellBgColor = placedPatch.color;
    } else if (clue != null) {
      cellBgColor = isDark ? const Color(0xFF232730) : const Color(0xFFEEF2F6);
    } else {
      cellBgColor = isDark ? const Color(0xFF16181C) : Colors.white;
    }

    // Border logic (uniform border to comply with Flutter borderRadius constraints)
    Color borderColor;
    double borderWidth;
    if (isDragSelected) {
      borderColor = const Color(0xFF2563EB);
      borderWidth = 2.0;
    } else if (placedPatch != null) {
      borderColor = Colors.black.withValues(alpha: 0.22);
      borderWidth = 1.0;
    } else {
      borderColor = isDark ? const Color(0xFF2A2D35) : level.gridBorder.withValues(alpha: 0.55);
      borderWidth = 0.8;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: EdgeInsets.all(isDragSelected ? 0.6.w : (placedPatch != null ? 0.8.w : 1.5.w)),
      decoration: BoxDecoration(
        color: cellBgColor,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: placedPatch != null
            ? [
                BoxShadow(
                  color: placedPatch.color.withValues(alpha: 0.28),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : (isDragSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null),
      ),
      child: Center(
        child: _buildCellContent(clue, placedPatch, isDragSelected, isDark),
      ),
    );
  }

  Widget _buildCellContent(
    PatchClueData? clue,
    PlacedPatch? placedPatch,
    bool isDragSelected,
    bool isDark,
  ) {
    if (clue == null) {
      return const SizedBox.shrink();
    }

    final bool isCovered = placedPatch != null;
    Color textColor;
    if (isCovered || isDragSelected) {
      textColor = Colors.white;
    } else {
      textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    }

    final Color iconColor = (isCovered || isDragSelected)
        ? Colors.white.withValues(alpha: 0.8)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${clue.value}',
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            shadows: (isCovered || isDragSelected)
                ? [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildClueShapeBadge(clue.shape, iconColor),
      ],
    );
  }

  Widget _buildClueShapeBadge(String shape, Color color) {
    switch (shape.toLowerCase()) {
      case 'wide':
        return Container(
          width: 14.w,
          height: 5.5.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      case 'tall':
        return Container(
          width: 5.5.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      case 'sq':
      case 'square':
        return Container(
          width: 7.5.w,
          height: 7.5.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5.r),
          ),
        );
      default:
        return Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  Widget _buildInteractionStatusArea(BuildContext context, PatchLevel level, bool isDark) {
    if (widget.isViewOnly) {
      return _buildViewOnlyBanner(context, isDark);
    }

    if (_isDragging && _dragStart != null && _dragCurrent != null) {
      return _buildActiveDragStatus(context, level, isDark);
    }

    return _buildDefaultStatusCard(context, level, isDark);
  }

  Widget _buildActiveDragStatus(BuildContext context, PatchLevel level, bool isDark) {
    final minR = min(_dragStart!.y, _dragCurrent!.y);
    final maxR = max(_dragStart!.y, _dragCurrent!.y);
    final minC = min(_dragStart!.x, _dragCurrent!.x);
    final maxC = max(_dragStart!.x, _dragCurrent!.x);
    final w = maxC - minC + 1;
    final h = maxR - minR + 1;
    final area = w * h;

    final cluesInside = <PatchClueData>[];
    for (int r = minR; r <= maxR; r++) {
      for (int c = minC; c <= maxC; c++) {
        final clue = level.getClueAt(r, c);
        if (clue != null) cluesInside.add(clue);
      }
    }

    Color bannerColor;
    Color borderColor;
    IconData icon;
    String title;
    String subtitle;

    if (cluesInside.isEmpty) {
      bannerColor = const Color(0xFF2563EB).withValues(alpha: 0.1);
      borderColor = const Color(0xFF2563EB).withValues(alpha: 0.35);
      icon = Icons.crop_free_rounded;
      title = '$area boxes selected (${w}×$h)';
      subtitle = 'Drag over a number to form its patch';
    } else if (cluesInside.length == 1) {
      final clue = cluesInside.first;
      if (area == clue.value) {
        bannerColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green.withValues(alpha: 0.45);
        icon = Icons.check_circle_rounded;
        title = '✓ $area boxes for clue ${clue.value} (${w}×$h)';
        subtitle = 'Release to place patch!';
      } else {
        bannerColor = Colors.orange.withValues(alpha: 0.12);
        borderColor = Colors.orange.withValues(alpha: 0.45);
        icon = Icons.straighten_rounded;
        title = 'Selected $area boxes (${w}×$h)';
        subtitle = 'Clue ${clue.value} requires ${clue.value} boxes';
      }
    } else {
      bannerColor = Colors.red.withValues(alpha: 0.12);
      borderColor = Colors.red.withValues(alpha: 0.45);
      icon = Icons.error_outline_rounded;
      title = '⚠️ Multiple numbers selected';
      subtitle = 'Cannot cover multiple clues in one patch';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: borderColor.withValues(alpha: 1.0)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
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

  Widget _buildDefaultStatusCard(BuildContext context, PatchLevel level, bool isDark) {
    final placedCount = _placedPatches.length;
    final totalClues = level.clues.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2024) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? const Color(0xFF33363D) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app_rounded,
                color: const Color(0xFFE50914),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tap a number & drag to select boxes',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap placed patch to remove it',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: placedCount == totalClues
                    ? Colors.green.withValues(alpha: 0.15)
                    : (isDark ? const Color(0xFF2A2D35) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$placedCount/$totalClues',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: placedCount == totalClues
                      ? Colors.green
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOnlyBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'You have completed today\'s Patch puzzle!',
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatchDashboardScreen(playerId: widget.playerId),
                      ),
                    );
                  },
                  child: const Text('Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
