import 'dart:async';
import 'package:chotanews/core/theme/theme_extensions.dart';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_card.dart';
import 'package:chotanews/features/reels/presentation/screens/reels_view.dart';
import 'package:chotanews/features/events/presentation/widgets/folk_night_floating_button.dart';
import 'package:chotanews/features/home/presentation/screens/live_tv_screen.dart';
import 'package:chotanews/features/home/presentation/screens/search_discover_screen.dart';
import 'package:chotanews/services/app_update_servuce.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/widgets/epaper_first_open_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeProvider? homeProvider;
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);

    homeProvider?.isHomeScreen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
      requestNotificationPermission();
      homeProvider?.getMobileNumber();
      homeProvider?.loadLanguage();
      _sendDeviceDetails();
      _checkAndShowFirstOpenEpaperPopup();
      homeProvider?.processPendingDeepLink();
    });
    homeProvider?.initDeepLinks();
    homeProvider?.subscribeToPushCallbacks();
    homeProvider?.selectedIndex = 1;
    homeProvider?.homePageController = PageController(initialPage: 1);
    if (homeProvider?.getAllPostList.isEmpty == true ||
        (homeProvider?.postsLanguage != null && homeProvider?.postsLanguage != homeProvider?.langCode)) {
      homeProvider?.getAllPost(isGetAllPost: true);
    }
    super.initState();
  }

  Future<void> _checkAndShowFirstOpenEpaperPopup() async {
    try {
      if (homeProvider?.hasPendingDeepLink == true || homeProvider?.isRoutingDeepLink == true) {
        return;
      }
      final bool shouldShow = await shouldShowEpaperFirstOpenDialog();
      if (!shouldShow) return;

      // Small delay so home screen loads smoothly before modal appears
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      final String langCode = homeProvider?.langCode ?? 'te';
      if (langCode == 'ml') return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kFirstOpenEpaperPopupShownKey, true);

      if (mounted) {
        showEpaperFirstOpenDialog(context);
      }
    } catch (e) {
      debugPrint("Error checking first open epaper popup: $e");
    }
  }

  Future<void> _sendDeviceDetails() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String token = await getAppFcmToken() ?? "";
      String? deviceId = preferences.getString("deviceId");
      String? userId = preferences.getString("userId");
      String langCode = preferences.getString("selectedLanguageCode") ?? "te";
      homeProvider?.loadLanguage();

      homeProvider?.sendDeviceDetailsApi(
        userId: userId ?? "0",
        deviceId: deviceId ?? "",
        fcmToken: token,
        lan: langCode,
      );
    } catch (e) {
      debugPrint("Error sending device details: $e");
    }
  }

  @override
  void dispose() {
    homeProvider?.isHomeScreen = false;
    super.dispose();
  }

  DateTime? lastBackPressed;
  Timer? autoCloseTimer;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, __) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final bool isSearchTab = homeProvider.selectedIndex == 0;

        final Color systemStatusBarColor = isSearchTab
            ? AppColorTokens.primaryRed
            : (isDark ? const Color(0xFF0F0F12) : Colors.white);

        final bool isSystemDark = isSearchTab || isDark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: systemStatusBarColor,
            statusBarIconBrightness: isSystemDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isSystemDark ? Brightness.dark : Brightness.light,
          ),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final now = DateTime.now();
              if (lastBackPressed == null || now.difference(lastBackPressed!) > Duration(seconds: 2)) {
                lastBackPressed = now;
                CustomToast.showInfoToast(msg: "Swipe again to exit");
                return;
              }
              SystemNavigator.pop();
            },
            child: Scaffold(
              backgroundColor: systemStatusBarColor,
              extendBody: true,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: null,
              body: Stack(
                children: [
                  PageView(
                    controller: homeProvider.homePageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  homeProvider.onItemTapped(index);
                  context.read<VideoProvider>().pauseVideo();
                },
                children: [
                  // Index 0: Search
                  SearchDiscoverScreen(
                    onGoToHome: () {
                      homeProvider.onItemTapped(1);
                      homeProvider.homePageController.jumpToPage(1);
                    },
                  ),
                  // Index 1: Home
                  Screenshot(
                    controller: screenshotController,
                    child: const MainScreenCard(),
                  ),
                  // Index 2: Bigtv daily (Reels)
                  const ReelsScreen(),
                  // Index 3: Marrini (Settings)
                  const KeepAlivePage(keepAlive: true, child: SettingsView()),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: !homeProvider.isCurrentArticleGrid &&
                      !homeProvider.isCurrentArticleShowAlert &&
                      !homeProvider.isCurrentArticleBulletin &&
                      homeProvider.isBottomEnable &&
                      MediaQuery.of(context).orientation != Orientation.landscape,
                  child: Container(
                    color: const Color(0xFFF03B5A),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 1. Search button
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 0,
                                iconData: Icons.search_rounded,
                                labelMl: 'തിരയുക',
                                labelTe: 'శోధన',
                              ),
                              // 2. Live button
                              _buildLiveTvNavItem(context, homeProvider),
                              // 3. Home button
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 1,
                                iconPath: "assets/new_app_icon/bytes.svg",
                                labelMl: 'വാർത്തകൾ',
                                labelTe: 'వార్తలు',
                              ),
                              // 4. Bigtv daily button
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 2,
                                iconPath: "assets/new_app_icon/reel.svg",
                                labelMl: 'ബിഗ് ടിവി ഡെയ്‌ലി',
                                labelTe: 'బిగ్‌టీవీ డైలీ',
                              ),
                              // 5. Marrini button
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 3,
                                iconPath: "assets/new_app_icon/menu.svg",
                                labelMl: 'കൂടുതൽ',
                                labelTe: 'మరిన్ని',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ),
              if (homeProvider.langCode != 'ml')
                Positioned(
                  bottom: (!homeProvider.isCurrentArticleGrid &&
                          !homeProvider.isCurrentArticleShowAlert &&
                          !homeProvider.isCurrentArticleBulletin &&
                          homeProvider.isBottomEnable &&
                          MediaQuery.of(context).orientation != Orientation.landscape)
                      ? (50.0 + MediaQuery.of(context).padding.bottom + 12.0)
                      : (MediaQuery.of(context).padding.bottom + 16.0),
                  right: 16.0,
                  child: Visibility(
                    visible: homeProvider.folkNight &&
                        homeProvider.langCode != 'ml' &&
                        !homeProvider.isCurrentArticleGrid &&
                        !homeProvider.isCurrentArticleShowAlert &&
                        !homeProvider.isCurrentArticleBulletin &&
                        MediaQuery.of(context).orientation != Orientation.landscape,
                    child: const FolkNightFloatingButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildNavItem(
    BuildContext context,
    HomeProvider homeProvider, {
    required int index,
    String? iconPath,
    IconData? iconData,
    required String labelMl,
    required String labelTe,
  }) {
    bool isSelected = homeProvider.selectedIndex == index;
    String label = homeProvider.langCode == 'ml' ? labelMl : labelTe;
    Color itemColor = context.colors.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<VideoProvider>().pauseVideo();
        final itemNames = ['search', 'news', 'reels', 'more'];
        final itemName = index < itemNames.length ? itemNames[index] : index.toString();
        AnalyticsService.instance.track(AnalyticsEventName.bottomNavClick, properties: {
          'item_name': itemName,
          'destination': itemName,
        });
        AnalyticsService.instance.track(AnalyticsEventName.navigationClick, properties: {
          'type': 'bottom_nav',
          'destination': itemName,
        });
        homeProvider.isTabChange();
        homeProvider.homePageController.jumpToPage(index);
        homeProvider.pageChange(isValue: true);

        if (index == 0) {
          EventRepo().addEvent({"aiTagName": "search", "aiTagId": "-2", "createAt": DateTime.now().toString()}, "ai_tag_click");
        } else if (index == 1) {
          if (homeProvider.getAllPostList.isEmpty) {
            homeProvider.getAllPost();
          }
          homeProvider.aiTagDataLoaded(false);
          homeProvider.setSelectedTagId(0);
          EventRepo().addEvent({"aiTagName": "news", "aiTagId": "-1", "createAt": DateTime.now().toString()}, "ai_tag_click");
        } else if (index == 2) {
          EventRepo().addEvent({"aiTagName": "reels", "aiTagId": "-3", "createAt": DateTime.now().toString()}, "ai_tag_click");
        } else if (index == 3) {
          EventRepo().addEvent({"aiTagName": "more", "aiTagId": "-5", "createAt": DateTime.now().toString()}, "ai_tag_click");
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: isSelected ? const EdgeInsets.only(top: 2) : EdgeInsets.zero,
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(top: BorderSide(color: itemColor, width: 2)),
                    )
                  : null,
              child: iconPath != null
                  ? SvgPicture.asset(
                      iconPath,
                      height: 20,
                      colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                    )
                  : Icon(
                      iconData,
                      color: itemColor,
                      size: 20,
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTvNavItem(BuildContext context, HomeProvider homeProvider) {
    String label = homeProvider.langCode == 'ml' ? 'ലൈവ് ടിവി' : 'లైవ్ టీవీ';
    Color itemColor = context.colors.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        AnalyticsService.instance.track(AnalyticsEventName.bottomNavClick, properties: {
          'item_name': 'live_tv',
          'destination': 'live_tv',
        });
        try {
          context.read<VideoProvider>().pauseVideo();
        } catch (_) {}
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
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            homeProvider.isLiveTvLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: itemColor,
                    ),
                  )
                : Icon(
                    Icons.live_tv_rounded,
                    color: itemColor,
                    size: 20,
                  ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

