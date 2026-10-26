import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../utils/top_right_wave_painter.dart';
import '../providers/daily_puzzle_provider.dart';
import '../widgets/zip_daily_challenge_view.dart';
import 'zip_leaderboard_screen.dart';
import '../../../../services/game_share_helper.dart';

class ZipLevelSelectionScreen extends StatefulWidget {
  const ZipLevelSelectionScreen({super.key});

  @override
  State<ZipLevelSelectionScreen> createState() => _ZipLevelSelectionScreenState();
}

class _ZipLevelSelectionScreenState extends State<ZipLevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<DailyPuzzleProvider>();
        if (provider.gameId != 'zip' || provider.todayPuzzle == null) {
          provider.init(gameId: 'zip');
        }
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F6FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E222D).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161922).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF282E3E) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/zip_puzzle_3d_icon.png',
                width: 24.w,
                height: 24.w,
                errorBuilder: (_, __, ___) => const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 22),
              ),
              SizedBox(width: 8.w),
              Text(
                'Zip Puzzle',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.5.sp,
                  letterSpacing: 0.4,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'ARENA',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: const Color(0xFFE50914),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Consumer<DailyPuzzleProvider>(
            builder: (context, provider, _) {
              if (provider.isTodayCompleted) {
                final last = provider.lastSubmissionResult;
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: InkWell(
                    onTap: () {
                      GameShareHelper.shareGame(
                        context: context,
                        gameSlug: 'zip',
                        gameTitle: 'Zip Puzzle',
                        formattedTime: last != null ? '${(last.durationMs / 1000).toStringAsFixed(1)}s' : null,
                        rank: last?.rank,
                        streak: last?.streak.currentStreak,
                      );
                    },
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 18.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ZipLeaderboardScreen(
                      initialLevel: 1,
                      isDailyLeaderboard: true,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E222D).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.leaderboard_rounded,
                  size: 20.sp,
                  color: Colors.amber.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Signature animated wave ripple across the top
          Positioned(
            top: 0,
            right: 0,
            width: MediaQuery.of(context).size.width,
            height: 360.h,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: TopRightWavePainter(
                      waveAnimation: _waveController,
                      isDark: isDark,
                      maxRadius: 380.0,
                      gap: 22.0,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Gaming Content
          const SafeArea(
            child: ZipDailyChallengeView(),
          ),
        ],
      ),
    );
  }
}
