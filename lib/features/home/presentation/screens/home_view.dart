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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
              body: PageView(
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
              bottomNavigationBar: homeProvider.isBottomEnable
                  ? BottomAppBar(
                      color: AppColorTokens.primaryRed,
                      clipBehavior: Clip.antiAlias,
                      padding: EdgeInsets.zero,
                      height: 64,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ),
                        child: BottomNavigationBar(
                          backgroundColor: Colors.transparent,
                          type: BottomNavigationBarType.fixed,
                          elevation: 0,
                        currentIndex: homeProvider.selectedIndex > 3 ? 3 : homeProvider.selectedIndex,
                        onTap: (index) {
                          context.read<VideoProvider>().pauseVideo();
                          homeProvider.isTabChange();
                          homeProvider.homePageController.jumpToPage(index);
                          homeProvider.pageChange(isValue: true);

                          if (index == 0) {
                            homeProvider.getAllPost();
                            homeProvider.aiTagDataLoaded(false);
                            homeProvider.setSelectedTagId(0);
                            EventRepo().addEvent({
                              "aiTagName": "news",
                              "aiTagId": "-1",
                              "createAt": DateTime.now().toString(),
                            }, "ai_tag_click");
                          } else if (index == 1) {
                            EventRepo().addEvent({
                              "aiTagName": "reels",
                              "aiTagId": "-3",
                              "createAt": DateTime.now().toString(),
                            }, "ai_tag_click");
                          } else if (index == 2) {
                            if (homeProvider.langCode == 'ml') {
                              EventRepo().addEvent({
                                "aiTagName": "premium",
                                "aiTagId": "-6",
                                "createAt": DateTime.now().toString(),
                              }, "ai_tag_click");
                            } else {
                              EventRepo().addEvent({
                                "aiTagName": "epaper",
                                "aiTagId": "-4",
                                "createAt": DateTime.now().toString(),
                              }, "ai_tag_click");
                            }
                          } else if (index == 3) {
                            EventRepo().addEvent({
                              "aiTagName": "more",
                              "aiTagId": "-5",
                              "createAt": DateTime.now().toString(),
                            }, "ai_tag_click");
                          }
                        },
                        selectedItemColor: context.colors.onPrimary,
                        unselectedItemColor: context.colors.onPrimary,
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        iconSize: 22,
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        items: [
                          BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              "assets/new_app_icon/bytes.svg",
                              height: 22,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            activeIcon: Container(
                              padding: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.white, width: 2)),
                              ),
                              child: SvgPicture.asset(
                                "assets/new_app_icon/bytes.svg",
                                height: 22,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                            label: homeProvider.langCode == 'ml' ? 'വാർത്തകൾ' : 'వార్తలు',
                          ),
                          BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              "assets/new_app_icon/reel.svg",
                              height: 22,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            activeIcon: Container(
                              padding: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.white, width: 2)),
                              ),
                              child: SvgPicture.asset(
                                "assets/new_app_icon/reel.svg",
                                height: 22,
                                colorFilter: ColorFilter.mode(context.colors.onPrimary, BlendMode.srcIn),
                              ),
                            ),
                            label: homeProvider.langCode == 'ml' ? 'റീൽസ്' : 'రీల్స్',
                          ),
                          if (homeProvider.langCode == 'ml')
                            BottomNavigationBarItem(
                              icon: Icon(Icons.workspace_premium, color: context.colors.onPrimary, size: 22),
                              activeIcon: Container(
                                padding: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: context.colors.onPrimary, width: 2)),
                                ),
                                child: Icon(Icons.workspace_premium, color: context.colors.onPrimary, size: 22),
                              ),
                              label: homeProvider.langCode == 'ml' ? 'പ്രീമിയം' : 'ప్రీమియం',
                            ),
                          if (homeProvider.langCode != 'ml')
                            BottomNavigationBarItem(
                              icon: Icon(Icons.newspaper, color: context.colors.onPrimary, size: 22),
                              activeIcon: Container(
                                padding: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: context.colors.onPrimary, width: 2)),
                                ),
                                child: Icon(Icons.newspaper, color: context.colors.onPrimary, size: 22),
                              ),
                              label: homeProvider.langCode == 'ml' ? 'ഇ-പേപ്പർ' : 'ఈ-పేపర్',
                            ),
                          BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              "assets/new_app_icon/menu.svg",
                              height: 22,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            activeIcon: Container(
                              padding: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.white, width: 2)),
                              ),
                              child: SvgPicture.asset(
                                "assets/new_app_icon/menu.svg",
                                height: 22,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                            label: homeProvider.langCode == 'ml' ? 'ആൽമരം' : 'మరిన్ని',
                          ),
                        ],
                      ),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
