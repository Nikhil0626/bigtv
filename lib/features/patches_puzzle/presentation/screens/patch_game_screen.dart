import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import '../widgets/patch_profile_prompt_dialog.dart';
import '../../data/models/patch_model.dart';
import '../../../../services/puzzle_api_service.dart';
import 'patch_dashboard_screen.dart';
import '../../../../services/game_share_helper.dart';
import '../../../../core/widgets/game_watermark_widget.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

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

class _PatchGameScreenState extends State<PatchGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  PatchLevel? _level;
  final List<PlacedPatch> _placedPatches = [];
  final List<List<PlacedPatch>> _undoHistory = [];
  bool _isLoading = true;
  bool _isCompleted = false;
  String? _errorMessage;
  int? _cachedRank;
  int? _cachedStreak;
  int? _cachedDurationMs;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _savedElapsedMs = 0;
  int get _currentElapsedMs => _savedElapsedMs + _stopwatch.elapsedMilliseconds;
  int get _currentElapsedSec => _currentElapsedMs ~/ 1000;

  // Countdown overlay state on resuming in-progress game
  bool _isCountingDown = false;
  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  // Board screenshot & completion flow tracking
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _hasHandledCompletionFlow = false;

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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _waveController.repeat();
    }
    _loadDailyPatch();
  }

  String _getSavedStateKey(String levelId) =>
      'patch_in_progress_${widget.playerId}_$levelId';

  Future<void> _saveInProgressState() async {
    if (widget.isViewOnly || _isCompleted || _level == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'levelId': _level!.levelId,
        'elapsedMs': _currentElapsedMs,
        'patches': _placedPatches.map((p) => p.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_getSavedStateKey(_level!.levelId), jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving patch game state: $e');
    }
  }

  Future<void> _clearInProgressState() async {
    if (_level == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getSavedStateKey(_level!.levelId));
    } catch (e) {
      debugPrint('Error clearing patch game state: $e');
    }
  }

  void _startResumeCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        _stopwatch.start();
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _saveInProgressState();
    _waveController.dispose();
    _timer?.cancel();
    _countdownTimer?.cancel();
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

      // Check for saved in-progress state to resume
      bool hasResumed = false;
      if (!widget.isViewOnly) {
        final prefs = await SharedPreferences.getInstance();
        final rawSaved = prefs.getString(_getSavedStateKey(level.levelId));
        if (rawSaved != null && rawSaved.isNotEmpty) {
          try {
            final Map<String, dynamic> savedMap = jsonDecode(rawSaved);
            final savedPatchesRaw = savedMap['patches'] as List?;
            final savedElapsedMs = (savedMap['elapsedMs'] as num?)?.toInt() ?? 0;

            if (savedPatchesRaw != null && savedPatchesRaw.isNotEmpty) {
              _placedPatches.clear();
              for (final item in savedPatchesRaw) {
                _placedPatches.add(PlacedPatch.fromJson(Map<String, dynamic>.from(item)));
              }
              _undoHistory.clear();
              _undoHistory.add(List.from(_placedPatches));
              _savedElapsedMs = savedElapsedMs;
              hasResumed = true;
            }
          } catch (e) {
            debugPrint('Error restoring saved patch state: $e');
          }
        }
      }

      if (!widget.isViewOnly) {
        AnalyticsService.instance.track(AnalyticsEventName.gameStart, properties: {
          'game_id': 'patch_puzzle',
          'round_id': level.levelId,
        });

        if (hasResumed) {
          _startResumeCountdown();
        } else {
          _stopwatch.start();
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() {});
          });
        }
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
    if (widget.isViewOnly || _isCompleted || _isCountingDown) return;

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

    _saveInProgressState();
    _checkWinCondition();
  }

  void _removePatch(PlacedPatch patch) {
    setState(() {
      _placedPatches.remove(patch);
      _undoHistory.add(List.from(_placedPatches));
    });
    _saveInProgressState();
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
    _saveInProgressState();
  }

  void _onReset() {
    if (_placedPatches.isEmpty || _isCompleted || widget.isViewOnly) return;
    setState(() {
      _placedPatches.clear();
      _undoHistory.clear();
      _savedElapsedMs = 0;
    });
    _clearInProgressState();
    _stopwatch.reset();
    _stopwatch.start();
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
    _clearInProgressState();
    setState(() => _isCompleted = true);

    final duration = _currentElapsedMs;
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

      setState(() {
        _cachedDurationMs = duration;
        _cachedRank = rank;
        _cachedStreak = streak;
      });
    });
  }


  Future<void> _shareCurrentGame() async {
    final duration = _cachedDurationMs ?? _currentElapsedMs;
    final formattedTime = '${(duration / 1000).toStringAsFixed(1)}s';

    XFile? screenshotXFile;
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 20),
      );
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imageFile = File('${directory.path}/patch_game_${DateTime.now().millisecondsSinceEpoch}.png');
        await imageFile.writeAsBytes(imageBytes);
        screenshotXFile = XFile(imageFile.path);
      }
    } catch (e) {
      debugPrint('Error capturing patch game screenshot: $e');
    }

    if (!mounted) return;
    await GameShareHelper.shareGame(
      context: context,
      gameSlug: 'patch',
      gameTitle: 'Patch Puzzle',
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
      // Prompt user for Name and Profile Pic
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PatchProfilePromptDialog(
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
          builder: (_) => PatchDashboardScreen(playerId: widget.playerId),
        ),
      );
    }
  }

  void _fireBackgroundSync({
    required String displayName,
    required String photoUrl,
  }) {
    final duration = _cachedDurationMs ?? _currentElapsedMs;

    try {
      GameProfileManager.saveUnifiedProfile(
        name: displayName,
        photoUrl: photoUrl,
      );
    } catch (_) {}

    PuzzleApiService.submitGame(
      gameSlug: 'patch',
      playerId: widget.playerId,
      durationMs: duration > 0 ? duration : 30000,
      score: 100,
      displayName: displayName,
      avatarUrl: photoUrl,
    ).catchError((e) {
      debugPrint('Error syncing patch score: $e');
      return <String, dynamic>{};
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

    final bool canDirectPop = (!_isCompleted && !widget.isViewOnly) || _hasHandledCompletionFlow;

    return PopScope(
      canPop: canDirectPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveInProgressState();
        } else if ((_isCompleted || widget.isViewOnly) && !_hasHandledCompletionFlow) {
          _handleDoneOrBack(isDone: false);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, isDark, level),
        body: Stack(
          children: [
            // 1. Base Gradient Canvas Mesh (like feedback screen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF180A0D),
                            const Color(0xFF0F0F12),
                            const Color(0xFF13090B),
                          ]
                        : [
                            const Color(0xFFFFF2F4),
                            const Color(0xFFFBFBFC),
                            const Color(0xFFFFF6F7),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Top Right Wave Ripple Art (like feedback screen)
            Positioned(
              top: 0,
              right: 0,
              width: MediaQuery.of(context).size.width,
              height: 380.h,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: TopRightWavePainter(
                        waveAnimation: _waveController,
                        isDark: isDark,
                        maxRadius: 380.0,
                        gap: 22.0,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Foreground Gameplay Content
            SafeArea(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),

                            // Controls Row: [Difficulty Pill] | [Undo] [Reset]
                            _buildControlsRow(context, level, isDark),

                            SizedBox(height: 12.h),

                            // Main Game Board with direct drag-to-select
                            _buildBoard(context, level, boardSize, isDark),

                            SizedBox(height: 16.h),

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

            // 4. Countdown Overlay when resuming
            if (_isCountingDown)
              _buildCountdownOverlay(context, isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    PatchLevel? level,
  ) {
    final elapsedSec = _currentElapsedSec;

    return AppBar(
      centerTitle: true,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          level != null
              ? 'Patch (${level.rows}x${level.columns})'
              : 'Patch Game',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () {
          if ((_isCompleted || widget.isViewOnly) && !_hasHandledCompletionFlow) {
            _handleDoneOrBack(isDone: false);
          } else {
            _saveInProgressState();
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        if (level != null && !widget.isViewOnly) ...[
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2024).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF33363D) : Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
          ),
        ] else if (level != null && widget.isViewOnly) ...[
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

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.w),
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
          ),
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

    bool isCellInDrag(int r, int c) {
      if (!_isDragging || _dragStart == null || _dragCurrent == null) return false;
      final minR = min(_dragStart!.y, _dragCurrent!.y);
      final maxR = max(_dragStart!.y, _dragCurrent!.y);
      final minC = min(_dragStart!.x, _dragCurrent!.x);
      final maxC = max(_dragStart!.x, _dragCurrent!.x);
      return r >= minR && r <= maxR && c >= minC && c <= maxC;
    }

    return Center(
      child: Screenshot(
        controller: _screenshotController,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Grid background cells
                  Positioned.fill(
                    child: Column(
                      children: List.generate(level.rows, (r) {
                        return Expanded(
                          child: Row(
                            children: List.generate(level.columns, (c) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF16181C) : Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF2A2D35)
                                          : level.gridBorder.withValues(alpha: 0.35),
                                      width: 0.8,
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

                  // 2. Placed Patches - EACH COLOUR IS A SINGLE UNIFIED BOX
                  for (final patch in _placedPatches)
                    Positioned(
                      left: patch.minCol * cellW,
                      top: patch.minRow * cellH,
                      width: patch.width * cellW,
                      height: patch.height * cellH,
                      child: Container(
                        margin: EdgeInsets.all(1.2.w),
                        decoration: BoxDecoration(
                          color: patch.color,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: patch.color.withValues(alpha: isDark ? 0.35 : 0.28),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. Active drag selection - SINGLE UNIFIED PREVIEW RECTANGLE
                  if (_isDragging && _dragStart != null && _dragCurrent != null) () {
                    final minR = min(_dragStart!.y, _dragCurrent!.y);
                    final maxR = max(_dragStart!.y, _dragCurrent!.y);
                    final minC = min(_dragStart!.x, _dragCurrent!.x);
                    final maxC = max(_dragStart!.x, _dragCurrent!.x);
                    final dragW = (maxC - minC + 1) * cellW;
                    final dragH = (maxR - minR + 1) * cellH;

                    return Positioned(
                      left: minC * cellW,
                      top: minR * cellH,
                      width: dragW,
                      height: dragH,
                      child: Container(
                        margin: EdgeInsets.all(1.2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF2563EB),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),

                  // 4. Background image tilted 45 degrees covering full container of game background when completed
                  if (_isCompleted || widget.isViewOnly)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Transform.rotate(
                            angle: 45 * pi / 180,
                            child: SizedBox(
                              width: innerSize * 1.5,
                              height: innerSize * 1.5,
                              child: GameWatermarkWidget(
                                logoUrl: level.logoUrl,
                                size: innerSize * 1.5,
                                fit: BoxFit.cover,
                                opacity: 0.52,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 5. Clues and indicators for all clue cells (drawn on top of background image)
                  for (final clue in level.clues) () {
                    final patch = _getPatchAt(clue.row, clue.col);
                    final inDrag = isCellInDrag(clue.row, clue.col);

                    // Center the clue inside the entire patch rectangle when covered
                    final double clueLeft = (patch != null)
                        ? patch.minCol * cellW
                        : clue.col * cellW;
                    final double clueTop = (patch != null)
                        ? patch.minRow * cellH
                        : clue.row * cellH;
                    final double clueWidth = (patch != null)
                        ? patch.width * cellW
                        : cellW;
                    final double clueHeight = (patch != null)
                        ? patch.height * cellH
                        : cellH;

                    return Positioned(
                      left: clueLeft,
                      top: clueTop,
                      width: clueWidth,
                      height: clueHeight,
                      child: IgnorePointer(
                        child: Center(
                          child: _buildCellContent(
                            clue,
                            patch,
                            inDrag,
                            isDark,
                          ),
                        ),
                      ),
                    );
                  }(),
                ],
              ),
            ),
          ),
        ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${clue.value}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: (placedPatch != null && placedPatch.area > 2) ? 18.sp : 16.sp,
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
    Widget content;
    if (_isCompleted && !widget.isViewOnly) {
      content = _buildDoneBanner(context, isDark);
    } else if (widget.isViewOnly) {
      content = _buildViewOnlyBanner(context, isDark);
    } else if (_isDragging && _dragStart != null && _dragCurrent != null) {
      content = _buildActiveDragStatus(context, level, isDark);
    } else {
      content = _buildDefaultStatusCard(context, level, isDark);
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w),
        child: content,
      ),
    );
  }

  Widget _buildDoneBanner(BuildContext context, bool isDark) {
    return _buildCompletedBanner(context, isDark);
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
      title = '$area boxes selected ($w×$h)';
      subtitle = 'Drag over a number to form its patch';
    } else if (cluesInside.length == 1) {
      final clue = cluesInside.first;
      if (area == clue.value) {
        bannerColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green.withValues(alpha: 0.45);
        icon = Icons.check_circle_rounded;
        title = '✓ $area boxes for clue ${clue.value} ($w×$h)';
        subtitle = 'Release to place patch!';
      } else {
        bannerColor = Colors.orange.withValues(alpha: 0.12);
        borderColor = Colors.orange.withValues(alpha: 0.45);
        icon = Icons.straighten_rounded;
        title = 'Selected $area boxes ($w×$h)';
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

  Widget _buildCompletedBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                    'You have completed today\'s Patch puzzle!',
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
                        builder: (_) => PatchDashboardScreen(playerId: widget.playerId),
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

  Widget _buildViewOnlyBanner(BuildContext context, bool isDark) {
    return _buildCompletedBanner(context, isDark);
  }

  Widget _buildCountdownOverlay(BuildContext context, bool isDark) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE50914).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: const Color(0xFFE50914), size: 18.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Resuming Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Starting in',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 16.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey<int>(_countdownSeconds),
                  width: 96.w,
                  height: 96.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFE50914), Color(0xFF990008)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.65),
                        blurRadius: 28,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '$_countdownSeconds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Resuming from where you left off...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
