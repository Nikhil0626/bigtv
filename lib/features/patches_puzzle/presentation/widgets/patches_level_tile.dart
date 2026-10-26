import 'package:flutter/material.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import '../../data/models/patches_level_definition.dart';
import '../../data/models/patches_level_progress.dart';

class PatchesLevelTile extends StatelessWidget {
  final PatchesLevelDefinition level;
  final PatchesLevelProgress progress;
  final VoidCallback onTap;

  const PatchesLevelTile({
    super.key,
    required this.level,
    required this.progress,
    required this.onTap,
  });

  Color _getDifficultyColor(ZipDifficulty difficulty) {
    switch (difficulty) {
      case ZipDifficulty.easy:
        return const Color(0xFF10B981);
      case ZipDifficulty.medium:
        return const Color(0xFF3B82F6);
      case ZipDifficulty.hard:
        return const Color(0xFFF59E0B);
      case ZipDifficulty.expert:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = progress.isUnlocked;
    final isCompleted = progress.isCompleted;
    final diffColor = _getDifficultyColor(level.difficulty);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
              : (isDark ? const Color(0xFF141414) : const Color(0xFFF1F1F4)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColorTokens.success.withValues(alpha: 0.6)
                : (isUnlocked
                    ? (isDark
                        ? const Color(0xFF333333)
                        : const Color(0xFFE2E4E9))
                    : (isDark
                        ? const Color(0xFF222222)
                        : const Color(0xFFE5E7EB))),
            width: isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: Level number + difficulty dot/badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${level.levelNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF1F2937))
                        : (isDark
                            ? const Color(0xFF555555)
                            : const Color(0xFF9CA3AF)),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color:
                        diffColor.withValues(alpha: isUnlocked ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    level.difficulty.displayName[0],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? diffColor : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),

            // Middle: status icon
            if (!isUnlocked)
              const Icon(
                Icons.lock_rounded,
                size: 20,
                color: Color(0xFF9CA3AF),
              )
            else if (isCompleted)
              const Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: AppColorTokens.success,
              )
            else
              Text(
                '${level.rows}x${level.cols}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF6B7280),
                ),
              ),

            // Bottom: Best time or Clue count
            if (isCompleted && progress.formattedBestTime != null)
              Text(
                progress.formattedBestTime!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColorTokens.success,
                ),
              )
            else
              Text(
                '${level.clues.length} clues',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? const Color(0xFF777777)
                      : const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
