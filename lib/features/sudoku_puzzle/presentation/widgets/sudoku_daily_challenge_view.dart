import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../zip_puzzle/data/models/daily_puzzle_models.dart';
import '../../../zip_puzzle/presentation/providers/daily_puzzle_provider.dart';
import '../../../zip_puzzle/presentation/widgets/zip_daily_streak_card.dart';
import '../screens/sudoku_game_screen.dart';
import '../../../../services/game_share_helper.dart';

class SudokuDailyChallengeView extends StatelessWidget {
  final String playerId;
  final ScrollController? scrollController;

  const SudokuDailyChallengeView({
    super.key,
    required this.playerId,
    this.scrollController,
  });

  void _viewCompletedGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuGameScreen(
          playerId: playerId,
          isViewOnly: true,
        ),
      ),
    );
  }

  void _playDailyPuzzle(BuildContext context, DailyPuzzleProvider dailyProvider) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuGameScreen(
          playerId: playerId,
        ),
      ),
    );

    // Refresh streak calendar and leaderboard after gameplay
    dailyProvider.loadStreakCalendar();
    dailyProvider.loadTodayLeaderboard(limit: 100);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyProvider = context.watch<DailyPuzzleProvider>();

    return RefreshIndicator(
      color: const Color(0xFFE50914),
      onRefresh: () async {
        await Future.wait([
          dailyProvider.loadTodayGame(),
          dailyProvider.loadStreakCalendar(),
          dailyProvider.loadTodayLeaderboard(limit: 100),
        ]);
      },
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // 1. Gamified 7-Day Streak & Rewards Card
          const ZipDailyStreakCard(),

          SizedBox(height: 6.h),

          // 2. Today's Sudoku Hero Challenge Card
          _buildTodayHeroCard(context, dailyProvider, isDark),

          SizedBox(height: 6.h),

          // 3. Today's Speed Leaders Dedicated Scroll View
          _buildSpeedLeadersCard(context, dailyProvider, isDark),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. Today's Hero Challenge Card
  // -------------------------------------------------------------
  Widget _buildTodayHeroCard(
    BuildContext context,
    DailyPuzzleProvider dailyProvider,
    bool isDark,
  ) {
    final todayData = dailyProvider.todayPuzzle;
    final isCompleted = dailyProvider.isTodayCompleted;
    final lastResult = dailyProvider.lastSubmissionResult;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF181C26), const Color(0xFF13151D)]
              : [Colors.white, const Color(0xFFF9FAFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF2A3144) : const Color(0xFFE2E8F0)),
          width: isCompleted ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Status badge + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.5.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFE50914).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.45)
                        : const Color(0xFFE50914).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.bolt_rounded,
                      size: 14.sp,
                      color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE50914),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isCompleted ? 'COMPLETED' : 'TODAY\'S CHALLENGE',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE50914),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12.sp,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    todayData?.puzzleDate.isNotEmpty == true ? todayData!.puzzleDate : '2026-10-27',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Title: Sudoku Puzzle + Arcade Badge
          Row(
            children: [
              Text(
                'Sudoku Puzzle',
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'SUDOKU MASTER',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Game description
          Text(
            'Fill each row, column, and block with unique digits without duplicates. Beat the clock and climb the speed leaderboard!',
            style: TextStyle(
              fontSize: 12.5.sp,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),

          // Feature chips using Wrap to eliminate overflow
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildFeatureBadge(
                Icons.grid_4x4_rounded,
                '${todayData?.rows ?? 9}x${todayData?.columns ?? 9} Grid',
                isDark,
              ),
              _buildFeatureBadge(
                Icons.extension_rounded,
                'Classic Sudoku',
                isDark,
              ),
              _buildFeatureBadge(
                Icons.speed_rounded,
                (todayData?.difficulty ?? 'medium').toUpperCase(),
                isDark,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Action Area: Completed celebration banner vs Play button
          if (isCompleted) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0D3222), const Color(0xFF13231B)]
                      : [const Color(0xFFE8FDF3), const Color(0xFFD1FAE5)],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      lastResult != null
                          ? 'Solved in ${(lastResult.durationMs / 1000).toStringAsFixed(1)}s! Rank #${lastResult.rank}'
                          : 'You solved today\'s Sudoku puzzle!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewCompletedGame(context),
                icon: Icon(Icons.visibility_rounded, size: 18.sp, color: Colors.white),
                label: Text(
                  'VIEW SOLVED GAME',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFFE50914).withValues(alpha: 0.35),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  GameShareHelper.shareGame(
                    context: context,
                    gameSlug: 'sudoku',
                    gameTitle: 'Sudoku Puzzle',
                    formattedTime: lastResult != null ? '${(lastResult.durationMs / 1000).toStringAsFixed(1)}s' : null,
                    rank: lastResult?.rank,
                    streak: lastResult?.streak.currentStreak,
                  );
                },
                icon: Icon(Icons.share_rounded, size: 18.sp, color: const Color(0xFF10B981)),
                label: Text(
                  'SHARE MY SCORE',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: const Color(0xFF10B981),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _playDailyPuzzle(context, dailyProvider),
                icon: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24.sp),
                label: Text(
                  'PLAY TODAY\'S PUZZLE',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFE50914).withValues(alpha: 0.4),
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
    final c = color ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: c),
          SizedBox(width: 4.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. Today's Speed Leaders Dedicated Scroll View
  // -------------------------------------------------------------
  Widget _buildSpeedLeadersCard(
    BuildContext context,
    DailyPuzzleProvider dailyProvider,
    bool isDark,
  ) {
    final lb = dailyProvider.dailyLeaderboard;
    final entries = lb?.entries ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF282E3E) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Trophy + Today's Speed Leaders + Live player count pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.25),
                            const Color(0xFFFFA500).withValues(alpha: 0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.emoji_events_rounded, color: const Color(0xFFFFB800), size: 19.sp),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'Today\'s Speed Leaders',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _CompetitionRadarBeacon(),
                    SizedBox(width: 6.w),
                    Text(
                      '${entries.length} ${entries.length == 1 ? 'Player' : 'Players'}',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Scrollable List of ALL players right here
          if (entries.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 26.h),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_esports_rounded,
                      size: 34.sp,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'No scores submitted yet today.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Be the first to claim #1 on the leaderboard!',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          else
            _LeaderboardScrollList(
              entries: entries,
              currentPlayerId: dailyProvider.playerId,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}

class _CompetitionRadarBeacon extends StatefulWidget {
  const _CompetitionRadarBeacon();

  @override
  State<_CompetitionRadarBeacon> createState() => _CompetitionRadarBeaconState();
}

class _CompetitionRadarBeaconState extends State<_CompetitionRadarBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final scale = 1.0 + (_pulseController.value * 0.55);
        final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);
        return SizedBox(
          width: 9.w,
          height: 9.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: opacity * 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardScrollList extends StatelessWidget {
  final List<DailyLeaderboardUser> entries;
  final String currentPlayerId;
  final bool isDark;

  const _LeaderboardScrollList({
    required this.entries,
    required this.currentPlayerId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final double itemHeight = 56.h;
    final double calculatedHeight = (entries.length * itemHeight).clamp(112.h, 360.h);

    return SizedBox(
      height: calculatedHeight,
      child: RawScrollbar(
        thumbVisibility: entries.length > 5,
        thickness: 3.5,
        radius: Radius.circular(8.r),
        thumbColor: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            thickness: 0.6,
            color: isDark ? const Color(0xFF222838) : const Color(0xFFF1F5F9),
          ),
          itemBuilder: (context, index) {
            final user = entries[index];
            final isMe = user.playerId == currentPlayerId;

            return _buildPlayerRow(context, user, isMe, index);
          },
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    DailyLeaderboardUser user,
    bool isMe,
    int index,
  ) {
    final rank = user.rank;
    final isTop1 = rank == 1;
    final isTop2 = rank == 2;
    final isTop3 = rank == 3;
    final isPodium = isTop1 || isTop2 || isTop3;

    Color rankBadgeBg;
    Color rankBadgeBorder;
    Color rankTextColor;

    if (isTop1) {
      rankBadgeBg = const Color(0xFFFFD700).withValues(alpha: isDark ? 0.25 : 0.2);
      rankBadgeBorder = const Color(0xFFFFD700);
      rankTextColor = const Color(0xFFD97706);
    } else if (isTop2) {
      rankBadgeBg = const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.25 : 0.2);
      rankBadgeBorder = const Color(0xFFCBD5E1);
      rankTextColor = isDark ? Colors.white : const Color(0xFF475569);
    } else if (isTop3) {
      rankBadgeBg = const Color(0xFFCD7F32).withValues(alpha: isDark ? 0.25 : 0.2);
      rankBadgeBorder = const Color(0xFFCD7F32);
      rankTextColor = const Color(0xFFB45309);
    } else {
      rankBadgeBg = isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9);
      rankBadgeBorder = isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0);
      rankTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isMe
            ? Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.45),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // 1. Rank Badge
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: rankBadgeBg,
              shape: BoxShape.circle,
              border: Border.all(color: rankBadgeBorder, width: isPodium ? 1.4 : 1),
            ),
            child: Center(
              child: isPodium
                  ? Icon(
                      Icons.emoji_events_rounded,
                      size: 13.sp,
                      color: rankTextColor,
                    )
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: rankTextColor,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 8.w),

          // 2. User Avatar
          _buildUserAvatar(user, isDark),
          SizedBox(width: 9.w),

          // 3. Name & Optional "You" Tag
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'YOU',
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 4. Time
          Text(
            user.formattedTime,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isMe
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(DailyLeaderboardUser user, bool isDark) {
    final photo = user.avatarUrl?.trim() ?? '';
    final name = user.displayName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2A2E3D) : const Color(0xFFE2E8F0),
        border: Border.all(
          color: isDark ? const Color(0xFF3B4254) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: photo.isNotEmpty
            ? Image.network(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarFallback(initial),
              )
            : _buildAvatarFallback(initial),
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF6366F1),
          ),
        ),
      ),
    );
  }
}
