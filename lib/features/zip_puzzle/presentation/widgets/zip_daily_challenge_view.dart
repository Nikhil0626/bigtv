import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/models/daily_puzzle_models.dart';
import '../providers/daily_puzzle_provider.dart';
import '../screens/zip_gameplay_screen.dart';
import '../screens/zip_leaderboard_screen.dart';
import 'zip_daily_streak_card.dart';
import '../../../../services/game_share_helper.dart';

class ZipDailyChallengeView extends StatelessWidget {
  const ZipDailyChallengeView({super.key});

  void _viewCompletedGame(BuildContext context, DailyPuzzleProvider dailyProvider) async {
    final level = dailyProvider.todayLevelDefinition;
    if (level == null) return;

    final path = await dailyProvider.getCompletedPath();
    final solveTimeMs = dailyProvider.lastSubmissionResult?.durationMs;

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZipGameplayScreen(
          level: level,
          isDailyPuzzle: true,
          isViewOnly: true,
          initialPath: path.isNotEmpty ? path : level.solutionPath,
          initialElapsedMs: solveTimeMs,
        ),
      ),
    );
  }

  void _playDailyPuzzle(BuildContext context, DailyPuzzleProvider dailyProvider) async {
    final level = dailyProvider.todayLevelDefinition;
    if (level == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading today\'s puzzle... Please try again in a moment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      dailyProvider.loadTodayGame();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZipGameplayScreen(
          level: level,
          isDailyPuzzle: true,
        ),
      ),
    );

    // Refresh streak calendar after gameplay
    dailyProvider.loadStreakCalendar();
    dailyProvider.loadTodayLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyProvider = context.watch<DailyPuzzleProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          dailyProvider.loadTodayGame(),
          dailyProvider.loadStreakCalendar(),
          dailyProvider.loadTodayLeaderboard(),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 1. 7-Day Streak Calendar Card
          const ZipDailyStreakCard(),

          // 2. Today's Puzzle Hero Card
          _buildTodayHeroCard(context, dailyProvider, isDark),

          // 3. Today's Leaderboard Preview Card
          _buildLeaderboardPreview(context, dailyProvider, isDark),
        ],
      ),
    );
  }

  Widget _buildTodayHeroCard(
    BuildContext context,
    DailyPuzzleProvider dailyProvider,
    bool isDark,
  ) {
    final todayData = dailyProvider.todayPuzzle;
    final isCompleted = dailyProvider.isTodayCompleted;
    final lastResult = dailyProvider.lastSubmissionResult;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.15)
                          : AppColorTokens.primaryRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.bolt_rounded,
                          size: 14,
                          color: isCompleted
                              ? Colors.green
                              : AppColorTokens.primaryRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'COMPLETED' : 'TODAY\'S PUZZLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green
                                : AppColorTokens.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                todayData?.puzzleDate ?? 'Daily',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            todayData?.title ?? 'Daily Puzzle Challenge',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Connect all checkpoints sequentially without overlapping or hitting walls. Compete on today\'s speed leaderboard!',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Details chips (Grid info, checkpoints, difficulty) - Wrap to prevent overflow
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildFeatureBadge(
                Icons.grid_4x4_rounded,
                '${todayData?.rows ?? 4}x${todayData?.columns ?? 4} Grid',
                isDark,
              ),
              _buildFeatureBadge(
                Icons.flag_rounded,
                '${todayData?.checkpointsCount ?? 4} Checkpoints',
                isDark,
              ),
              _buildFeatureBadge(
                Icons.speed_rounded,
                (todayData?.difficulty ?? 'easy').toUpperCase(),
                isDark,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action Button
          if (isCompleted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lastResult != null
                          ? 'Solved in ${lastResult.durationMs / 1000}s! Rank #${lastResult.rank}'
                          : 'You solved today\'s puzzle!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewCompletedGame(context, dailyProvider),
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('View Game'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColorTokens.primaryRed,
                      side: const BorderSide(color: AppColorTokens.primaryRed, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ZipLeaderboardScreen(
                            isDailyLeaderboard: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.leaderboard_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorTokens.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  GameShareHelper.shareGame(
                    context: context,
                    gameSlug: 'zip',
                    gameTitle: 'Zip Puzzle',
                    formattedTime: lastResult != null ? '${(lastResult.durationMs / 1000).toStringAsFixed(1)}s' : null,
                    rank: lastResult?.rank,
                    streak: lastResult?.streak.currentStreak,
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
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _playDailyPuzzle(context, dailyProvider),
                icon: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 24),
                label: const Text(
                  'PLAY TODAY\'S PUZZLE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorTokens.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(
    IconData icon,
    String label,
    bool isDark, {
    Color? color,
  }) {
    final c = color ?? (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6B7280));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282828) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPreview(
    BuildContext context,
    DailyPuzzleProvider dailyProvider,
    bool isDark,
  ) {
    final lb = dailyProvider.dailyLeaderboard;
    final entries = lb?.entries.take(3).toList() ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Speed Leaders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF282828) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entries.length} ${entries.length == 1 ? 'Player' : 'Players'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_esports_rounded,
                      size: 30,
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No scores submitted yet today.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Be the first to claim #1 on the leaderboard!',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: entries.length > 5 ? 270 : (entries.length * 48.0 + 8.0),
              ),
              child: Scrollbar(
                thumbVisibility: entries.length > 3,
                radius: const Radius.circular(8),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final user = entries[index];
                    return _buildLeaderboardRow(user, isDark);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(DailyLeaderboardUser user, bool isDark) {
    Color rankColor;
    if (user.rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (user.rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (user.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${user.rank}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            user.formattedTime,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
              color: AppColorTokens.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}
