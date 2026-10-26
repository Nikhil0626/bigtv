import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../services/game_share_helper.dart';

class PatchesCompletionDialog extends StatelessWidget {
  final int levelNumber;
  final String formattedTime;
  final bool isPersonalBest;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onViewLeaderboard;

  const PatchesCompletionDialog({
    super.key,
    required this.levelNumber,
    required this.formattedTime,
    required this.isPersonalBest,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onReplay,
    required this.onViewLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        children: [
          // BigTV Watermark in top-right corner
          Positioned(
            top: 16,
            right: 16,
            child: Opacity(
              opacity: isDark ? 0.75 : 0.9,
              child: Image.asset(
                'assets/images/BigTvPostLogo.png',
                height: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorTokens.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColorTokens.warning,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Level $levelNumber Solved!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),

                // Elapsed time container
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282828)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Time Taken',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColorTokens.primaryRed,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (isPersonalBest) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColorTokens.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: AppColorTokens.success, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'NEW BEST TIME!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorTokens.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Share Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      GameShareHelper.shareGame(
                        context: context,
                        gameSlug: 'patch',
                        gameTitle: 'Patch Puzzle Level $levelNumber',
                        formattedTime: formattedTime,
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF10B981)),
                    label: const Text(
                      'Share My Score',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Action Buttons
                if (hasNextLevel)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onNextLevel,
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                      label: const Text(
                        'Next Level',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReplay,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Replay'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewLeaderboard,
                        icon: const Icon(Icons.leaderboard_rounded, size: 18),
                        label: const Text('Ranks'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // BigTV Branding Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: isDark ? 0.6 : 0.8,
                      child: Image.asset(
                        'assets/images/BigTvPostLogo.png',
                        height: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
