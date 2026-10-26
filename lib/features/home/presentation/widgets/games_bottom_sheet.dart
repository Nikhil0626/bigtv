import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../utils/local_data.dart';
import '../../../../utils/app_enums.dart';
import '../../../auth/presentation/providers/authentication_provider.dart';
import '../../../auth/presentation/widgets/login_background_view.dart';
import '../../../patches_puzzle/presentation/screens/patch_game_screen.dart';
import '../../../patches_puzzle/presentation/screens/patch_dashboard_screen.dart';
import '../../../sudoku_puzzle/presentation/screens/sudoku_game_screen.dart';
import '../../../zip_puzzle/data/models/daily_puzzle_models.dart';
import '../../../zip_puzzle/data/repositories/puzzle_games_api_client.dart';
import '../../../zip_puzzle/presentation/providers/daily_puzzle_provider.dart';
import '../../../zip_puzzle/presentation/screens/zip_gameplay_screen.dart';
import '../../../zip_puzzle/presentation/screens/zip_level_selection_screen.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/widgets/lottie_3d_icon.dart';
import 'package:chotanews/services/game_share_helper.dart';

class GamesBottomSheet extends StatefulWidget {
  final bool isTelugu;

  const GamesBottomSheet({super.key, required this.isTelugu});

  static Future<void> show(BuildContext context, bool isTelugu) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GamesBottomSheet(isTelugu: isTelugu),
    );
  }

  @override
  State<GamesBottomSheet> createState() => _GamesBottomSheetState();
}

