import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import '../../../../core/widgets/game_profile_prompt_dialog.dart';
import '../../../../services/puzzle_api_service.dart';
import '../../data/models/daily_puzzle_models.dart';
import '../../data/models/grid_point.dart';
import '../../data/models/level_definition.dart';
import '../../data/repositories/zip_puzzle_repository.dart';
import '../providers/daily_puzzle_provider.dart';
import '../providers/zip_catalog_provider.dart';
import '../providers/zip_game_provider.dart';
import '../widgets/zip_board_widget.dart';
import '../widgets/zip_completion_dialog.dart';
import '../widgets/zip_how_to_play_card.dart';
import 'zip_leaderboard_screen.dart';
import 'zip_level_selection_screen.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import '../../../../services/game_share_helper.dart';

class ZipGameplayScreen extends StatefulWidget {
  final LevelDefinition level;
  final bool isDailyPuzzle;
  final bool isViewOnly;
  final List<GridPoint>? initialPath;
  final int? initialElapsedMs;

  const ZipGameplayScreen({
    super.key,
    required this.level,
    this.isDailyPuzzle = false,
    this.isViewOnly = false,
    this.initialPath,
    this.initialElapsedMs,
  });

  @override
  State<ZipGameplayScreen> createState() => _ZipGameplayScreenState();
}

class _ZipGameplayScreenState extends State<ZipGameplayScreen> {
  late LevelDefinition _currentLevel;
  bool _dialogShown = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _hasHandledCompletionFlow = false;

