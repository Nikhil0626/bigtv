import 'dart:async';
import 'dart:developer';

import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_card.dart';
import 'package:chotanews/utils/keep_alive_page.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_card.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../services/app_update_servuce.dart';
import '../../../services/daily_dialog_manager.dart';
import '../../../services/permission_handler_services.dart';
import '../../../services/webengage_notification.dart';
import '../../ad_manager_screen/ad_provider/banner_ads_provider.dart';
import '../../events_data/event_repo.dart';
import '../../settings_screen/settings_view/settings_view.dart';
import '../home_provider/home_provider.dart';
import 'main_screen_card.dart';

///This widgets help in stopping the build
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bannerAdsProvider = Provider.of<AdMobBannerProvider>(context, listen: false);
      bannerAdsProvider.loadAd320x50ManagerBanner(0, AdSize.banner);
    });

    homeProvider?.isHomeScreen = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
      requestNotificationPermission();
      homeProvider?.getMobileNumber();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        // checkAndShowPopup();
        DailyDialog.showReferDialog(context: context);
      });
    });
    homeProvider?.initDeepLinks(context);
    homeProvider?.subscribeToPushCallbacks();
    homeProvider?.selectedIndex = 0;
    homeProvider?.homePageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    // homeProvider?.linkSubscription?.cancel();
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
                        },
                        children: [MainScreenCard(), PapersScreenCard(), ReelsScreen(), KeepAlivePage(keepAlive: true, child: SettingsView())],
                      ),
                      if (homeProvider.isBottomEnable && context.watch<SettingsProvider>().bannerAdsLoading != BannerAdsLoading.success)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                            minimum: EdgeInsets.only(left: 16,right: 16, bottom:4),
                            child: Container(
                              height: 56, // reduced height
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
                                borderRadius: BorderRadius.circular(20),
                                child: BottomNavigationBar(
                                  backgroundColor: Colors.white,
                                  type: BottomNavigationBarType.fixed,
                                  currentIndex: homeProvider.selectedIndex,
                                  onTap: (index) {
                                    homeProvider.isTabChange();
                                    homeProvider.homePageController.jumpToPage(index);
                                    homeProvider.pageChange(isValue: true);
                                    if (index == 0) {
                                      context.read<HomeProvider>().setSelectedTagId(0);
                                      EventRepo().addEvent({
                                        "aiTagName": "news",
                                        "aiTagId": "-1",
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    } else if (index == 1) {
                                      EventRepo().addEvent({
                                        "aiTagName": "ePaper",
                                        "aiTagId": "-2",
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    } else if (index == 2) {
                                      EventRepo().addEvent({
                                        "aiTagName": "reels",
                                        "aiTagId": "-3",
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    } else if (index == 3) {
                                      EventRepo().addEvent({
                                        "aiTagName": "more",
                                        "aiTagId": "-4",
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    }
                                    setState(() {});
                                  },
                                  selectedItemColor: AppColors.appButtonColor,
                                  unselectedItemColor: AppColors.bodyTextColor,
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
                                        colorFilter: ColorFilter.mode(
                                          homeProvider.selectedIndex == 0 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: 'news'.tr(),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(
                                        "assets/new_app_icon/paper.svg",
                                        height: 22,
                                        colorFilter: ColorFilter.mode(
                                          homeProvider.selectedIndex == 1 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: 'ePaper'.tr(),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(
                                        "assets/new_app_icon/reel.svg",
                                        height: 22,
                                        colorFilter: ColorFilter.mode(
                                          homeProvider.selectedIndex == 2 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: 'reels'.tr(),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(
                                        "assets/new_app_icon/menu.svg",
                                        height: 22,
                                        colorFilter: ColorFilter.mode(
                                          homeProvider.selectedIndex == 3 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: 'more'.tr(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                  ),
                                ],
                              ),
                  bottomNavigationBar: SafeArea(
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
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: Container(
                              height: 50,
                              width: 320,
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Center(child: AdWidget(ad: adsList[0])),
                              ),
                            ),
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
