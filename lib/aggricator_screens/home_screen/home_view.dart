import 'dart:developer';

import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_card.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/main_screen_list.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_card.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_list.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/home_screen/home_provider/provider.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../utils/custom_switch.dart';
import '../e_papers_screens/paper_view/papers_screen_list.dart';
import '../settings_screen/settings_view/settings_view.dart';
import 'main_screen_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes back arrow
          backgroundColor: Colors.white,
          elevation: 0,
          title:Row(
            children: [
              Text(
                "Chota",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                // margin: EdgeInsets.only(left: 1),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  "News",
                  style: fontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            // Shift actions closer to the title
            Row(
              children: [
                CustomSwitch(),
                const SizedBox(width: 12),
                Consumer<FlipProvider>(
                  builder: (_, flipProvider, __) {
                    return InkWell(
                      onTap: () {
                        log("Refresh");
                        EventRepo().sendEvent({
                          "key": "reload",
                          "data": {
                            "device_id": "${GlobalVariables().deviceId}",
                            "userId": GlobalVariables().userId ?? "",
                          }
                        });
                        flipProvider.getArticles(refresh: true);
                      },
                      child: Center(
                        child: flipProvider!.isRefresh
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.iconColors,
                          ),
                        )
                            : SvgPicture.asset(
                          "assets/svg/new_refresh.svg",
                          height: 24,
                          width: 24,
                          color: AppColors.textColor,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),


        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            homeProvider.onItemTapped(index);
          },
          children: [
            homeProvider.isSwitched ? MainScreenList() : MainScreenCard(),
            homeProvider.isSwitched ? PapersScreenList() : PapersScreenCard(),
            homeProvider.isSwitched ? ReelsScreenList() : ReelsScreen(),
            SettingsView()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          //
          currentIndex: homeProvider.selectedIndex,
          onTap: (index) {
            homeProvider.isTabChange();
            _pageController.jumpToPage(index); // Change the page when tapping the bottom bar
          },
          selectedItemColor: AppColors.appButtonColor,
          // Highlight color
          unselectedItemColor: AppColors.bodyTextColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedLabelStyle: fontStyle(fontWeight: FontWeight.normal, fontSize: 14),
          selectedLabelStyle: fontStyle(fontWeight: FontWeight.w600, fontSize: 14),
          // Emphasized label
          items: [
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  if (homeProvider.selectedIndex == 0)
                    Container(
                      width: 50,
                      height: 3,
                      color: Colors.blue, // Small bar under icon
                    ),
                  height(height: 4),
                  SvgPicture.asset(
                    "assets/new_app_icon/bytes.svg",
                    colorFilter: ColorFilter.mode(
                      homeProvider.selectedIndex == 0 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              label: 'news'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  if (homeProvider.selectedIndex == 1)
                    Container(
                      width: 50,
                      height: 3,
                      color: Colors.blue,
                    ),
                  height(height: 4),
                  SvgPicture.asset("assets/new_app_icon/paper.svg",
                      colorFilter: ColorFilter.mode(
                        homeProvider.selectedIndex == 1 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                        BlendMode.srcIn,
                      )),
                ],
              ),
              label: 'ePaper'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  if (homeProvider.selectedIndex == 2)
                    Container(
                      width: 50,
                      height: 3,
                      color: Colors.blue,
                    ),
                  height(height: 4),
                  SvgPicture.asset("assets/new_app_icon/reel.svg",
                      colorFilter: ColorFilter.mode(
                        homeProvider.selectedIndex == 2 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                        BlendMode.srcIn,
                      )),
                ],
              ),
              label: 'reels'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  if (homeProvider.selectedIndex == 3)
                    Container(
                      width: 50,
                      height: 3,
                      color: Colors.blue,
                    ),
                  height(height: 4),
                  SvgPicture.asset("assets/new_app_icon/menu.svg",
                      colorFilter: ColorFilter.mode(
                        homeProvider.selectedIndex == 3 ? AppColors.appButtonColor : AppColors.bodyTextColor,
                        BlendMode.srcIn,
                      )),
                ],
              ),
              label: 'more'.tr(),
            ),
          ],
        ),
      );
    });
  }
}
