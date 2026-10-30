import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../utils/top_right_wave_painter.dart';
import '../../../zip_puzzle/presentation/providers/daily_puzzle_provider.dart';
import '../../../patches_puzzle/presentation/widgets/competition_atmosphere_painter.dart';
import '../widgets/sudoku_daily_challenge_view.dart';

class SudokuDashboardScreen extends StatefulWidget {
  final String playerId;

  const SudokuDashboardScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<SudokuDashboardScreen> createState() => _SudokuDashboardScreenState();
}

class _SudokuDashboardScreenState extends State<SudokuDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _competitionController;
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();

    _competitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<DailyPuzzleProvider>();
        provider.init(gameId: 'sudoku');
        provider.loadStreakCalendar();
        provider.loadTodayLeaderboard(limit: 100);
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _competitionController.dispose();
    _pageScrollController.dispose();
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
                  width: 1,
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/sudoku_puzzle_3d_icon.png',
                width: 22.w,
                height: 22.w,
                errorBuilder: (_, __, ___) => const Icon(Icons.grid_on_rounded, color: Colors.blueAccent, size: 20),
              ),
              SizedBox(width: 6.w),
              Text(
                'Sudoku Puzzle',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17.sp,
                  letterSpacing: 0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
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

          // 2. Animated Competition Atmosphere Sparks & Championship Aura
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _competitionController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: CompetitionAtmospherePainter(
                      animation: _competitionController,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Gaming Arena Content
          SafeArea(
            child: SudokuDailyChallengeView(
              playerId: widget.playerId,
              scrollController: _pageScrollController,
            ),
          ),
        ],
      ),
    );
  }
}
