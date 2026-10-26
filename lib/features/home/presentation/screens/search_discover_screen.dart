import 'dart:io';
import 'dart:math' as math;
import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/editorial_screen.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_screen.dart';
import 'package:chotanews/features/home/presentation/screens/live_tv_screen.dart';
import 'package:chotanews/features/home/presentation/widgets/games_bottom_sheet.dart';
import 'package:chotanews/features/home/presentation/widgets/lottie_3d_icon.dart';
import 'package:chotanews/services/live_tv_share_helper.dart';
import 'package:chotanews/features/notifications/data/models/app_notification_model.dart';
import 'package:chotanews/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:chotanews/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:chotanews/features/notifications/presentation/widgets/notification_shimmer_list.dart';
import 'package:chotanews/features/reporters/presentation/providers/reporters_provider.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporters_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchDiscoverScreen extends StatefulWidget {
  final VoidCallback? onGoToHome;
  const SearchDiscoverScreen({super.key, this.onGoToHome});

  @override
  State<SearchDiscoverScreen> createState() => _SearchDiscoverScreenState();
}

class _SearchDiscoverScreenState extends State<SearchDiscoverScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: Discover, 1: Notifications
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _waveController;
  late final Animation<double> _waveAnimation;

  late final AnimationController _livePulseController;
  late final Animation<double> _livePulseAnimation;

  late final AnimationController _bookmarkController;
  late final Animation<double> _bookmarkAnimation;

  late final AnimationController _borderController;
  late final Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_waveController);

    _livePulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _livePulseAnimation = CurvedAnimation(
      parent: _livePulseController,
      curve: Curves.easeInOut,
    );

    _bookmarkController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _bookmarkAnimation = CurvedAnimation(
      parent: _bookmarkController,
      curve: Curves.easeInOut,
    );

    // Uniform linear controller for border dot rotation across both buttons
    _borderController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.linear),
    );

    if (!isTest) {
      _waveController.repeat();
      _livePulseController.repeat();
      _bookmarkController.repeat();
      _borderController.repeat();
    } else {
      _waveController.value = 0.5;
      _livePulseController.value = 0.5;
      _bookmarkController.value = 0.5;
      _borderController.value = 0.5;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final homeProvider = context.read<HomeProvider>();
      final expectedNotifLang = (homeProvider.langCode == 'ml') ? 'ml' : 'te';
      final notifProvider = context.read<NotificationsProvider>();
      if (notifProvider.notifications.isEmpty || notifProvider.currentLanguage != expectedNotifLang) {
        notifProvider.fetchNotifications(languageCode: expectedNotifLang);
      }
      if (homeProvider.editorialPosts.isEmpty || homeProvider.editorialLanguage != homeProvider.langCode) {
        homeProvider.fetchEditorialPosts(refresh: true);
      }
      final expectedVideoLang = (homeProvider.langCode == 'ml') ? 'ml' : 'te';
      if (homeProvider.getAllAiTagsList.isEmpty || homeProvider.videoTagsLanguage != expectedVideoLang) {
        homeProvider.getAllAiTags();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250) {
          context.read<NotificationsProvider>().loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _livePulseController.dispose();
    _bookmarkController.dispose();
    _borderController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openNotificationPost(
    BuildContext context,
    AppNotificationModel notification,
  ) {
    String? targetPostId;
    if (notification.postId != null && notification.postId != 0) {
      targetPostId = notification.postId.toString();
    } else if (notification.link != null && notification.link!.isNotEmpty) {
      final uri = Uri.tryParse(notification.link!);
      if (uri != null) {
        targetPostId = uri.queryParameters['postId'] ??
            uri.queryParameters['post_id'] ??
            uri.queryParameters['articleId'] ??
            uri.queryParameters['article_id'] ??
            uri.queryParameters['id'];

        if (targetPostId == null || targetPostId.isEmpty) {
          for (final seg in uri.pathSegments) {
            if (int.tryParse(seg) != null && seg != "0") {
              targetPostId = seg;
              break;
            }
          }
        }

        // If it's a non-post deep link (e.g. epaper, live, events), route it
        if ((targetPostId == null || targetPostId.isEmpty) &&
            (uri.path.contains('epaper') ||
                uri.path.contains('events') ||
                uri.path.contains('live') ||
                uri.path.contains('reel'))) {
          context.read<HomeProvider>().routeDeepLink(uri, isFromNotification: true);
          return;
        }
      }
    }

    if (targetPostId != null && targetPostId.isNotEmpty && targetPostId != "0") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualPostView1(
            postId: targetPostId!,
            isComeFrom: true,
            initialArticle: notification.toInitialArticleMap(),
          ),
        ),
      );
    }
  }

  void _navigateToHome(BuildContext context, HomeProvider homeProvider) {
    if (widget.onGoToHome != null) {
      widget.onGoToHome!();
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
    final notifProvider = context.watch<NotificationsProvider>();
    final isTelugu = homeProvider.langCode != 'ml';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
        body: Stack(
          children: [
            // Background top right wave design from reporters page
            Positioned(
              top: 0,
              right: 0,
              width: MediaQuery.of(context).size.width,
              height: 350.h,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: TopRightWavePainter(
                    isDark: isDark,
                    waveAnimation: _waveAnimation,
                  ),
                ),
              ),
            ),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar with Logo & Animated Live / Bookmarks Badges
                  _buildTopAppBar(context, homeProvider, isTelugu),

                  // Segmented Switcher: [ డిస్కవర్ (Discoveries) | నోటిఫికేషన్‌లు (Notifications) ]
                  _buildSegmentedTabSwitcher(context, notifProvider, isTelugu),

                  // Content depending on selected tab (0: Discoveries, 1: Notifications)
                  if (_selectedTabIndex == 0)
                    _buildDiscoverTabView(context, homeProvider, isTelugu)
                  else
                    _buildNotificationsTabView(
                      context,
                      homeProvider,
                      notifProvider,
                      isTelugu,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented Switcher: [ డిస్కవర్ (Discoveries) | నోటిఫికేషన్‌లు (Notifications) ]
  Widget _buildSegmentedTabSwitcher(
    BuildContext context,
    NotificationsProvider notifProvider,
    bool isTelugu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Tab 0: Discoveries
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? AppColorTokens.primaryRed
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: _selectedTabIndex == 0
                        ? [
                            BoxShadow(
                              color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_rounded,
                        size: 15.sp,
                        color: _selectedTabIndex == 0
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          isTelugu ? "డిస్కవర్" : "ഡിസ്കവർ",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            fontSize: 12.sp,
                            fontWeight: _selectedTabIndex == 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab 1: Notifications
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 1;
                  });
                  final homeProvider = context.read<HomeProvider>();
                  final expectedNotifLang = (homeProvider.langCode == 'ml') ? 'ml' : 'te';
                  if (notifProvider.notifications.isEmpty || notifProvider.currentLanguage != expectedNotifLang) {
                    notifProvider.fetchNotifications(
                      isRefresh: notifProvider.currentLanguage != expectedNotifLang,
                      languageCode: expectedNotifLang,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? AppColorTokens.primaryRed
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: _selectedTabIndex == 1
                        ? [
                            BoxShadow(
                              color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        size: 15.sp,
                        color: _selectedTabIndex == 1
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          "${isTelugu ? "నోటిఫికేషన్‌లు" : "അറിയിപ്പുകൾ"}${notifProvider.total > 0 ? " (${notifProvider.total})" : ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            fontSize: 12.sp,
                            fontWeight: _selectedTabIndex == 1
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Notifications Tab Content with Infinite Scrolling ListView
  Widget _buildNotificationsTabView(
    BuildContext context,
    HomeProvider homeProvider,
    NotificationsProvider notifProvider,
    bool isTelugu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: RefreshIndicator(
        color: AppColorTokens.primaryRed,
        onRefresh: () async {
          await notifProvider.fetchNotifications(
            isRefresh: true,
            languageCode: homeProvider.langCode == 'ml' ? 'ml' : 'te',
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Services Horizontal Bar
            SizedBox(height: 8.h),
            _buildQuickServicesRow(context, homeProvider, isTelugu),
            SizedBox(height: 10.h),

            // Section Header: "All Notifications" with live pulse dot & count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        isTelugu ? "తాజా నోటిఫికేషన్‌లు" : "ഏറ്റവും പുതിയ അറിയിപ്പുകൾ",
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  if (notifProvider.total > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
                      ),
                      child: Text(
                        "${notifProvider.total} ${isTelugu ? "అలర్ట్‌లు" : "അറിയിപ്പുകൾ"}",
                        style: TextStyle(
                          color: AppColorTokens.primaryRed,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Main Notification List / Loading / Error / Empty States
            Expanded(
              child: notifProvider.isLoading && notifProvider.notifications.isEmpty
                  ? const NotificationShimmerList(count: 6)
                  : notifProvider.errorMessage != null && notifProvider.notifications.isEmpty
                      ? _buildErrorState(context, notifProvider, isTelugu)
                      : notifProvider.filteredNotifications.isEmpty
                          ? _buildEmptyState(context, notifProvider, isTelugu)
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.only(top: 2.h, bottom: 95.h),
                              itemCount: notifProvider.filteredNotifications.length +
                                  (notifProvider.hasMore && notifProvider.searchQuery.isEmpty ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == notifProvider.filteredNotifications.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: AppColorTokens.primaryRed,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final item = notifProvider.filteredNotifications[index];
                                return NotificationItemCard(
                                  notification: item,
                                  isTelugu: isTelugu,
                                  onTap: () => _openNotificationPost(context, item),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Horizontal Quick Services Row for Notifications Tab
  Widget _buildQuickServicesRow(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        children: [
          // 1. EDITORIAL
          _buildCompactChip(
            index: 0,
            icon: Icons.article_rounded,
            iconColor: const Color(0xFFFF2A2A),
            imagePath: 'assets/images/editorial_3d_icon.png',
            label: isTelugu ? "ఎడిటోరియల్" : "എഡിറ്റോറിയൽ",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditorialScreen()),
              );
            },
          ),
          SizedBox(width: 8.w),

          // 2. E-PAPER (Removed for Malayalam)
          if (isTelugu) ...[
            _buildCompactChip(
              index: 1,
              icon: Icons.newspaper_rounded,
              iconColor: const Color(0xFFD97706),
              imagePath: 'assets/images/epaper_3d_icon.png',
              label: "ఈ-పేపర్",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EpaperScreen()),
                );
              },
            ),
            SizedBox(width: 8.w),
          ],

          // 3. GAMES
          _buildCompactChip(
            index: 2,
            icon: Icons.sports_esports_rounded,
            iconColor: const Color(0xFF059669),
            imagePath: 'assets/images/game_3d_icon.png',
            label: isTelugu ? "గేమ్స్" : "ഗെയിംസ്",
            onTap: () => GamesBottomSheet.show(context, isTelugu),
          ),
          SizedBox(width: 8.w),

          // 4. REPORTERS
          _buildCompactChip(
            index: 3,
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFF7C3AED),
            imagePath: 'assets/images/reporters_3d_icon.png',
            label: isTelugu ? "రిపోర్టర్లు" : "റിപ്പോർട്ടർമാർ",
            onTap: () {
              final targetLang = isTelugu ? 'te' : 'ml';
              final repProvider = context.read<ReportersProvider>();
              if (repProvider.currentLanguage != targetLang) {
                repProvider.loadReporters(languageCode: targetLang, force: true);
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportersScreen()),
              );
            },
          ),
          SizedBox(width: 8.w),

          // 5. BOOKMARKS
          _buildCompactChip(
            index: 4,
            icon: Icons.bookmark_rounded,
            iconColor: const Color(0xFFBE185D),
            imagePath: 'assets/images/bookmarks_3d_icon.png',
            label: isTelugu ? "బుక్‌మార్క్స్" : "ബുക്ക്‌മാർക്കുകൾ",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
          SizedBox(width: 8.w),

          // 6. MY FEED / NEWS
          _buildCompactChip(
            index: 5,
            icon: Icons.dynamic_feed_rounded,
            iconColor: const Color(0xFF2563EB),
            imagePath: 'assets/images/myfeed_3d_icon.png',
            label: isTelugu ? "న్యూస్" : "വാർത്തകൾ",
            onTap: () => _navigateToHome(context, homeProvider),
          ),
          SizedBox(width: 8.w),

          // 7. TRENDING
          _buildCompactChip(
            index: 6,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF4B2B),
            imagePath: 'assets/images/trending_3d_icon.png',
            label: isTelugu ? "ట్రెండింగ్" : "ട്രെൻഡിംഗ്",
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
    );
  }

  /// Compact Pill Chip for Horizontal Quick Services with Lottie 3D Micro-Animation
  Widget _buildCompactChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    String? imagePath,
    int index = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null)
                Lottie3DIcon(
                  imagePath: imagePath,
                  width: 19.w,
                  height: 19.w,
                  index: index,
                  fallback: Icon(icon, size: 14.sp, color: iconColor),
                )
              else
                Icon(icon, size: 14.sp, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state when no notifications match search query
  Widget _buildEmptyState(
    BuildContext context,
    NotificationsProvider notifProvider,
    bool isTelugu,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 1),
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 32.sp,
                  color: AppColorTokens.primaryRed,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              notifProvider.searchQuery.isNotEmpty
                  ? (isTelugu ? "ఫలితాలు కనుగొనబడలేదు" : "ഫലങ്ങളൊന്നും കണ്ടെത്തിയില്ല")
                  : (isTelugu ? "నోటిఫికేషన్‌లు ఏవీ లేవు" : "അറിയിപ്പുകൾ ഒന്നും ലഭ്യമല്ല"),
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              notifProvider.searchQuery.isNotEmpty
                  ? (isTelugu
                      ? "'${notifProvider.searchQuery}' సంబంధిత సమాచారం లభించలేదు"
                      : "'${notifProvider.searchQuery}' എന്നതുമായി ബന്ധപ്പെട്ട വിവരങ്ങൾ ലഭ്യമല്ല")
                  : (isTelugu
                      ? "తాజా నోటిఫికేషన్‌లు ఇక్కడ కనిపిస్తాయి"
                      : "പുതിയ അറിയിപ്പുകൾ ഇവിടെ ദൃശ്യമാകും"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state when network fails
  Widget _buildErrorState(
    BuildContext context,
    NotificationsProvider notifProvider,
    bool isTelugu,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40.sp,
              color: const Color(0xFF94A3B8),
            ),
            SizedBox(height: 12.h),
            Text(
              isTelugu ? "కనెక్షన్ లోపం ఏర్పడింది" : "കണക്ഷൻ തകരാർ",
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              isTelugu
                  ? "నోటిఫికేషన్‌లు లోడ్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్ళీ ప్రయత్నించండి."
                  : "അറിയിപ്പുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton.icon(
              onPressed: () {
                notifProvider.fetchNotifications(
                  isRefresh: true,
                  languageCode: isTelugu ? 'te' : 'ml',
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              label: Text(
                isTelugu ? "మళ్ళీ ప్రయత్నించండి" : "വീണ്ടും ശ്രമിക്കുക",
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Discover Tab View (The original discover page content)
  Widget _buildDiscoverTabView(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    return Expanded(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 14.h, bottom: 90.h),
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

          // 4. Editorials Horizontal Grid Slider
          _buildAllEditorialsSection(context, homeProvider, isTelugu),
        ],
      ),
    );
  }

  /// Top Bar with BigTV Post Logo on Left, Animated Bookmarks and Animated Live TV on Right
  Widget _buildTopAppBar(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BigTV Logo
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/BigTvPostLogo.png',
                height: 28.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Bookmarks Shortcut Button
              _buildAnimatedBookmarksButton(context, isTelugu, isDark),

              SizedBox(width: 8.w),

              // Animated Live Broadcast Indicator Button
              _buildAnimatedLiveTvButton(context, homeProvider, isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// Animated Bookmarks Shortcut Button with playful icon tilt and uniform single-dot border rotation
  Widget _buildAnimatedBookmarksButton(
    BuildContext context,
    bool isTelugu,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bookmarkAnimation, _borderAnimation]),
      builder: (context, child) {
        final double borderProgress = _borderAnimation.value;
        final double tiltAngle = math.sin(_bookmarkAnimation.value * 2 * math.pi) * 0.14;
        final double scale = 1.0 + (0.07 * math.sin(_bookmarkAnimation.value * math.pi));

        return Material(
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
            child: CustomPaint(
              foregroundPainter: _SingleDotBorderPainter(
                progress: borderProgress,
                borderRadius: 20.r,
                isDark: isDark,
                strokeWidth: 1.4,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2026) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: tiltAngle,
                      child: Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.bookmark_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Consumer<BookmarksProvider>(
                      builder: (context, provider, _) {
                        final countText = provider.totalBookmarks > 0
                            ? " (${provider.totalBookmarks})"
                            : "";
                        return Text(
                          "${isTelugu ? "బుక్‌మార్క్స్" : "ബുക്ക്‌മാർക്കുകൾ"}$countText",
                          style: TextStyle(
                            color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
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
        );
      },
    );
  }

  /// Animated Live TV Broadcast Indicator Button with Expanding Radar Ripple and uniform single-dot border rotation
  Widget _buildAnimatedLiveTvButton(
    BuildContext context,
    HomeProvider homeProvider,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_livePulseAnimation, _borderAnimation]),
      builder: (context, child) {
        final double borderProgress = _borderAnimation.value;
        final double pulseProgress = _livePulseAnimation.value;

        return Material(
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
            child: CustomPaint(
              foregroundPainter: _SingleDotBorderPainter(
                progress: borderProgress,
                borderRadius: 20.r,
                isDark: isDark,
                strokeWidth: 1.4,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2026) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Pulsing Radar Dot
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Expanding ripple wave ring
                          Transform.scale(
                            scale: 1.0 + (1.25 * pulseProgress),
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFDC2626).withValues(
                                  alpha: (1.0 - pulseProgress).clamp(0.0, 0.75),
                                ),
                              ),
                            ),
                          ),
                          // Core pulsing red dot
                          Transform.scale(
                            scale: 0.85 + (0.25 * math.sin(pulseProgress * math.pi)),
                            child: Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFDC2626),
                                    blurRadius: 4,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "LIVE 24x7",
                      style: TextStyle(
                        color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
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
        );
      },
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
          Expanded(
            child: Row(
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
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
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
                index: 0,
                title: isTelugu ? "ఎడిటోరియల్" : "എഡിറ്റോറിയൽ",
                subtitle: isTelugu ? "ఎడిటోరియల్" : "എഡിറ്റോറിയൽ",
                icon: Icons.article_rounded,
                iconGradient: const [Color(0xFFFF5E62), Color(0xFFFF2A2A)],
                shadowColor: const Color(0xFFFF2A2A).withValues(alpha: 0.25),
                imagePath: 'assets/images/editorial_3d_icon.png',
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

              // 2. E-PAPER (Removed for Malayalam)
              if (isTelugu) ...[
                _buildModernShortcutTile(
                  index: 1,
                  title: "ఈ-పేపర్",
                  subtitle: "E-Paper",
                  icon: Icons.newspaper_rounded,
                  iconGradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                  shadowColor: const Color(0xFFD97706).withValues(alpha: 0.25),
                  imagePath: 'assets/images/epaper_3d_icon.png',
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
              ],

              // 3. GAMES (Dynamic from API)
              _buildModernShortcutTile(
                index: 2,
                title: isTelugu ? "గేమ్స్" : "ഗെയിംസ്",
                subtitle: isTelugu ? "గేమ్స్" : "ഗെയിംസ്",
                icon: Icons.sports_esports_rounded,
                iconGradient: const [Color(0xFF10B981), Color(0xFF059669)],
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                imagePath: 'assets/images/game_3d_icon.png',
                onTap: () => GamesBottomSheet.show(context, isTelugu),
              ),
              SizedBox(width: 10.w),

              // 4. REPORTERS
              _buildModernShortcutTile(
                index: 3,
                title: isTelugu ? "రిపోర్టర్లు" : "റിപ്പോർട്ടർമാർ",
                subtitle: isTelugu ? "రిపోర్టర్లు" : "റിപ്പോർട്ടർമാർ",
                icon: Icons.mic_rounded,
                iconGradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                imagePath: 'assets/images/reporters_3d_icon.png',
                onTap: () {
                  final targetLang = isTelugu ? 'te' : 'ml';
                  final repProvider = context.read<ReportersProvider>();
                  if (repProvider.currentLanguage != targetLang) {
                    repProvider.loadReporters(languageCode: targetLang, force: true);
                  }
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
                index: 4,
                title: isTelugu ? "బుక్‌మార్క్స్" : "ബുക്ക്‌മാർക്കുകൾ",
                subtitle: isTelugu ? "బుక్‌మార్క్స్" : "ബുക്ക്‌മാർക്കുകൾ",
                icon: Icons.bookmark_rounded,
                iconGradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                shadowColor: const Color(0xFFEC4899).withValues(alpha: 0.25),
                imagePath: 'assets/images/bookmarks_3d_icon.png',
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

              // 6. MY FEED / NEWS
              _buildModernShortcutTile(
                index: 5,
                title: isTelugu ? "న్యూస్" : "വാർത്തകൾ",
                subtitle: isTelugu ? "వార్తలు" : "വാർത്തകൾ",
                icon: Icons.dynamic_feed_rounded,
                iconGradient: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.25),
                imagePath: 'assets/images/myfeed_3d_icon.png',
                onTap: () => _navigateToHome(context, homeProvider),
              ),
              SizedBox(width: 10.w),

              // 7. TRENDING
              _buildModernShortcutTile(
                index: 6,
                title: isTelugu ? "ట్రెండింగ్" : "ട്രെൻഡിംഗ്",
                subtitle: isTelugu ? "ట్రెండింగ్" : "ട്രെൻഡിംഗ്",
                icon: Icons.local_fire_department_rounded,
                iconGradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                shadowColor: const Color(0xFFFF416C).withValues(alpha: 0.25),
                imagePath: 'assets/images/trending_3d_icon.png',
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

  /// Modern Squircle Tile for Quick Services with 3D Icon Support
  Widget _buildModernShortcutTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required Color shadowColor,
    required VoidCallback onTap,
    String? imagePath,
    int index = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E2026) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: 78.w,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2E313A) : const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D App Icon with Lottie Micro-Animation
              imagePath != null
                  ? Lottie3DIcon(
                      imagePath: imagePath,
                      width: 46.w,
                      height: 46.w,
                      index: index,
                      shadowColor: shadowColor,
                      fallback: _buildFallback3DIcon(
                        icon: icon,
                        iconGradient: iconGradient,
                      ),
                    )
                  : Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: _buildFallback3DIcon(
                          icon: icon,
                          iconGradient: iconGradient,
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
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

  Widget _buildFallback3DIcon({
    required IconData icon,
    required List<Color> iconGradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: iconGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 22.sp,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.35),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
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
                    child: AnimatedBuilder(
                      animation: _livePulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (0.06 * math.sin(_livePulseAnimation.value * math.pi)),
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.live_tv_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
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
                                SizedBox(
                                  width: 8.w,
                                  height: 8.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _livePulseAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 + (1.2 * _livePulseAnimation.value),
                                            child: Container(
                                              width: 5.w,
                                              height: 5.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFFDC2626).withValues(
                                                  alpha: (1.0 - _livePulseAnimation.value).clamp(0.0, 0.7),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        width: 5.w,
                                        height: 5.w,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDC2626),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
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
                          Flexible(
                            child: Text(
                              "BIG TV 24x7",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
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
                // Frosted Circular Share Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => _shareLiveTv(context, homeProvider, isTelugu),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                      ),
                    ),
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
              ? (homeProvider.isAiTagsLoading
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFED1C24),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isTelugu ? "అంశాలు లోడ్ అవుతున్నాయి..." : "വിഷയങ്ങൾ ലോഡ് ചെയ്യുന്നു...",
                            style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.tag_rounded,
                                size: 22.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            isTelugu ? "డేటా కనుగొనబడలేదు" : "ഡാറ്റ ലഭ്യമല്ല",
                            style: TextStyle(
                              color: const Color(0xFF475569),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            isTelugu ? "సమాచారం అందుబాటులో లేదు" : "വിവരങ്ങൾ ലഭ്യമല്ല",
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ))
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

  /// Editorials Horizontal Grid Slider
  Widget _buildAllEditorialsSection(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editorials = homeProvider.editorialPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: isTelugu ? "ఎడిటోరియల్స్" : "എഡിറ്റോറിയലുകൾ",
          trailing: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditorialScreen()),
              );
            },
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

        if (homeProvider.isEditorialLoading && editorials.isEmpty)
          SizedBox(
            height: 235.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(width: 14.w),
              itemBuilder: (context, index) => _buildHorizontalEditorialShimmer(context),
            ),
          )
        else if (editorials.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2026) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E313A) : const Color(0xFFEDF2F7),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        isTelugu
                            ? "ఎడిటోరియల్స్ అందుబాటులో లేవు"
                            : "എഡിറ്റോറിയലുകൾ ലഭ്യമല്ല",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 236.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics: const BouncingScrollPhysics(),
              itemCount: editorials.length + 1,
              separatorBuilder: (context, index) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                if (index < editorials.length) {
                  final article = editorials[index];
                  return _buildHorizontalEditorialCard(
                    context,
                    homeProvider,
                    article,
                    isTelugu,
                  );
                } else {
                  return _buildViewAllEndCard(context, isTelugu, isDark);
                }
              },
            ),
          ),
      ],
    );
  }

  /// Modern Editorial Grid Card for Horizontal Slider
  Widget _buildHorizontalEditorialCard(
    BuildContext context,
    HomeProvider homeProvider,
    Map<String, dynamic> article,
    bool isTelugu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String title = article['title']?.toString() ?? 'Editorial';
    final String imageUrl = article['image_url']?.toString() ?? '';
    final String publishDate = article['publishDate']?.toString() ?? '';
    final String webUrl = article['link']?.toString() ?? '';
    final String fallbackHost = homeProvider.langCode == 'ml' ? "https://bigtv24x7.com" : "https://www.bigtvlive.com";
    final String targetUrl = webUrl.isNotEmpty
        ? webUrl
        : (article['id'] != null ? "$fallbackHost/?p=${article['id']}" : "");

    return Material(
      color: isDark ? const Color(0xFF1E2026) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          if (targetUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewScreen(
                  webUrl: targetUrl,
                  title: title,
                ),
              ),
            );
          }
        },
        child: Container(
          width: 235.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2E313A) : const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Featured Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                child: SizedBox(
                  height: 120.h,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: isDark ? const Color(0xFF2A2D36) : Colors.grey.shade300,
                            highlightColor: isDark ? const Color(0xFF353944) : Colors.grey.shade100,
                            child: Container(
                              color: isDark ? const Color(0xFF2A2D36) : Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/bigtv_default_post.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/bigtv_default_post.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              // 2. Content Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Date Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            "EDITORIAL",
                            style: TextStyle(
                              color: AppColorTokens.primaryRed,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (publishDate.isNotEmpty)
                          Text(
                            publishDate,
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    // Article Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Footer Row with Logo, "Read More" and Share buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/BigTvPostLogo.png',
                                height: 20.h,
                                width: 20.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 5.w),
                              Flexible(
                                child: Text(
                                  isTelugu ? "చదవండి" : "വായിക്കുക",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColorTokens.primaryRed,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12.sp,
                                color: AppColorTokens.primaryRed,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // WhatsApp Share
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _shareEditorial(context, article, isWhatsAppOnly: true),
                              child: Image.asset(
                                'assets/images/WhatsApp_icon.png',
                                height: 22.w,
                                width: 22.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Native Share
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _shareEditorial(context, article, isWhatsAppOnly: false),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.share_rounded,
                                  color: AppColorTokens.primaryRed,
                                  size: 13.sp,
                                ),
                              ),
                            ),
                          ],
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
  }

  /// "View All" End Card at the end of the Editorial Horizontal Slider
  Widget _buildViewAllEndCard(BuildContext context, bool isTelugu, bool isDark) {
    return Material(
      color: isDark ? const Color(0xFF1E2026) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditorialScreen()),
          );
        },
        child: Container(
          width: 130.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2E313A) : const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColorTokens.primaryRed.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                isTelugu ? "అన్నీ చూడండి" : "എല്ലാം കാണുക",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                isTelugu ? "ఎడిటోరియల్" : "എഡിറ്റോറിയൽ",
                style: TextStyle(
                  color: AppColorTokens.primaryRed,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal Shimmer Card
  Widget _buildHorizontalEditorialShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 235.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2026) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2E313A) : const Color(0xFFEDF2F7),
          width: 1.2,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF2A2D36) : Colors.grey.shade300,
        highlightColor: isDark ? const Color(0xFF353944) : Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 60.w, height: 12.h, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(width: double.infinity, height: 14.h, color: Colors.white),
                  SizedBox(height: 4.h),
                  Container(width: 140.w, height: 14.h, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Editorial Social & WhatsApp Share Handler
  Future<void> _shareEditorial(
    BuildContext context,
    Map<String, dynamic> article, {
    bool isWhatsAppOnly = false,
  }) async {
    final Size size = MediaQuery.of(context).size;
    final String title = article['title']?.toString() ?? 'Editorial';
    final String imageUrl = article['image_url']?.toString() ?? '';
    final String webUrl = article['link']?.toString() ?? '';
    final homeProvider = context.read<HomeProvider>();
    final String fallbackHost = homeProvider.langCode == 'ml' ? "https://bigtv24x7.com" : "https://www.bigtvlive.com";
    final String shareUrl = webUrl.isNotEmpty
        ? webUrl
        : (article['id'] != null ? "$fallbackHost/?p=${article['id']}" : "");

    final List<String> parts = [];
    if (title.isNotEmpty) parts.add(title);
    if (shareUrl.isNotEmpty) parts.add(shareUrl);
    final String shareText = parts.join("\n\n");

    File? imageFile;
    if (imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File(
              '${tempDir.path}/editorial_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await file.writeAsBytes(response.bodyBytes);
          imageFile = file;
        }
      } catch (_) {}
    }

    if (isWhatsAppOnly) {
      try {
        if (imageFile != null && await imageFile.exists()) {
          if (Platform.isIOS) {
            await Share.shareXFiles(
              [XFile(imageFile.path)],
              text: shareText,
              sharePositionOrigin:
                  Rect.fromLTWH(0, 0, size.width, size.height / 2),
            );
          } else {
            try {
              const platform = MethodChannel('com.chotanews/whatsapp');
              await platform.invokeMethod('shareToWhatsApp',
                  {'imagePath': imageFile.path, 'text': shareText});
            } catch (_) {
              await Share.shareXFiles(
                [XFile(imageFile.path)],
                text: shareText,
                sharePositionOrigin:
                    Rect.fromLTWH(0, 0, size.width, size.height / 2),
              );
            }
          }
        } else {
          final String fallbackText =
              imageUrl.isNotEmpty ? "$shareText\n\n$imageUrl" : shareText;
          final String encodedText = Uri.encodeComponent(fallbackText);
          final Uri whatsappUri = Uri.parse("whatsapp://send?text=$encodedText");
          if (await canLaunchUrl(whatsappUri)) {
            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          } else {
            await Share.share(fallbackText);
          }
        }
      } catch (_) {
        await Share.share(shareText);
      }
    } else {
      try {
        if (imageFile != null && await imageFile.exists()) {
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: shareText,
            sharePositionOrigin:
                Rect.fromLTWH(0, 0, size.width, size.height / 2),
          );
        } else {
          await Share.share(
            shareText,
            sharePositionOrigin:
                Rect.fromLTWH(0, 0, size.width, size.height / 2),
          );
        }
      } catch (_) {
        await Share.share(shareText);
      }
    }
  }

  /// Live TV Social & WhatsApp Share Handler
  Future<void> _shareLiveTv(
    BuildContext context,
    HomeProvider homeProvider,
    bool isTelugu,
  ) async {
    final liveData = await homeProvider.fetchLiveTvStream();
    final String channelName = (liveData?['channel_name'] ?? "BIG TV").toString();

    if (!context.mounted) return;
    await LiveTvShareHelper.shareLiveTv(
      context: context,
      channelName: channelName,
      isTelugu: isTelugu,
      langCode: isTelugu ? 'te' : 'ml',
      source: 'discover_banner',
    );
  }
}

/// Single Uniform Animated Dot Border Painter
/// Draws a clean, uniform base border and exactly ONE white highlight dot rotating smoothly along the perimeter
class _SingleDotBorderPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 from uniform linear controller
  final double borderRadius;
  final double strokeWidth;
  final bool isDark;

  _SingleDotBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.isDark,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    // 1. Uniform static base border
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = isDark
          ? const Color(0xFF4A1518).withValues(alpha: 0.75)
          : const Color(0xFFFECACA).withValues(alpha: 0.95);
    canvas.drawRRect(rrect, basePaint);

    // 2. Exactly ONE bright white dot rotating smoothly around the perimeter
    final dotPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 0.4
      ..shader = SweepGradient(
        colors: const [
          Colors.transparent,
          Colors.white,
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [
          0.0,
          0.05,
          0.12,
          1.0,
        ],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleDotBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.isDark != isDark;
}
