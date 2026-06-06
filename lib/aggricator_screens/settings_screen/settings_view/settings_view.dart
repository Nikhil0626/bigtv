import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/about_us.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/referral_screen/referral_view/refer_earn.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/theme_provider.dart';

import '../../../services/webengage_notification.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../ad_manager_screen/ad_screen/banner_300x50_size.dart';
import '../../chota_info_screens/advertise_with_us.dart';
import '../../chota_info_screens/privacy_policy.dart';
import '../../chota_info_screens/terms_conditions.dart';
import '../../contest_screen/contest_screen.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import 'filters_screen/filter_view.dart';
import 'profile_view.dart';
import 'feedback_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  NewAppLoginStatus loginStatus = NewAppLoginStatus.none;
  bool isNotificationsEnabled = false;
  String appVersion = "";

  @override
  void initState() {
    getLogin();
    context.read<AuthenticationProvider>().sendEvent("SettingsView");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    appVersion = sp.getString("app_version") ?? "";
    isNotificationsEnabled = sp.getString("loginType") == "login" ? true : false;
    log(isNotificationsEnabled.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSettingsRow(context, "profile.png", "Edit Profile", () {
                    EventRepo().addEvent({
                      "visitPageName":"Edit Profile",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    if (isNotificationsEnabled == false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginBackgroundView()),
                      );
                    } else if (isNotificationsEnabled == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileView()),
                      );
                    }
                  }),
                  // else
                  SizedBox.shrink(),

                  _buildThemeToggle(context),

                  _buildSettingsRow(context, "Filter.svg", "Filter", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FilterView()));
                  }),
                  //
                  // _buildSettingsRow(context, "Share_our_app.svg", "Share Our App", () async {
                  //   _showShareBottomSheet(context);
                  // }),

                  _buildSettingsRow(context, "Help_support.svg", "Help & Support", () {
                    EventRepo().addEvent({
                      "visitPageName": "Help & Support",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutUs(),
                      ),
                    );
                  }),

                  _buildSettingsRow(context, "Advertise_icon.svg", "Advertise With Us", () {
                    EventRepo().addEvent({
                      "visitPageName": "Advertise With Us",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvertiseWithUs(),
                      ),
                    );
                  }),

                  _buildSettingsRow(context, "Terms_icon.svg", "Terms & Conditions", () {
                    EventRepo().addEvent({
                      "visitPageName": "Terms & Conditions",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsConditions(),
                      ),
                    );
                  }),
                  // height(height: 5.h),
                  // _buildSettingsRow(context, "HandCoinss.svg", "Refer And Earn", () {
                  //   // EventRepo().addEvent({
                  //   //   "visitPageName": "Terms & Conditions",
                  //   //   "createAt": DateTime.now().toString(),
                  //   // }, "compliance_section");
                  //   if(!isNotificationsEnabled ){
                  //     CustomToast.showErrorToast(msg: "Your currently using your application in guest mode please login and join your Refer & Earn contest",timeDuration: 3);
                  //   }else{
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => ReferEarn(),
                  //       ),
                  //     );
                  //   }
                  // }
                  // ),
                  _buildSettingsRow(context, "Private_icon.svg", "Privacy Policy", () {
                    EventRepo().addEvent({
                      "visitPageName": "Privacy Policy",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicy(),
                      ),
                    );
                  }),
                  _buildSettingsRow(context, "Feedback.svg", "Feedback", () {
                    EventRepo().addEvent({
                      "visitPageName": "Feedback",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
                  }),
                  _buildSettingsRow(context, "contest.svg", "Ads Contest", () {
                    EventRepo().addEvent({
                      "visitPageName": "Contest",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ContestScreen()));
                  }),
                  _buildSettingsRow(context, "Signout.svg", !isNotificationsEnabled ? "Login" : "Logout", () async {
                    closeSubscribe();
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    String? deviceId = preferences.getString("deviceId");
                    String? userId = preferences.getString("userId");

                    WebEngagePlugin.trackEvent('logout_user', {
                      "device_id": "${deviceId}",
                      "date_time": DateTime.now().toString(),
                      "user_id": userId ?? "",
                    });
                    WebEngagePlugin.userLogout();
                    context.read<AuthenticationProvider>().setLogOutStatus(context, false);
                    EventRepo().addEvent({
                      "loginType": "logout",
                      "mobileNumber": "",
                      "createAt": DateTime.now().toString(),
                    }, "login_event");
                  }),
                  height(height: 10),
                ],
              ),
            ),),
            //context.watch<SettingsProvider>().bannerAdsLoading == BannerAdsLoading.fail ? SizedBox.shrink() : Banner300x50Size(),

            //Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Text(
                "V$appVersion",
                style: fontStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.35,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share Our App",
                  style: homeScreenFontStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                height(height: 10),
                Divider(
                  height: 1,
                  color: context.borderColor,
                ),
                height(height: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          EventRepo().addEvent({
                            "shareApp": Platform.isIOS ? "iOS" : "Android",
                            "createAt": DateTime.now().toString(),
                          }, "share_app");
                          Share.share(
                            "Check out this app: https://apps.apple.com/in/app/chotanews-daily-telugu-news/id1631068092",
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.apple,
                                size: 50,
                                color: context.textColor,
                              ),
                            ),
                            height(height: 8),
                              Text(
                                "App Store",
                                style: context.typography.titleMedium,
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          EventRepo().addEvent({
                            "shareApp": Platform.isIOS ? "iOS" : "Android",
                            "createAt": DateTime.now().toString(),
                          }, "share_app");
                          Share.share(
                            "Check out this app: https://play.google.com/store/apps/details?id=com.chotanews",
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.android,
                                size: 50,
                                color: Colors.green,
                              ),
                            ),
                            height(height: 8),
                              Text(
                                "Play Store",
                                style: context.typography.titleMedium,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                height(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 35.h,
                    // margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: context.typography.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                height(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsRow(BuildContext context, String iconName, String title, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                iconName =="profile.png"?Image.asset('assets/svg/$iconName',height: 24.w, width: 24.w, color: context.iconTheme.color): SvgPicture.asset('assets/svg/$iconName', height: 24.w, width: 24.w, colorFilter: ColorFilter.mode(context.iconTheme.color ?? Colors.grey, BlendMode.srcIn)),
                width(width: 16.w),
                Text(title, style: context.typography.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: context.subtitleColor),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: context.borderColor.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      children: [
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.dark_mode, size: 24, color: context.iconTheme.color),
              width(width: 16.w),
              Text("Dark Mode", style: context.typography.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Spacer(),
              Switch(
                value: themeProvider.isDarkMode,
                activeColor: context.primaryColor,
                onChanged: (val) {
                  themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.borderColor.withOpacity(0.3)),
      ],
    );
  }
}
