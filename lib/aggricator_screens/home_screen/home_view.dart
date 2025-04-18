import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_card.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/main_screen_list.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_card.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_list.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../services/deviice_details.dart';
import '../../services/permission_handler_services.dart';
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
    requestLocationPermission();
    requestNotificationPermission();
    getMobileNumber();
    context.read<HomeProvider>().selectedIndex = 0;
    _pageController = PageController(initialPage: 0);

    super.initState();
  }

  getMobileNumber() async {
    WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log('APNS Token: $apnsToken');
      getUniqueDeviceId(apnsToken ?? "");
    } else if (Platform.isAndroid) {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        getUniqueDeviceId(token, );
        log('FCM Token: $token');
        _webEngagePlugin.tokenInvalidatedCallback(_onTokenInvalidated);
        WebEngagePlugin.setPushToken(token);
      }
    }
  }

  void _onTokenInvalidated(Map<String, dynamic>? message) {
    print("tokenInvalidated callback received $message");
    WebEngagePlugin.setSecureToken("siva kumar", message.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return Scaffold(
        backgroundColor: Colors.white,
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
                if( context.read<HomeProvider>().selectedIndex != 3)
                CustomSwitch(),
                width(width: 12),
                if( context.read<HomeProvider>().selectedIndex == 0)
                Consumer<HomeProvider>(
                  builder: (_, homeProvider, __) {
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
                        homeProvider.getAllPostList = [];
                        homeProvider.isReloadData();
                        homeProvider.getAllPost();
                      },
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: homeProvider.isReload
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
                            height: 20,
                            width: 20,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    );

                  },
                ),
                if( context.read<HomeProvider>().selectedIndex == 3)
                  Text("V5.0.0+32",style: fontStyle(fontWeight: FontWeight.w900),),
               width(width: 20),
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
          backgroundColor: Colors.white,
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
