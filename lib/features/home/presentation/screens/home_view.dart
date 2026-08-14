import 'dart:async';
import 'package:chotanews/core/theme/theme_extensions.dart';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_card.dart';
import 'package:chotanews/features/reels/presentation/screens/reels_view.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chotanews/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:chotanews/features/premium/data/repositories/premium_repo.dart';
import 'package:chotanews/features/premium/presentation/screens/premium_screen.dart';
import 'package:chotanews/services/app_update_servuce.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/webengage_notification.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
// import 'package:social_share/social_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    homeProvider?.isHomeScreen = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
      requestNotificationPermission();
      homeProvider?.getMobileNumber();
      homeProvider?.loadLanguage();
    });
    homeProvider?.initDeepLinks();
    homeProvider?.subscribeToPushCallbacks();
    homeProvider?.selectedIndex = 0;
    homeProvider?.homePageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    closeSubscribe();
    super.dispose();
  }

  DateTime? lastBackPressed;
  Timer? autoCloseTimer;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
        child: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            return Scaffold(
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
                  Screenshot(
                    controller: screenshotController,
                    child: const MainScreenCard(),
                  ),
                  const ReelsScreen(),
                  if (homeProvider.langCode == 'ml')
                    BlocProvider(
                      create: (context) => PremiumBloc(premiumRepo: PremiumRepo()),
                      child: const PremiumScreen(),
                    ),
                  if (homeProvider.langCode != 'ml')
                    const EpaperScreen(),
                  const KeepAlivePage(keepAlive: true, child: SettingsView())
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: homeProvider.isBottomEnable && MediaQuery.of(context).orientation != Orientation.landscape,
                  child: Container(
                    color: AppColorTokens.primaryRed,
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              context,
                              homeProvider,
                              index: 0,
                              iconPath: "assets/new_app_icon/bytes.svg",
                              labelMl: 'വാർത്തകൾ',
                              labelTe: 'వార్తలు',
                            ),
                            _buildNavItem(
                              context,
                              homeProvider,
                              index: 1,
                              iconPath: "assets/new_app_icon/reel.svg",
                              labelMl: 'റീൽസ്',
                              labelTe: 'రీల్స్',
                            ),
                            if (homeProvider.langCode == 'ml')
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 2,
                                iconData: Icons.workspace_premium,
                                labelMl: 'പ്രീമിയം',
                                labelTe: 'ప్రీమియం',
                              ),
                            if (homeProvider.langCode != 'ml')
                              _buildNavItem(
                                context,
                                homeProvider,
                                index: 2,
                                iconData: Icons.newspaper,
                                labelMl: 'ഇ-പേപ്പർ',
                                labelTe: 'ఈ-పేపర్',
                              ),
                            _buildNavItem(
                              context,
                              homeProvider,
                              index: 3,
                              iconPath: "assets/new_app_icon/menu.svg",
                              labelMl: 'ആൽമരം',
                              labelTe: 'మరిన్ని',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            );
          },
        ),
      ),
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
    bool isSelected = (homeProvider.selectedIndex > 3 ? 3 : homeProvider.selectedIndex) == index;
    String label = homeProvider.langCode == 'ml' ? labelMl : labelTe;
    Color itemColor = context.colors.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<VideoProvider>().pauseVideo();
        homeProvider.isTabChange();
        homeProvider.homePageController.jumpToPage(index);
        homeProvider.pageChange(isValue: true);

        if (index == 0) {
          homeProvider.getAllPost();
          homeProvider.aiTagDataLoaded(false);
          homeProvider.setSelectedTagId(0);
          EventRepo().addEvent({"aiTagName": "news", "aiTagId": "-1", "createAt": DateTime.now().toString()}, "ai_tag_click");
        } else if (index == 1) {
          EventRepo().addEvent({"aiTagName": "reels", "aiTagId": "-3", "createAt": DateTime.now().toString()}, "ai_tag_click");
        } else if (index == 2) {
          if (homeProvider.langCode == 'ml') {
            EventRepo().addEvent({"aiTagName": "premium", "aiTagId": "-6", "createAt": DateTime.now().toString()}, "ai_tag_click");
          } else {
            EventRepo().addEvent({"aiTagName": "epaper", "aiTagId": "-4", "createAt": DateTime.now().toString()}, "ai_tag_click");
          }
        } else if (index == 3) {
          EventRepo().addEvent({"aiTagName": "more", "aiTagId": "-5", "createAt": DateTime.now().toString()}, "ai_tag_click");
        }
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: isSelected ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(top: BorderSide(color: itemColor, width: 2)),
                    )
                  : null,
              child: iconPath != null
                  ? SvgPicture.asset(
                      iconPath,
                      height: 22,
                      colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                    )
                  : Icon(
                      iconData,
                      color: itemColor,
                      size: 22,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
