import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_card.dart';
import 'package:chotanews/features/reels/presentation/screens/reels_view.dart';
import 'package:chotanews/services/app_update_servuce.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/webengage_notification.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeProvider? homeProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);

    homeProvider?.isHomeScreen = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
      requestNotificationPermission();
      homeProvider?.getMobileNumber();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColorTokens.primaryRed,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (lastBackPressed == null || now.difference(lastBackPressed!) > Duration(seconds: 2)) {
            lastBackPressed = now;
            CustomToast.showInfoToast(msg: "Swipe again to exit");
            return false;
          }
          return true;
        },
        child: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            return Scaffold(
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
                          MainScreenCard(),
                          ReelsScreen(),
                          KeepAlivePage(keepAlive: true, child: SettingsView()),
                        ],
                      ),
                      if (homeProvider.isBottomEnable && context.watch<SettingsProvider>().bannerAdsLoading != BannerAdsLoading.success)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: AppColorTokens.primaryRed,
                            child: SafeArea(
                              top: false,
                              child: BottomNavigationBar(
                                elevation: 0,
                                backgroundColor: AppColorTokens.primaryRed,
                              type: BottomNavigationBarType.fixed,
                              currentIndex: homeProvider.selectedIndex,
                              onTap: (index) {
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
                                  EventRepo().addEvent({"aiTagName": "more", "aiTagId": "-4", "createAt": DateTime.now().toString()}, "ai_tag_click");
                                }
                              },
                              selectedItemColor: Colors.white,
                              unselectedItemColor: Colors.white70,
                              selectedFontSize: 11,
                              unselectedFontSize: 11,
                              iconSize: 22,
                              showSelectedLabels: true,
                              showUnselectedLabels: true,
                              items: [
                                 BottomNavigationBarItem(
                                   icon: SvgPicture.asset("assets/new_app_icon/bytes.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn)),
                                   activeIcon: Column(mainAxisSize: MainAxisSize.min, children: [
                                     Container(height: 2, width: 28, color: Colors.white),
                                     const SizedBox(height: 4),
                                     SvgPicture.asset("assets/new_app_icon/bytes.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                                   ]),
                                   label: 'news'.tr(),
                                 ),
                                BottomNavigationBarItem(
                                  icon: SvgPicture.asset("assets/new_app_icon/reel.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn)),
                                  activeIcon: Column(mainAxisSize: MainAxisSize.min, children: [
                                    Container(height: 2, width: 28, color: Colors.white),
                                    const SizedBox(height: 4),
                                    SvgPicture.asset("assets/new_app_icon/reel.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                                  ]),
                                  label: 'reels'.tr(),
                                ),
                                BottomNavigationBarItem(
                                  icon: SvgPicture.asset("assets/new_app_icon/menu.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn)),
                                  activeIcon: Column(mainAxisSize: MainAxisSize.min, children: [
                                    Container(height: 2, width: 28, color: Colors.white),
                                    const SizedBox(height: 4),
                                    SvgPicture.asset("assets/new_app_icon/menu.svg", height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                                  ]),
                                  label: 'more'.tr(),
                                ),
                              ],
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
}
