import 'package:flutter/material.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import '../../data/models/sudoku_level_definition.dart';
import '../../data/models/sudoku_level_progress.dart';

class SudokuLevelTile extends StatelessWidget {
  final SudokuLevelDefinition level;
  final SudokuLevelProgress progress;
  final VoidCallback? onTap;

  const SudokuLevelTile({
    super.key,
    required this.level,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = progress.isUnlocked;
    final isCompleted = progress.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isDark ? const Color(0xFF1E2024) : Colors.white)
                : (isDark ? const Color(0xFF16181B) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : (isUnlocked
                      ? (isDark
                          ? const Color(0xFF33363D)
                          : const Color(0xFFE5E7EB))
                      : (isDark
                          ? const Color(0xFF23262D)
                          : const Color(0xFFE5E7EB))),
              width: isCompleted ? 1.5 : 1.0,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Level number + Lock/Check icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${level.levelNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? (isDark ? Colors.white : const Color(0xFF111827))
                          : (isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF)),
                    ),
                  ),
                  if (!isUnlocked)
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    )
                  else if (isCompleted)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                ],
              ),

              // Center: Difficulty Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? level.difficulty.accentColor.withValues(alpha: 0.12)
                      : (isDark
                          ? const Color(0xFF23262D)
                          : const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  level.difficulty.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? level.difficulty.accentColor
                        : (isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF)),
                  ),
                ),
              ),

              // Bottom: Star ratings or Givens count
              if (isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final isEarned = i < progress.stars;
                    return Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: isEarned
                          ? const Color(0xFFF59E0B)
                          : (isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFD1D5DB)),
                    );
                  }),
                )
              else
                Text(
                  '${level.givensCount} givens',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
