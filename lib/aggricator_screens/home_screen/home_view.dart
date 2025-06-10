
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_card.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_card.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../services/app_update_servuce.dart';
import '../../services/permission_handler_services.dart';
import '../../services/webengage_notification.dart';
import '../settings_screen/settings_view/settings_view.dart';
import 'home_provider/home_provider.dart';
import 'main_screen_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;

  HomeProvider? homeProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
      requestNotificationPermission();
      homeProvider?.getMobileNumber();
    });
    context.read<HomeProvider>().subscribeToPushCallbacks();
    context.read<HomeProvider>().selectedIndex = 0;
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    // homeProvider?.linkSubscription?.cancel();
    closeSubscribe();
    super.dispose();
  }



  DateTime? lastBackPressed;

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
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      homeProvider.onItemTapped(index);
                    },
                    children: [MainScreenCard(), PapersScreenCard(), ReelsScreen(), SettingsView()],
                  ),
                  if (homeProvider.isBottomEnable && context.watch<SettingsProvider>().bannerAdsLoading != BannerAdsLoading.success)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 6,
                      child: SafeArea(
                        child: Container(
                          height: 58, // reduced height
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
                                _pageController.jumpToPage(index);
                                homeProvider.pageChange(isValue: true);
                                if (homeProvider.selectedIndex == 0) {
                                  context.read<HomeProvider>().setSelectedTagId(0);
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
            );
          },
        ),
      ),
    );
  }
}
