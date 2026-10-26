import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/sudoku_level_definition.dart';
import '../../data/repositories/sudoku_catalog.dart';
import '../../data/repositories/sudoku_puzzle_repository.dart';
import '../providers/sudoku_catalog_provider.dart';
import '../providers/sudoku_game_provider.dart';
import '../widgets/sudoku_board_widget.dart';
import '../widgets/sudoku_completion_dialog.dart';
import '../widgets/sudoku_how_to_play_card.dart';
import '../widgets/sudoku_number_pad.dart';
import 'sudoku_leaderboard_screen.dart';

class SudokuGameplayScreen extends StatefulWidget {
  final SudokuLevelDefinition level;

  const SudokuGameplayScreen({super.key, required this.level});

  @override
  State<SudokuGameplayScreen> createState() => _SudokuGameplayScreenState();
}

class _SudokuGameplayScreenState extends State<SudokuGameplayScreen> {
  late SudokuLevelDefinition _currentLevel;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
  }

  void _onLevelCompleted(SudokuGameProvider game) async {
    if (_dialogShown) return;
    _dialogShown = true;

    final repo = SudokuPuzzleRepository();
    final progress = await repo.getLevelProgress(_currentLevel.levelNumber);
    final isPersonalBest = progress.bestTimeMs == null ||
        game.elapsedMilliseconds <= progress.bestTimeMs!;
    final hasNext = _currentLevel.levelNumber < SudokuCatalog.totalLevels;

    if (!mounted) return;

    try {
      context.read<SudokuCatalogProvider>().refresh();
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return SudokuCompletionDialog(
          levelNumber: _currentLevel.levelNumber,
          formattedTime: game.formattedTime,
          isPersonalBest: isPersonalBest,
          hasNextLevel: hasNext,
          onNextLevel: () {
            Navigator.pop(dialogCtx);
            if (hasNext) {
              final nextLevel =
                  SudokuCatalog.getLevel(_currentLevel.levelNumber + 1);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SudokuGameplayScreen(level: nextLevel),
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
                builder: (context) => SudokuLeaderboardScreen(
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

    return ChangeNotifierProvider<SudokuGameProvider>(
      create: (ctx) => SudokuGameProvider(
        level: _currentLevel,
        onLevelCompleted: () {},
      ),
      child: Consumer<SudokuGameProvider>(
        builder: (context, game, child) {
          if (game.isCompleted && !_dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onLevelCompleted(game);
            });
          }

          final selected = game.selectedCell;
          final isEraseEnabled =
              selected != null && !selected.isGiven && (selected.value != 0 || selected.notes.isNotEmpty);

          return Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    // Top Bar: ⏱ Timer | Difficulty Capsule | Reset
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Back Arrow + Timer
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

                          // Center: Difficulty Capsule
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

                          // Right: Reset Button
                          InkWell(
                            onTap: !game.hasStarted ? null : () => game.reset(),
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
                                  color: !game.hasStarted
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

                    const SizedBox(height: 4),

                    // Game Board (Center Stage)
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: SudokuBoardWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quick Actions Row: Undo | Erase | Notes | Hint
                    Row(
                      children: [
                        // Undo
                        _buildActionPill(
                          context: context,
                          label: 'Undo',
                          icon: Icons.undo_rounded,
                          isEnabled: game.canUndo,
                          isActive: false,
                          isDark: isDark,
                          onTap: game.canUndo ? () => game.undo() : null,
                        ),
                        const SizedBox(width: 8),

                        // Erase
                        _buildActionPill(
                          context: context,
                          label: 'Erase',
                          icon: Icons.backspace_outlined,
                          isEnabled: isEraseEnabled,
                          isActive: false,
                          isDark: isDark,
                          onTap: isEraseEnabled ? () => game.erase() : null,
                        ),
                        const SizedBox(width: 8),

                        // Notes Toggle
                        _buildActionPill(
                          context: context,
                          label: game.isNoteMode ? 'Notes ON' : 'Notes',
                          icon: Icons.edit_note_rounded,
                          isEnabled: true,
                          isActive: game.isNoteMode,
                          isDark: isDark,
                          onTap: () => game.toggleNoteMode(),
                        ),
                        const SizedBox(width: 8),

                        // Hint (with daily 3 hints limit)
                        _buildActionPill(
                          context: context,
                          label: 'Hint (${game.remainingHints})',
                          icon: Icons.lightbulb_outline_rounded,
                          isEnabled: game.canUseHint,
                          isActive: false,
                          isDark: isDark,
                          onTap: () {
                            if (game.remainingHints <= 0) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Number Pad 1-9
                    const SudokuNumberPad(),

                    const SizedBox(height: 10),

                    // Collapsible "How to play" Card
                    const SudokuHowToPlayCard(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionPill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isEnabled,
    required bool isActive,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    Color bg;
    Color border;
    Color text;

    if (isActive) {
      bg = isDark
          ? const Color(0xFF1E3A8A)
          : const Color(0xFFEFF6FF);
      border = const Color(0xFF2563EB);
      text = isDark ? Colors.white : const Color(0xFF1D4ED8);
    } else if (isEnabled) {
      bg = isDark ? const Color(0xFF1E2024) : Colors.white;
      border = isDark ? const Color(0xFF33363D) : const Color(0xFFD1D5DB);
      text = isDark ? Colors.white : const Color(0xFF111827);
    } else {
      bg = isDark ? const Color(0xFF181A1D) : const Color(0xFFECEEF1);
      border = Colors.transparent;
      text = const Color(0xFF9CA3AF);
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: text),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
