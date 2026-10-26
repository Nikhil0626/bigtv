import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
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
        'rank': dailyResult.rank ?? 1,
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

    // Refresh catalog provider in background
    try {
      catalog.refreshProgressOnly();
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return ZipCompletionDialog(
          levelNumber: _currentLevel.levelNumber,
          formattedTime: game.formattedTime,
          isPersonalBest: isPersonalBest,
          hasNextLevel: hasNext,
          isDailyPuzzle: widget.isDailyPuzzle,
          dailyResult: dailyResult,
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
            game.reset();
          },
          onViewLeaderboard: () {
            Navigator.pop(dialogCtx);
            if (widget.isDailyPuzzle) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZipLevelSelectionScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZipLeaderboardScreen(
                    initialLevel: _currentLevel.levelNumber,
                    totalLevels:
                        catalog.totalLevels > 0 ? catalog.totalLevels : 100,
                    isDailyLeaderboard: widget.isDailyPuzzle,
                  ),
                ),
              );
            }
          },
        );
      },
    );
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

          final isUndoEnabled =
              game.currentPath.isNotEmpty && !game.isCompleted;

          return PopScope(
            canPop: !(widget.isDailyPuzzle && game.isCompleted && !widget.isViewOnly),
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (widget.isDailyPuzzle && game.isCompleted && !widget.isViewOnly) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ZipLevelSelectionScreen()),
                );
              }
            },
            child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
            appBar: AppBar(
              backgroundColor:
                  isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                onPressed: () {
                  if (widget.isDailyPuzzle && game.isCompleted && !widget.isViewOnly) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ZipLevelSelectionScreen(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              titleSpacing: 0,
              title: widget.isViewOnly
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.initialElapsedMs != null
                              ? 'Solved in ${(widget.initialElapsedMs! / 1000).toStringAsFixed(2)}s'
                              : 'Completed Solution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF111827),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          game.formattedTime,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
              actions: [
                if (widget.isViewOnly)
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
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Reset Button matching LinkedIn style capsule
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: InkWell(
                        onTap:
                            game.currentPath.isEmpty ? null : () => game.reset(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E2024) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF33363D)
                                  : const Color(0xFFD1D5DB),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: game.currentPath.isEmpty
                                  ? (isDark
                                      ? const Color(0xFF555555)
                                      : const Color(0xFF9CA3AF))
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF111827)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Level info and checkpoint counter
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (widget.isDailyPuzzle) ...[
                                const Icon(Icons.local_fire_department_rounded,
                                    color: Colors.deepOrange, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  'Daily Puzzle',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Level ${_currentLevel.levelNumber}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: game.pathColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _currentLevel.difficulty.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF9E9E9E)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status / Feedback message area (fixed height ensures no board resizing or touch jumps)
                    SizedBox(
                      height: 36,
                      child: Center(
                        child: game.feedbackMessage != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF3B1E1E)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.5),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      game.feedbackMessage!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),

                    // Game Board (Center Stage)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const ZipBoardWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (widget.isViewOnly) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2024) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.green, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Your Solved Trace',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'All ${_currentLevel.checkpoints.length} checkpoints connected sequentially.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorTokens.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Dashboard'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      // Undo and Hint Pill Buttons Row (Matches Screenshot 1 & 2)
                      Row(
                        children: [
                          // Undo Pill Button
                          Expanded(
                            child: InkWell(
                              onTap: isUndoEnabled ? () => game.undo() : null,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isUndoEnabled
                                      ? (isDark
                                          ? const Color(0xFF1E2024)
                                          : Colors.white)
                                      : (isDark
                                          ? const Color(0xFF181A1D)
                                          : const Color(0xFFECEEF1)),
                                  borderRadius: BorderRadius.circular(24),
                                  border: isUndoEnabled
                                      ? Border.all(
                                          color: isDark
                                              ? const Color(0xFF33363D)
                                              : const Color(0xFFD1D5DB),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Undo',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isUndoEnabled
                                          ? (isDark
                                              ? Colors.white
                                              : const Color(0xFF111827))
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Hint Pill Button (3 daily hints limit)
                          Expanded(
                            child: InkWell(
                              onTap: game.isCompleted
                                  ? null
                                  : () async {
                                      if (game.remainingHints <= 0) {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Daily hint limit reached (3/3). Come back tomorrow!'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }
                                      game.hint();
                                    },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: game.canUseHint
                                      ? (isDark
                                          ? const Color(0xFF1E2024)
                                          : Colors.white)
                                      : (isDark
                                          ? const Color(0xFF181A1D)
                                          : const Color(0xFFECEEF1)),
                                  borderRadius: BorderRadius.circular(24),
                                  border: game.canUseHint
                                      ? Border.all(
                                          color: isDark
                                              ? const Color(0xFF33363D)
                                              : const Color(0xFFD1D5DB),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: game.canUseHint
                                              ? (isDark
                                                  ? Colors.white
                                                  : const Color(0xFF111827))
                                              : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${game.remainingHints})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: game.canUseHint
                                              ? game.pathColor
                                              : const Color(0xFF9CA3AF),
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

                      const SizedBox(height: 16),

                      // "How to play" Collapsible Card (Matches Screenshot 1 & 2)
                      ZipHowToPlayCard(pathColor: game.pathColor),

                      const SizedBox(height: 12),
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
}
