import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/level_definition.dart';
import '../../data/repositories/zip_catalog.dart';
import '../../data/repositories/zip_puzzle_repository.dart';
import '../providers/zip_catalog_provider.dart';
import '../providers/zip_game_provider.dart';
import '../widgets/zip_board_widget.dart';
import '../widgets/zip_completion_dialog.dart';
import '../widgets/zip_how_to_play_card.dart';
import 'zip_leaderboard_screen.dart';

class ZipGameplayScreen extends StatefulWidget {
  final LevelDefinition level;

  const ZipGameplayScreen({super.key, required this.level});

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
  }

  void _onLevelCompleted(ZipGameProvider game) async {
    if (_dialogShown) return;
    _dialogShown = true;

    final repo = ZipPuzzleRepository();
    final progress = await repo.getLevelProgress(_currentLevel.levelNumber);
    final isPersonalBest = progress.bestTimeMs == null ||
        game.elapsedMilliseconds <= progress.bestTimeMs!;
    final hasNext = _currentLevel.levelNumber < ZipCatalog.totalLevels;

    if (!mounted) return;

    // Refresh catalog provider in background
    try {
      context.read<ZipCatalogProvider>().refresh();
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
          onNextLevel: () {
            Navigator.pop(dialogCtx);
            if (hasNext) {
              final nextLevel =
                  ZipCatalog.getLevel(_currentLevel.levelNumber + 1);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ZipGameplayScreen(level: nextLevel),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZipLeaderboardScreen(
                    initialLevel: _currentLevel.levelNumber),
              ),
            );
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
      ),
      child: Consumer<ZipGameProvider>(
        builder: (context, game, child) {
          if (game.isCompleted && !_dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onLevelCompleted(game);
            });
          }

          final isUndoEnabled = game.currentPath.isNotEmpty && !game.isCompleted;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: Row(
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
                // Reset Button matching LinkedIn style capsule
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: InkWell(
                      onTap: game.currentPath.isEmpty ? null : () => game.reset(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2024) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF33363D) : const Color(0xFFD1D5DB),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: game.currentPath.isEmpty
                                ? (isDark ? const Color(0xFF555555) : const Color(0xFF9CA3AF))
                                : (isDark ? Colors.white : const Color(0xFF111827)),
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
                              Text(
                                'Level ${_currentLevel.levelNumber}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Game Board (Center Stage)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const ZipBoardWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                                    ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                                    : (isDark ? const Color(0xFF181A1D) : const Color(0xFFECEEF1)),
                                borderRadius: BorderRadius.circular(24),
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
                                    fontSize: 15,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
