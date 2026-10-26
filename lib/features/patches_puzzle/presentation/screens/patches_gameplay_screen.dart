import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/patches_level_definition.dart';
import '../../data/repositories/patches_catalog.dart';
import '../../data/repositories/patches_puzzle_repository.dart';
import '../providers/patches_catalog_provider.dart';
import '../providers/patches_game_provider.dart';
import '../widgets/patches_board_widget.dart';
import '../widgets/patches_completion_dialog.dart';
import '../widgets/patches_how_to_play_card.dart';
import 'patches_leaderboard_screen.dart';

class PatchesGameplayScreen extends StatefulWidget {
  final PatchesLevelDefinition level;

  const PatchesGameplayScreen({super.key, required this.level});

  @override
  State<PatchesGameplayScreen> createState() => _PatchesGameplayScreenState();
}

class _PatchesGameplayScreenState extends State<PatchesGameplayScreen> {
  late PatchesLevelDefinition _currentLevel;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
  }

  void _onLevelCompleted(PatchesGameProvider game) async {
    if (_dialogShown) return;
    _dialogShown = true;

    final repo = PatchesPuzzleRepository();
    final progress = await repo.getLevelProgress(_currentLevel.levelNumber);
    final isPersonalBest = progress.bestTimeMs == null ||
        game.elapsedMilliseconds <= progress.bestTimeMs!;
    final hasNext = _currentLevel.levelNumber < PatchesCatalog.totalLevels;

    if (!mounted) return;

    try {
      context.read<PatchesCatalogProvider>().refresh();
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PatchesCompletionDialog(
          levelNumber: _currentLevel.levelNumber,
          formattedTime: game.formattedTime,
          isPersonalBest: isPersonalBest,
          hasNextLevel: hasNext,
          onNextLevel: () {
            Navigator.pop(dialogCtx);
            if (hasNext) {
              final nextLevel =
                  PatchesCatalog.getLevel(_currentLevel.levelNumber + 1);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PatchesGameplayScreen(level: nextLevel),
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
                builder: (context) => PatchesLeaderboardScreen(
                  initialLevel: _currentLevel.levelNumber,
                ),
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

    return ChangeNotifierProvider<PatchesGameProvider>(
      create: (ctx) => PatchesGameProvider(
        level: _currentLevel,
        onLevelCompleted: () {},
      ),
      child: Consumer<PatchesGameProvider>(
        builder: (context, game, child) {
          if (game.isCompleted && !_dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onLevelCompleted(game);
            });
          }

          final isUndoEnabled =
              game.placedPatches.isNotEmpty && !game.isCompleted;

          return Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Top Bar matching user screenshot: ⏱ 1:36 | Difficulty HARD | Reset
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Back Button + Timer
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF111827),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                game.formattedTime,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),

                          // Center: Difficulty Capsule (Matching user screenshot: Difficulty HARD)
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF22252A)
                                        : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Difficulty ${_currentLevel.difficulty.displayName.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFD1D5DB)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Right: Reset Button matching LinkedIn style capsule
                          InkWell(
                            onTap: game.placedPatches.isEmpty
                                ? null
                                : () => game.reset(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2024)
                                    : Colors.white,
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
                                  color: game.placedPatches.isEmpty
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Game Board (Center Stage)
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: PatchesBoardWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Undo and Hint Pill Buttons Row (Matches Screenshot)
                    Row(
                      children: [
                        // Undo Pill Button
                        Expanded(
                          child: InkWell(
                            onTap: isUndoEnabled ? () => game.undo() : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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

                        // Hint Pill Button (with 3 hints/day limit)
                        Expanded(
                          child: InkWell(
                            onTap: game.isCompleted
                                ? null
                                : () {
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                                            ? const Color(0xFFE53935)
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

                    // "How to play" Collapsible Card (Matches Screenshot)
                    const PatchesHowToPlayCard(),

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
