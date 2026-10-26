import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../services/game_share_helper.dart';

class PatchCompletionDialog extends StatelessWidget {
  final String formattedTime;
  final int rank;
  final int streak;
  final VoidCallback onViewGame;
  final VoidCallback onDashboard;
  final VoidCallback? onReplay;
  final VoidCallback? onViewLeaderboard;

  const PatchCompletionDialog({
    super.key,
    required this.formattedTime,
    required this.rank,
    required this.streak,
    required this.onViewGame,
    required this.onDashboard,
    this.onReplay,
    this.onViewLeaderboard,
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
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber.shade700,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  "Today's Patch Solved!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),

                // Daily Puzzle Badges (Rank + Streak)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF382312), const Color(0xFF241912)]
                          : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.shade400.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.leaderboard_rounded,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Rank #$rank',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.amber.shade300,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: Colors.deepOrange, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$streak Day Streak',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Elapsed time container
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282828) : const Color(0xFFF3F4F6),
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      GameShareHelper.shareGame(
                        context: context,
                        gameSlug: 'patch',
                        gameTitle: 'Patch Puzzle',
                        formattedTime: formattedTime,
                        rank: rank,
                        streak: streak,
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF10B981)),
                    label: const Text(
                      'Share My Score',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                if (onViewLeaderboard != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewLeaderboard,
                      icon: const Icon(Icons.leaderboard_rounded, color: Colors.white),
                      label: const Text(
                        "Today's Leaderboard",
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
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewGame,
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('View Game'),
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
                        onPressed: onDashboard,
                        icon: const Icon(Icons.dashboard_rounded, size: 18),
                        label: const Text('Dashboard'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                if (onReplay != null) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: onReplay,
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Replay Puzzle', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
