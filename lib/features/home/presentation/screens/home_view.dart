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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';



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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
            return
                Scaffold(
                  body: Stack(
                    children: [
                      PageView(
                        controller: homeProvider.homePageController,
                        physics: NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          homeProvider.onItemTapped(index);
                          context.read<VideoProvider>().pauseVideo();
                        },
                        children: [MainScreenCard(), ReelsScreen(), KeepAlivePage(keepAlive: true, child: SettingsView())],
                      ),
                      if (homeProvider.isBottomEnable && context.watch<SettingsProvider>().bannerAdsLoading != BannerAdsLoading.success)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                              child: Container(
                                height: 64, // increased to accommodate activeIcon border
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                child: BottomNavigationBar(
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
                                      EventRepo().addEvent({
                                        "aiTagName": "more",
                                        "aiTagId": "-4",
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    }
                                  },
                                  selectedItemColor: Colors.white,
                                  unselectedItemColor: Colors.white,
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
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                      activeIcon: Container(
                                        padding: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.white, width: 2)),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/new_app_icon/bytes.svg",
                                          height: 22,
                                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                        ),
                                      ),
                                      label: 'news',
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(
                                        "assets/new_app_icon/reel.svg",
                                        height: 22,
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                      activeIcon: Container(
                                        padding: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.white, width: 2)),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/new_app_icon/reel.svg",
                                          height: 22,
                                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                        ),
                                      ),
                                      label: 'reels',
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(
                                        "assets/new_app_icon/menu.svg",
                                        height: 22,
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                      activeIcon: Container(
                                        padding: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.white, width: 2)),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/new_app_icon/menu.svg",
                                          height: 22,
                                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                        ),
                                      ),
                                      label: 'more',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                  ),
                                ],
                              ),
                  bottomNavigationBar:Platform.isIOS?Consumer<AdMobBannerProvider>(
                    builder: (_, adMobBannerProvider, __) {
                      final currentIndex = adMobBannerProvider.currentPageIndex;
                      final adsList = adMobBannerProvider.adsBanner320x50.values.where((ad) => ad != null).toList();
                      if (adsList.isEmpty) {
                        return const SizedBox.shrink();
                      } else if ((currentIndex + 1) % 5 == 0) {
                        return const SizedBox.shrink();
                      } else {
                        log("siva new ${adsList.last}");
                        return  Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Container(
                            height: 50,
                            width: 320,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Center(child: AdWidget(ad: adsList.last)),
                            ),
                          ),
                        );
                      }
                    },
                  ): SafeArea(
                    child: Consumer<AdMobBannerProvider>(
                      builder: (_, adMobBannerProvider, __) {
                        final currentIndex = adMobBannerProvider.currentPageIndex;
                        final adsList = adMobBannerProvider.adsBanner320x50.values.where((ad) => ad != null).toList();
                        if (adsList.isEmpty) {
                          return const SizedBox.shrink();
                        } else if ((currentIndex + 1) % 5 == 0) {
                          return const SizedBox.shrink();
                        } else {
                          log("siva new ${adsList.last}");
                          return  Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Center(child: AdWidget(ad: adsList[adsList.length-1])),
                          );
                        }
                      },
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }
}
