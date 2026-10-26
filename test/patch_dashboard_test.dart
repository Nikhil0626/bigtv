import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patch_dashboard_screen.dart';
import 'package:chotanews/features/zip_puzzle/data/models/daily_puzzle_models.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/daily_puzzle_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

class MockDailyPuzzleProvider extends ChangeNotifier implements DailyPuzzleProvider {
  @override
  String get gameId => 'patch';
  @override
  String get playerId => 'test_user_123';
  @override
  bool get isLoadingToday => false;
  @override
  bool get isLoadingStreak => false;
  @override
  bool get isLoadingLeaderboard => false;
  @override
  bool get isSubmitting => false;
  @override
  bool get isRequestingRecovery => false;
  @override
  String? get errorMessage => null;
  @override
  DailyGameData? get todayPuzzle => const DailyGameData(
        gameId: 'patch',
        gameName: 'Patch Puzzle',
        gameType: 'patch',
        puzzleDate: '2026-10-23',
        timezone: 'Asia/Kolkata',
        levelId: 'patch_003',
        levelNumber: 3,
        title: 'Patch Level 3',
        difficulty: 'medium',
        schemaVersion: 1,
        contentVersion: 1,
        content: {
          'grid': {'rows': 5, 'columns': 5},
        },
      );
  @override
  bool get isTodayCompleted => true;
  @override
  DailySubmissionResult? get lastSubmissionResult => const DailySubmissionResult(
        gameId: 'patch',
        levelId: 'patch_003',
        levelNumber: 3,
        playerId: 'test_user_123',
        durationMs: 18400,
        bestDurationMs: 18400,
        score: 100,
        isNewBest: true,
        rank: 1,
        streak: DailyStreakInfo(
          currentStreak: 1,
          longestStreak: 5,
          streakMaintained: true,
          freeMonthlyReviveApplied: false,
        ),
      );
  @override
  StreakCalendarResponse? get streakCalendar => null;
  @override
  int get currentStreak => 1;
  @override
  int get longestStreak => 5;
  @override
  int get gapDays => 0;
  @override
  bool get monthlyFreeReviveAvailable => true;
  @override
  int get autoApproveRemaining => 1;
  @override
  bool get canRequestRecovery => false;
  @override
  List<StreakDayItem> get last7Days => [
        StreakDayItem(date: '2026-10-17', dayName: 'Sat', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-18', dayName: 'Sun', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-19', dayName: 'Mon', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-20', dayName: 'Tue', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-21', dayName: 'Wed', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-22', dayName: 'Thu', completed: false, isToday: false),
        StreakDayItem(date: '2026-10-23', dayName: 'Fri', completed: true, isToday: true),
      ];
  @override
  DailyLeaderboardResponse? get dailyLeaderboard => DailyLeaderboardResponse(
        gameId: 'patch',
        levelId: 'patch_003',
        page: 1,
        limit: 100,
        total: 2,
        totalPages: 1,
        entries: [
          DailyLeaderboardUser(
            rank: 1,
            playerId: 'test_user_123',
            displayName: 'ProGamer',
            bestDurationMs: 18400,
            score: 100,
          ),
          DailyLeaderboardUser(
            rank: 2,
            playerId: 'rival_player',
            displayName: 'RivalX',
            bestDurationMs: 24500,
            score: 95,
          ),
        ],
      );

  @override
  Future<void> init({String gameId = 'zip'}) async {}

  @override
  Future<void> loadTodayLeaderboard({int page = 1, int limit = 50}) async {}

  @override
  Future<void> loadStreakCalendar() async {}

  @override
  Future<void> loadTodayGame({String? date}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithMaterial(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => ChangeNotifierProvider<DailyPuzzleProvider>(
        create: (_) => MockDailyPuzzleProvider(),
        child: MaterialApp(
          home: child,
        ),
      ),
    );
  }

  testWidgets('PatchDashboardScreen renders animated waves, gaming style, and scroll view leaderboard without View All', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;

    await tester.pumpWidget(wrapWithMaterial(
      const PatchDashboardScreen(playerId: 'test_user_123'),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 1. Verify animated wave custom paint and competition atmosphere exist
    expect(find.byType(CustomPaint), findsWidgets);
    final waveFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is TopRightWavePainter,
    );
    expect(waveFinder, findsOneWidget);

    final competitionFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter.runtimeType.toString() == 'CompetitionAtmospherePainter',
    );
    expect(competitionFinder, findsOneWidget);

    // 2. Verify gaming header elements
    expect(find.text('Patch Puzzle'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('PATCH MASTER'), findsOneWidget);

    // 3. Verify feature badges in Wrap
    expect(find.text('5x5 Grid'), findsOneWidget);
    expect(find.text('Dynamic Patches'), findsOneWidget);
    expect(find.text('MEDIUM'), findsOneWidget);

    // 4. Verify completed state buttons: VIEW SOLVED GAME & SHARE MY SCORE are present, Replay is REMOVED!
    expect(find.text('VIEW SOLVED GAME'), findsOneWidget);
    expect(find.text('SHARE MY SCORE'), findsOneWidget);
    expect(find.text('Replay'), findsNothing);

    // 5. Scroll down to Today's Speed Leaders: NO "View All" button!
    await tester.scrollUntilVisible(
      find.text('Today\'s Speed Leaders'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Today\'s Speed Leaders'), findsOneWidget);
    expect(find.text('View All'), findsNothing);

    // 6. Verify player scroll view entries
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('ProGamer'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('RivalX'), findsOneWidget);

    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });
}