class _GamesBottomSheetState extends State<GamesBottomSheet> {
  final PuzzleGamesApiClient _apiClient = PuzzleGamesApiClient();
  late Future<List<ActiveGameItem>> _gamesFuture;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.track(AnalyticsEventName.gameListOpen);
    _fetchGames();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<DailyPuzzleProvider>().init(gameId: 'zip');
        } catch (_) {}
      }
    });
  }

  void _fetchGames() {
    _gamesFuture = _apiClient.getActiveGames();
  }

  Future<bool> _isGameCompletedToday(String slug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      return prefs.getBool('puzzle_completed_${slug}_$today') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onGameTap(BuildContext context, ActiveGameItem game) async {
    // 1. Debounce rapid multiple taps
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // 2. Verify user is logged in
      final isLoggedIn = await isUserLoggedIn();
      if (!mounted) {
        _isNavigating = false;
        return;
      }

      if (!isLoggedIn) {
        _isNavigating = false;
        _showLoginRequiredDialog(context);
        return;
      }

      final userId = (await getUserid()) ?? 'guest';
      if (!mounted) {
        _isNavigating = false;
        return;
      }

      final slug = game.slug.toLowerCase();
      final gameType = game.gameType.toLowerCase();

      AnalyticsService.instance.track(AnalyticsEventName.gameOpen, properties: {
        'game_id': slug,
        'game_name': game.name,
      });

      // Capture navigator and provider before popping modal
      final navigator = Navigator.of(context);
      final dailyProvider = context.read<DailyPuzzleProvider>();

      // Dismiss bottom sheet immediately on the first tap
      navigator.pop();

      // Determine target screen without blocking on network latency
      Widget targetScreen;

      if (slug.contains('sudoku') || gameType == 'sudoku') {
        targetScreen = SudokuGameScreen(playerId: userId);
      } else if (slug.contains('patch') || gameType == 'patch' || gameType == 'patches') {
        // Trigger background sync for patch state
        dailyProvider.init(gameId: 'patch');

        final isCompleted = (dailyProvider.gameId == 'patch' && dailyProvider.isTodayCompleted) ||
            (await _isGameCompletedToday('patch'));

        if (isCompleted) {
          targetScreen = PatchDashboardScreen(playerId: userId);
        } else {
          targetScreen = PatchGameScreen(playerId: userId);
        }
      } else if (slug.contains('zip') || gameType == 'zip') {
        // Trigger background sync for zip state
        dailyProvider.init(gameId: 'zip');

        final isCompleted = (dailyProvider.gameId == 'zip' && dailyProvider.isTodayCompleted) ||
            (await _isGameCompletedToday('zip'));

        if (isCompleted) {
          targetScreen = const ZipLevelSelectionScreen();
        } else {
          final level = dailyProvider.todayLevelDefinition;
          if (level != null) {
            targetScreen = ZipGameplayScreen(
              level: level,
              isDailyPuzzle: true,
            );
          } else {
            targetScreen = const ZipLevelSelectionScreen();
          }
        }
      } else {
        // Default dynamic route
        targetScreen = const ZipLevelSelectionScreen();
      }

      // Navigate immediately on the very first tap
      navigator.push(
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } catch (e) {
      debugPrint('Error navigating to game: $e');
    } finally {
      _isNavigating = false;
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E2024) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColorTokens.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.lock_rounded, color: AppColorTokens.primaryRed, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  widget.isTelugu ? 'లాగిన్ అవసరం' : 'ലോഗിൻ ആവശ്യമാണ്',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            widget.isTelugu
                ? 'గేమ్స్ ఆడటానికి మరియు మీ ర్యాంక్, స్ట్రీక్స్ నమోదు చేయడానికి దయచేసి లాగిన్ అవ్వండి.'
                : 'ഗെയിമുകൾ കളിക്കാനും നിങ്ങളുടെ റാങ്ക്, സ്‌ട്രീക്കുകൾ രേഖപ്പെടുത്താനും ദയവായി ലോഗിൻ ചെയ്യുക.',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                widget.isTelugu ? 'రద్దు' : 'റദ്ദാക്കുക',
                style: TextStyle(color: const Color(0xFF64748B), fontSize: 13.sp),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                elevation: 0,
              ),
              onPressed: () {
                final navigator = Navigator.of(context);
                context.read<AuthenticationProvider>().newAppLoginStatus = NewAppLoginStatus.login;
                Navigator.pop(dialogCtx);
                navigator.pop(); // close bottom sheet
                navigator.push(
                  MaterialPageRoute(builder: (_) => const LoginBackgroundView()),
                );
              },
              child: Text(
                widget.isTelugu ? 'లాగిన్ అవ్వండి' : 'ഇപ്പോൾ ലോഗിൻ ചെയ്യുക',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _get3DIconAssetForGame(String gameType, String slug) {
    final type = gameType.toLowerCase();
    final s = slug.toLowerCase();
    if (s.contains('zip') || type == 'zip') {
      return 'assets/images/zip_puzzle_3d_icon.png';
    } else if (s.contains('patch') || type == 'patches') {
      return 'assets/images/patch_puzzle_3d_icon.png';
    } else if (s.contains('sudoku') || type == 'sudoku') {
      return 'assets/images/sudoku_puzzle_3d_icon.png';
    }
    return 'assets/images/game_3d_icon.png';
  }

  IconData _getIconForGame(String gameType, String slug) {
    final type = gameType.toLowerCase();
    final s = slug.toLowerCase();
    if (s.contains('zip') || type == 'zip') {
      return Icons.polyline_rounded;
    } else if (s.contains('patch') || type == 'patches') {
      return Icons.extension_rounded;
    } else if (s.contains('sudoku') || type == 'sudoku') {
      return Icons.grid_on_rounded;
    }
    return Icons.sports_esports_rounded;
  }

  List<Color> _getGradientForGame(String gameType, String slug) {
    final type = gameType.toLowerCase();
    final s = slug.toLowerCase();
    if (s.contains('zip') || type == 'zip') {
      return const [Color(0xFF6366F1), Color(0xFF4F46E5)];
    } else if (s.contains('patch') || type == 'patches') {
      return const [Color(0xFFF59E0B), Color(0xFFD97706)];
    } else if (s.contains('sudoku') || type == 'sudoku') {
      return const [Color(0xFFEC4899), Color(0xFFDB2777)];
    }
    return const [Color(0xFF10B981), Color(0xFF059669)];
  }

  Color _getBadgeColor(String gameType, String slug) {
    final type = gameType.toLowerCase();
    final s = slug.toLowerCase();
    if (s.contains('zip') || type == 'zip') {
      return const Color(0xFF6366F1);
    } else if (s.contains('patch') || type == 'patches') {
      return const Color(0xFFF59E0B);
    } else if (s.contains('sudoku') || type == 'sudoku') {
      return const Color(0xFFEC4899);
    }
    return const Color(0xFF10B981);
  }

  String _getBadgeText(String gameType, String slug) {
    final type = gameType.toLowerCase();
    if (type == 'zip') {
      return 'DAILY PUZZLE';
    } else if (type == 'patches') {
      return 'BRAIN TEASER';
    } else if (type == 'sudoku') {
      return 'CLASSIC';
    }
    return 'PUZZLE';
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = widget.isTelugu;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Lottie3DIcon(
                  imagePath: 'assets/images/game_3d_icon.png',
                  width: 42.w,
                  height: 42.w,
                  shadowColor: const Color(0xFF10B981),
                  fallback: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: Icon(Icons.sports_esports_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? "బిగ్ టీవీ గేమ్స్ & పజిల్స్" : "ബിഗ് ടിവി ഗെയിംസ് & പസിലുകൾ",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isTelugu ? "మీ మెదడుకు పదును పెట్టే సరికొత్త పజిల్స్" : "നിങ്ങളുടെ മനസ്സിന് മൂർച്ച കൂട്ടുന്ന ഏറ്റവും പുതിയ പസിലുകൾ",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Dynamic Games List from API
            FutureBuilder<List<ActiveGameItem>>(
              future: _gamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 40.sp, color: Colors.grey),
                          SizedBox(height: 10.h),
                          Text(
                            isTelugu ? "గేమ్స్ లోడ్ చేయడం విఫలమైంది" : "ഗെയിമുകൾ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു",
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
                          ),
                          SizedBox(height: 12.h),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _fetchGames();
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(isTelugu ? "మళ్లీ ప్రయత్నించండి" : "വീണ്ടും ശ്രമിക്കുക"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final games = (snapshot.data ?? []).where((g) => g.isActive).toList();

                if (games.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.h),
                    child: Center(
                      child: Text(
                        isTelugu ? "ప్రస్తుతం గేమ్స్ అందుబాటులో లేవు" : "നിലവിൽ ഗെയിമുകൾ ലഭ്യമല്ല",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
                      ),
                    ),
                  );
                }

                return Column(
                  children: games.map((game) {
                    final icon = _getIconForGame(game.gameType, game.slug);
                    final gradient = _getGradientForGame(game.gameType, game.slug);
                    final badgeColor = _getBadgeColor(game.gameType, game.slug);
                    final badgeText = _getBadgeText(game.gameType, game.slug);

                    final asset3dIcon = _get3DIconAssetForGame(game.gameType, game.slug);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildDynamicGameCard(
                        title: game.name,
                        badge: badgeText,
                        badgeColor: badgeColor,
                        description: game.description,
                        icon: icon,
                        gradient: gradient,
                        iconUrl: game.iconUrl,
                        asset3dIcon: asset3dIcon,
                        gameSlug: game.slug,
                        onTap: () => _onGameTap(context, game),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicGameCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    String? iconUrl,
    String? asset3dIcon,
    String? gameSlug,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: asset3dIcon != null
                      ? Image.asset(
                          asset3dIcon,
                          width: 46.w,
                          height: 46.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackCardIcon(icon, gradient, iconUrl),
                        )
                      : (iconUrl != null && iconUrl.isNotEmpty)
                          ? Image.network(
                              iconUrl,
                              width: 46.w,
                              height: 46.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFallbackCardIcon(icon, gradient, null),
                            )
                          : _buildFallbackCardIcon(icon, gradient, null),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 20, color: Color(0xFF10B981)),
                tooltip: 'Share Game',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  final slugLower = (gameSlug ?? '').toLowerCase();
                  String canonicalSlug = 'zip';
                  String canonicalTitle = title;
                  if (slugLower.contains('patch')) {
                    canonicalSlug = 'patch';
                    canonicalTitle = 'Patch Puzzle';
                  } else if (slugLower.contains('sudoku')) {
                    canonicalSlug = 'sudoku';
                    canonicalTitle = 'Sudoku';
                  } else {
                    canonicalSlug = 'zip';
                    canonicalTitle = 'Zip Puzzle';
                  }
                  GameShareHelper.shareGame(
                    context: context,
                    gameSlug: canonicalSlug,
                    gameTitle: canonicalTitle,
                  );
                },
              ),
              SizedBox(width: 4.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackCardIcon(IconData icon, List<Color> gradient, String? iconUrl) {
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return Image.network(
        iconUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