  DailySubmissionResult? _cachedDailyResult;
  bool? _cachedIsPersonalBest;
  bool? _cachedHasNext;
  LevelDefinition? _cachedNextLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    AnalyticsService.instance.track(AnalyticsEventName.gameStart, properties: {
      'game_id': 'zip_puzzle',
      'round_id': _currentLevel.levelNumber.toString(),
      'is_daily': widget.isDailyPuzzle,
    });
  }

  @override
  void dispose() {
    if (!_dialogShown && !widget.isViewOnly) {
      AnalyticsService.instance.track(AnalyticsEventName.gameIncomplete, properties: {
        'game_id': 'zip_puzzle',
        'round_id': _currentLevel.levelNumber.toString(),
        'reason': 'user_exit',
      });
    }
    AnalyticsService.instance.track(AnalyticsEventName.gameExit, properties: {
      'game_id': 'zip_puzzle',
      'round_id': _currentLevel.levelNumber.toString(),
    });
    super.dispose();
  }

  void _onLevelCompleted(ZipGameProvider game) async {
    if (_dialogShown) return;
    _dialogShown = true;

    DailySubmissionResult? dailyResult;
    if (widget.isDailyPuzzle) {
      try {
        final dailyProvider = context.read<DailyPuzzleProvider>();
        await dailyProvider.saveCompletedPath(game.currentPath);
        dailyResult = await dailyProvider.submitDailyCompletion(
          durationMs: game.elapsedMilliseconds,
          moves: game.currentPath.length,
        );

        final today = DateTime.now().toIso8601String().substring(0, 10);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('puzzle_completed_zip_$today', true);
      } catch (e) {
        debugPrint('Daily completion submit error: $e');
      }
    }

    AnalyticsService.instance.track(AnalyticsEventName.gameComplete, properties: {
      'game_id': 'zip_puzzle',
      'round_id': _currentLevel.levelNumber.toString(),
      'score': game.elapsedMilliseconds,
      'formatted_time': game.formattedTime,
    });

    if (dailyResult != null) {
      AnalyticsService.instance.track(AnalyticsEventName.gameScoreRecorded, properties: {
        'game_id': 'zip_puzzle',
        'score': game.elapsedMilliseconds,
        'rank': dailyResult.rank,
      });
    }

    final repo = ZipPuzzleRepository();
    final progress = await repo.getLevelProgress(_currentLevel.levelNumber);
    final isPersonalBest = progress.bestTimeMs == null ||
        game.elapsedMilliseconds <= progress.bestTimeMs!;

    if (!mounted) return;

    final catalog = context.read<ZipCatalogProvider>();
    final nextLevel = catalog.getNextLevel(_currentLevel);
    final hasNext = !widget.isDailyPuzzle && nextLevel != null;

    try {
      catalog.refreshProgressOnly();
    } catch (_) {}

    setState(() {
      _cachedDailyResult = dailyResult;
      _cachedIsPersonalBest = isPersonalBest;
      _cachedHasNext = hasNext;
      _cachedNextLevel = nextLevel;
    });

    // If it's a practice level (non-daily), show standard dialog
    if (!widget.isDailyPuzzle) {
      _showCompletionDialog(game);
    }
  }

  void _showCompletionDialog(ZipGameProvider game) {
    final catalog = context.read<ZipCatalogProvider>();
    final nextLevel = _cachedNextLevel ?? catalog.getNextLevel(_currentLevel);
    final hasNext = _cachedHasNext ?? (!widget.isDailyPuzzle && nextLevel != null);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return ZipCompletionDialog(
          levelNumber: _currentLevel.levelNumber,
          formattedTime: game.formattedTime,
          isPersonalBest: _cachedIsPersonalBest ?? true,
          hasNextLevel: hasNext,
          isDailyPuzzle: widget.isDailyPuzzle,
          dailyResult: _cachedDailyResult,
          onViewGame: () {
            Navigator.pop(dialogCtx);
          },
          onReturnHome: () {
            Navigator.pop(dialogCtx);
            if (widget.isDailyPuzzle) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZipLevelSelectionScreen(),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          onNextLevel: () async {
            Navigator.pop(dialogCtx);
            if (nextLevel != null) {
              final fullNext = await catalog.getOrFetchLevel(nextLevel);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ZipGameplayScreen(level: fullNext),
                ),
              );
            }
          },
          onReplay: () {
            Navigator.pop(dialogCtx);
            _dialogShown = false;
            _cachedDailyResult = null;
            game.reset();
          },
          onViewLeaderboard: () {
            Navigator.pop(dialogCtx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZipLeaderboardScreen(
                  initialLevel: _currentLevel.levelNumber,
                  totalLevels: catalog.totalLevels > 0 ? catalog.totalLevels : 100,
                  isDailyLeaderboard: widget.isDailyPuzzle,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _shareCurrentGame(ZipGameProvider game) async {
    final formattedTime = widget.isViewOnly && widget.initialElapsedMs != null
        ? '${(widget.initialElapsedMs! / 1000).toStringAsFixed(1)}s'
        : (game.currentPath.isNotEmpty ? game.formattedTime : null);

    XFile? screenshotXFile;
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 20),
      );
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imageFile = File('${directory.path}/zip_game_${DateTime.now().millisecondsSinceEpoch}.png');
        await imageFile.writeAsBytes(imageBytes);
        screenshotXFile = XFile(imageFile.path);
      }
    } catch (e) {
      debugPrint('Error capturing Zip screenshot: $e');
    }

    if (!mounted) return;
    await GameShareHelper.shareGame(
      context: context,
      gameSlug: 'zip',
      gameTitle: 'Zip Puzzle',
      formattedTime: formattedTime,
      rank: _cachedDailyResult?.rank,
      streak: _cachedDailyResult?.streak.currentStreak,
      screenshotFile: screenshotXFile,
    );
  }

  Future<void> _handleDoneOrBack(ZipGameProvider game, {required bool isDone}) async {
    final profileProvider = context.read<ProfileProvider>();
    final profile = await GameProfileManager.getUnifiedProfile(profileProvider: profileProvider);

    if (profile.hasValidName) {
      // User has ALREADY updated their name in profile or any game!
      // Navigate immediately with 0ms delay!
      _navigateAfterDoneOrBack();
      _fireBackgroundSync(game, displayName: profile.name, photoUrl: profile.photoUrl);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? 'guest';
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GameProfilePromptDialog(
          initialName: '',
          initialPhotoUrl: profile.photoUrl,
          userId: userId,
          onProfileSaved: (savedName, savedPhoto) async {
            _navigateAfterDoneOrBack();
            _fireBackgroundSync(
              game,
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
          builder: (_) => const ZipLevelSelectionScreen(),
        ),
      );
    }
  }

  void _fireBackgroundSync(
    ZipGameProvider game, {
    required String displayName,
    required String photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'guest';
    final duration = game.elapsedMilliseconds > 0
        ? game.elapsedMilliseconds
        : (widget.initialElapsedMs ?? 30000);

    try {
      GameProfileManager.saveUnifiedProfile(
        name: displayName,
        photoUrl: photoUrl,
      );
    } catch (_) {}

    PuzzleApiService.submitGame(
      gameSlug: 'zip',
      playerId: userId,
      durationMs: duration,
      score: 100,
      displayName: displayName,
      avatarUrl: photoUrl,
    ).catchError((e) {
      debugPrint('Error syncing Zip daily score: $e');
      return <String, dynamic>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider<ZipGameProvider>(
      create: (ctx) => ZipGameProvider(
        level: _currentLevel,
        onLevelCompleted: () {},
        isViewOnly: widget.isViewOnly,
        initialPath: widget.initialPath,
        initialElapsedMs: widget.initialElapsedMs,
      ),
      child: Consumer<ZipGameProvider>(
        builder: (context, game, child) {
          if (game.isCompleted && !_dialogShown && !widget.isViewOnly) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onLevelCompleted(game);
            });
          }

          final isUndoEnabled = game.currentPath.isNotEmpty && !game.isCompleted;
          final bool isFinished = game.isCompleted || widget.isViewOnly;
          final bool canDirectPop = (!widget.isDailyPuzzle || !isFinished) || _hasHandledCompletionFlow;

          return PopScope(
            canPop: canDirectPop,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              if (widget.isDailyPuzzle && isFinished && !_hasHandledCompletionFlow) {
                _handleDoneOrBack(game, isDone: false);
              } else {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
                elevation: 0,
                centerTitle: true,
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: InkWell(
                    onTap: () {
                      if (widget.isDailyPuzzle && isFinished && !_hasHandledCompletionFlow) {
                        _handleDoneOrBack(game, isDone: false);
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
                        'assets/images/zip_puzzle_3d_icon.png',
                        width: 22.w,
                        height: 22.w,
                        errorBuilder: (_, __, ___) => const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 20),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Zip Puzzle',
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
                  if (!isFinished)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
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
                                  game.formattedTime,
                                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          InkWell(
                            onTap: game.currentPath.isEmpty ? null : () => game.reset(),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2024) : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF33363D) : const Color(0xFFD1D5DB),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: game.currentPath.isEmpty
                                      ? (isDark ? const Color(0xFF555555) : const Color(0xFF9CA3AF))
                                      : (isDark ? Colors.white : const Color(0xFF111827)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
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
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      // Level info and checkpoint counter
                      Padding(
                        padding: EdgeInsets.only(top: 2.h, bottom: 6.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (widget.isDailyPuzzle) ...[
                                  const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 18),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Daily Puzzle',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'Zip Puzzle',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                ],
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: game.pathColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    _currentLevel.difficulty.displayName,
                                    style: TextStyle(
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: game.pathColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_currentLevel.checkpoints.length} checkpoints',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status / Feedback message area
                      SizedBox(
                        height: 34.h,
                        child: Center(
                          child: game.feedbackMessage != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 16),
                                      SizedBox(width: 6.w),
                                      Text(
                                        game.feedbackMessage!,
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // Game Board (Center Stage wrapped in Screenshot)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Screenshot(
                              controller: _screenshotController,
                              child: const ZipBoardWidget(),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Bottom actions: Completed banner OR Undo/Hint controls
                      if (isFinished)
                        _buildCompletedBanner(context, game, isDark)
                      else ...[
                        Row(
                          children: [
                            // Undo Pill Button
                            Expanded(
                              child: InkWell(
                                onTap: isUndoEnabled ? () => game.undo() : null,
                                borderRadius: BorderRadius.circular(24.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: isUndoEnabled
                                        ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                                        : (isDark ? const Color(0xFF181A1D) : const Color(0xFFECEEF1)),
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: isUndoEnabled
                                        ? Border.all(
                                            color: isDark ? const Color(0xFF33363D) : const Color(0xFFD1D5DB),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Undo',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isUndoEnabled
                                            ? (isDark ? Colors.white : const Color(0xFF111827))
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Hint Pill Button
                            Expanded(
                              child: InkWell(
                                onTap: game.isCompleted
                                    ? null
                                    : () async {
                                        if (game.remainingHints <= 0) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Daily hint limit reached (3/3). Come back tomorrow!'),
                                              behavior: SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        game.hint();
                                      },
                                borderRadius: BorderRadius.circular(24.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: game.canUseHint
                                        ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                                        : (isDark ? const Color(0xFF181A1D) : const Color(0xFFECEEF1)),
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: game.canUseHint
                                        ? Border.all(
                                            color: isDark ? const Color(0xFF33363D) : const Color(0xFFD1D5DB),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Hint',
                                          style: TextStyle(
                                            fontSize: 14.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: game.canUseHint
                                                ? (isDark ? Colors.white : const Color(0xFF111827))
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '(${game.remainingHints})',
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: game.canUseHint ? game.pathColor : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        ZipHowToPlayCard(pathColor: game.pathColor),
                        SizedBox(height: 10.h),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletedBanner(BuildContext context, ZipGameProvider game, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
                    widget.isDailyPuzzle
                        ? 'You have completed today\'s Zip puzzle!'
                        : 'Puzzle Completed!',
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
                  onPressed: () => _shareCurrentGame(game),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    if (widget.isDailyPuzzle) {
                      _handleDoneOrBack(game, isDone: true);
                    } else {
                      _showCompletionDialog(game);
                    }
                  },
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
                  onPressed: () {
                    if (widget.isDailyPuzzle) {
                      _handleDoneOrBack(game, isDone: false);
                    } else {
                      Navigator.pop(context);
                    }
                  },
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
                        builder: (_) => const ZipLevelSelectionScreen(),
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
}
