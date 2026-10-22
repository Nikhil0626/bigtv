import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/editorial_screen.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_screen.dart';
import 'package:chotanews/features/home/presentation/screens/live_tv_screen.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporters_screen.dart';
import 'package:chotanews/features/zip_puzzle/presentation/screens/zip_level_selection_screen.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patches_level_selection_screen.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_level_selection_screen.dart';
import 'package:chotanews/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchDiscoverScreen extends StatelessWidget {
  final VoidCallback? onGoToHome;
  const SearchDiscoverScreen({super.key, this.onGoToHome});

  String _getImageUrl(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
      return "";
    }
    String url = imageUrl.toString();
    if (url.startsWith('http')) {
      return url;
    }
    if (url.startsWith('/')) {
      return "https://migwp.chotanews.com$url";
    }
    return "https://migwp.chotanews.com/$url";
  }

  void _navigateToHome(BuildContext context, HomeProvider homeProvider) {
    if (onGoToHome != null) {
      onGoToHome!();
    } else {
      homeProvider.onItemTapped(1);
      if (homeProvider.homePageController.hasClients) {
        homeProvider.homePageController.jumpToPage(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final isTelugu = homeProvider.langCode != 'ml';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColorTokens.primaryRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColorTokens.primaryRed,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar with Logo & Live Badge
                _buildTopAppBar(context, homeProvider, isTelugu),

                // Main Discover Scrollable Content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 18.h, bottom: 90.h),
                    children: [
                      // 1. Quick Services Shortcuts (Editorial, E-Paper, My Feed, Trending)
                      _buildQuickServicesSection(context, homeProvider, isTelugu),

                      SizedBox(height: 22.h),

                      // 2. BigTV 24x7 Broadcast Hero Card
                      _buildLiveTvHeroBanner(context, homeProvider, isTelugu),

                      SizedBox(height: 24.h),

                      // 3. Popular Topics & AI Tags Section
                      _buildPopularTopicsSection(context, homeProvider, isTelugu),

                      SizedBox(height: 24.h),

                      // 4. Trending Highlights & Top Stories Carousel
                      _buildTopStoriesSection(context, homeProvider, isTelugu),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top Bar with BigTV Post Logo on Left and Live Pulse Badge on Right
  Widget _buildTopAppBar(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BigTV Logo
          Image.asset(
            'assets/images/BigTvPostLogo.png',
            height: 32.h,
            fit: BoxFit.contain,
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bookmarks Shortcut Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookmarksScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bookmark_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 4.w),
                        Consumer<BookmarksProvider>(
                          builder: (context, provider, _) {
                            final countText = provider.totalBookmarks > 0
                                ? " (${provider.totalBookmarks})"
                                : "";
                            return Text(
                              "${isTelugu ? "బుక్‌మార్క్స్" : "Saved"}$countText",
                              style: TextStyle(
                                color: const Color(0xFFDC2626),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),

              // Live Broadcast Indicator Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () async {
                    final liveData = await homeProvider.fetchLiveTvStream();
                    if (!context.mounted) return;
                    if (liveData != null &&
                        liveData['stream_url'] != null &&
                        liveData['stream_url'].toString().isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveTvScreen(
                            streamUrl: liveData['stream_url'].toString(),
                            channelName: (liveData['channel_name'] ?? "BIGTV").toString(),
                            playbackType: (liveData['playback_type'] ?? "hls").toString(),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          "LIVE 24x7",
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section Header with Red Vertical Indicator
  Widget _buildSectionHeader({
    required String title,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// Quick Services Section (Editorial, E-Paper, Reporters, My Feed, Trending)
  Widget _buildQuickServicesSection(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: isTelugu ? "త్వరిత సేవలు" : "ദ്രుത സേവനങ്ങൾ",
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 108.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              // 1. EDITORIAL
              _buildModernShortcutTile(
                title: isTelugu ? "ఎడిటోరియల్" : "എഡിറ്റോറിയൽ",
                subtitle: "Editorial",
                icon: Icons.article_rounded,
                iconGradient: const [Color(0xFFFF5E62), Color(0xFFFF2A2A)],
                shadowColor: const Color(0xFFFF2A2A).withValues(alpha: 0.25),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditorialScreen(),
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),

              // 2. E-PAPER
              _buildModernShortcutTile(
                title: isTelugu ? "ఈ-పేపర్" : "ഇ-പേപ്പర్",
                subtitle: "E-Paper",
                icon: Icons.newspaper_rounded,
                iconGradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                shadowColor: const Color(0xFFD97706).withValues(alpha: 0.25),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EpaperScreen(),
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),

              // 3. GAMES
              _buildModernShortcutTile(
                title: isTelugu ? "గేమ్స్" : "ഗെയിംസ്",
                subtitle: "Games",
                icon: Icons.sports_esports_rounded,
                iconGradient: const [Color(0xFF10B981), Color(0xFF059669)],
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                onTap: () => _showGamesBottomSheet(context, isTelugu),
              ),
              SizedBox(width: 10.w),

              // 4. REPORTERS
              _buildModernShortcutTile(
                title: isTelugu ? "రిపోర్టర్లు" : "റിപ്പോർട്ടർമാർ",
                subtitle: "Reporters",
                icon: Icons.mic_rounded,
                iconGradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportersScreen(),
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),

              // 5. BOOKMARKS
              _buildModernShortcutTile(
                title: isTelugu ? "బుక్‌మార్క్‌లు" : "Bookmarks",
                subtitle: "Saved",
                icon: Icons.bookmark_rounded,
                iconGradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                shadowColor: const Color(0xFFEC4899).withValues(alpha: 0.25),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksScreen(),
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),

              // 5. MY FEED / NEWS
              _buildModernShortcutTile(
                title: isTelugu ? "వార్తలు" : "വാർത്തകൾ",
                subtitle: "My Feed",
                icon: Icons.dynamic_feed_rounded,
                iconGradient: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.25),
                onTap: () => _navigateToHome(context, homeProvider),
              ),
              SizedBox(width: 10.w),

              // 6. TRENDING
              _buildModernShortcutTile(
                title: isTelugu ? "ట్రెండింగ్" : "ട്രെൻഡിംഗ്",
                subtitle: "Trending",
                icon: Icons.local_fire_department_rounded,
                iconGradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                shadowColor: const Color(0xFFFF416C).withValues(alpha: 0.25),
                onTap: () {
                  if (homeProvider.getAllAiTagsList.isNotEmpty) {
                    final firstTag = homeProvider.getAllAiTagsList.first;
                    final tagId = firstTag['aitagid'] ?? firstTag['id'] ?? firstTag['slug'] ?? '0';
                    homeProvider.setSelectedTagId(tagId);
                    homeProvider.getAllPostsByAiId(tagId);
                    homeProvider.aiTagDataLoaded(true);
                  }
                  _navigateToHome(context, homeProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Games Selection Bottom Sheet showing Zip, Patches, and Sudoku Puzzles
  void _showGamesBottomSheet(BuildContext context, bool isTelugu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    Container(
                      width: 40.w,
                      height: 40.w,
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
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTelugu ? "బిగ్ టీవీ గేమ్స్ & పజిల్స్" : "ബിഗ് ടിവി ഗെയിംസ്",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          isTelugu ? "మీ మెదడుకు పదును పెట్టే సరికొత్త పజిల్స్" : "Challenge your mind with puzzles",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // 1. Zip Puzzle Card
                _buildGameItemCard(
                  title: isTelugu ? "జిప్ పజిల్" : "Zip Puzzle",
                  badge: "DAILY PUZZLE",
                  badgeColor: const Color(0xFF6366F1),
                  description: isTelugu ? "గ్రిడ్ పాయింట్లు కనెక్ట్ చేసి మార్గం కనుగొనండి" : "Connect the dots without crossing walls",
                  icon: Icons.polyline_rounded,
                  gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ZipLevelSelectionScreen()),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // 2. Patches Puzzle Card
                _buildGameItemCard(
                  title: isTelugu ? "ప్యాచెస్ పజిల్" : "Patches Puzzle",
                  badge: "BRAIN TEASER",
                  badgeColor: const Color(0xFFF59E0B),
                  description: isTelugu ? "రంగుల ప్యాచులతో గ్రిడ్ సరిగ్గా పూర్తి చేయండి" : "Place colored patches to cover the board",
                  icon: Icons.extension_rounded,
                  gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatchesLevelSelectionScreen()),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // 3. Sudoku 6x6 Card
                _buildGameItemCard(
                  title: isTelugu ? "సుడోకు 6x6" : "Sudoku 6x6",
                  badge: "CLASSIC",
                  badgeColor: const Color(0xFFEC4899),
                  description: isTelugu ? "వేగవంతమైన 6x6 నంబర్ గ్రిడ్ లాజిక్ గేమ్" : "Fast-paced 6x6 number logic challenge",
                  icon: Icons.grid_on_rounded,
                  gradient: const [Color(0xFFEC4899), Color(0xFFDB2777)],
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SudokuLevelSelectionScreen()),
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameItemCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required IconData icon,
    required List<Color> gradient,
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
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 24),
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
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern Squircle Tile for Quick Services
  Widget _buildModernShortcutTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: 78.w,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Squircle Gradient Icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// BigTV 24x7 Broadcast Hero Card with Crimson Gradient & Frosted Play Button
  Widget _buildLiveTvHeroBanner(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () async {
            final liveData = await homeProvider.fetchLiveTvStream();
            if (!context.mounted) return;
            if (liveData != null &&
                liveData['stream_url'] != null &&
                liveData['stream_url'].toString().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveTvScreen(
                    streamUrl: liveData['stream_url'].toString(),
                    channelName: (liveData['channel_name'] ?? "BIGTV").toString(),
                    playbackType: (liveData['playback_type'] ?? "hls").toString(),
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF991B1B), // Deep Burgundy
                  Color(0xFFDC2626), // BigTV Red
                  Color(0xFFEF4444), // Vibrant Crimson
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                // Frosted Glass TV Icon Container
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.live_tv_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // Titles and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: const Color(0xFFDC2626),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "BIG TV 24x7",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        isTelugu
                            ? "తాజా వార్తల ప్రత్యక్ష ప్రసారం చూడండి"
                            : "തത്സമയ വാർത്തകൾ കാണുക",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Frosted Circular Play Button
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: const Color(0xFFDC2626),
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Popular Topics / AI Tags Grid with Modern Pill Styling
  Widget _buildPopularTopicsSection(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    final tags = homeProvider.getAllAiTagsList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: isTelugu ? "ప్రముఖ అంశాలు & ట్యాగ్‌లు" : "പ്രധാന വിഷയങ്ങൾ",
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: tags.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    isTelugu ? "అంశాలు లోడ్ అవుతున్నాయి..." : "വിഷയങ്ങൾ ലോഡ് ചെയ്യുന്നു...",
                    style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
                  ),
                )
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 10.h,
                  children: tags.take(12).map((tag) {
                    final String tagName = (tag['aitagname'] ??
                            tag['name'] ??
                            tag['title'] ??
                            tag['slug'] ??
                            '')
                        .toString();
                    if (tagName.trim().isEmpty) return const SizedBox.shrink();

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22.r),
                        onTap: () {
                          final tagId = tag['aitagid'] ?? tag['id'] ?? tag['slug'] ?? tagName;
                          homeProvider.setSelectedTagId(tagId);
                          if (homeProvider.liveTvVideosEnable) {
                            homeProvider.fetchVideosByTagSlug(
                              (tag['slug'] ?? tagName).toString(),
                              displayTitle: tagName,
                            );
                          } else {
                            homeProvider.getAllPostsByAiId(tagId);
                          }
                          homeProvider.aiTagDataLoaded(true);
                          _navigateToHome(context, homeProvider);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "#",
                                style: TextStyle(
                                  color: AppColorTokens.primaryRed,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                tagName,
                                style: TextStyle(
                                  color: const Color(0xFF1E293B),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  /// Trending Highlights & Top Stories Horizontal Carousel
  Widget _buildTopStoriesSection(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    // Filter out valid news articles from home feed
    final articles = homeProvider.getAllPostList
        .where((e) =>
            e is Map &&
            e['title'] != null &&
            e['title'].toString().trim().isNotEmpty &&
            e['type'] != 'morefollow' &&
            e['type'] != 'HomePostGrid')
        .take(6)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: isTelugu ? "తాజా ముఖ్యాంశాలు" : "പ്രധാന വാർത്തകൾ",
          trailing: GestureDetector(
            onTap: () => _navigateToHome(context, homeProvider),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTelugu ? "అన్నీ చూడండి" : "എല്ലാം കാണുക",
                  style: TextStyle(
                    color: AppColorTokens.primaryRed,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColorTokens.primaryRed,
                  size: 11.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (articles.isNotEmpty)
          SizedBox(
            height: 195.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics: const BouncingScrollPhysics(),
              itemCount: articles.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final article = articles[index] as Map;
                final title = (article['title'] ?? '').toString();
                final rawImg = article['image_url'] ?? article['image'] ?? article['thumbnail'] ?? '';
                final imageUrl = _getImageUrl(rawImg);

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () => _navigateToHome(context, homeProvider),
                    child: Container(
                      width: 220.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFEDF2F7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Article Image Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                            child: SizedBox(
                              height: 110.h,
                              width: double.infinity,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: Center(
                                          child: Icon(
                                            Icons.newspaper_rounded,
                                            color: const Color(0xFF94A3B8),
                                            size: 28.sp,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFFF1F5F9),
                                      child: Center(
                                        child: Icon(
                                          Icons.newspaper_rounded,
                                          color: const Color(0xFF94A3B8),
                                          size: 28.sp,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          // Article Title & Footer
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        "BIG TV",
                                        style: TextStyle(
                                          color: AppColorTokens.primaryRed,
                                          fontSize: 8.5.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 10.sp,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      isTelugu ? "తాజా వార్త" : "പുതിയ വാർത്ത",
                                      style: TextStyle(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          // Fallback Feature Highlight Cards if news feed hasn't populated yet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildDiscoverFeatureCard(
                    title: isTelugu ? "ప్రత్యేక కథనాలు" : "പ്രത്യേക വാർത്തകൾ",
                    subtitle: isTelugu ? "విశేష విశ్లేషణ" : "വിശകലനം",
                    icon: Icons.auto_awesome_rounded,
                    accentColor: const Color(0xFF6366F1),
                    onTap: () => _navigateToHome(context, homeProvider),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDiscoverFeatureCard(
                    title: isTelugu ? "వీడియో బులెటిన్" : "വീഡിയോ ബുള്ളറ്റിൻ",
                    subtitle: isTelugu ? "త్వరిత ముఖ్యాంశాలు" : "വേഗത്തിലുള്ള വാർത്തകൾ",
                    icon: Icons.play_circle_fill_rounded,
                    accentColor: const Color(0xFFEC4899),
                    onTap: () => _navigateToHome(context, homeProvider),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Fallback Discover Feature Highlight Card
  Widget _buildDiscoverFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
