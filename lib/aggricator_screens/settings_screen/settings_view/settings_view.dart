import 'dart:developer';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/about_us.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';



import '../../../services/webengage_notification.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../ad_manager_screen/banner_300x50_size.dart';
import '../../chota_info_screens/advertise_with_us.dart';
import '../../chota_info_screens/privacy_policy.dart';
import '../../chota_info_screens/terms_conditions.dart';
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
    // context.read<SettingsProvider>().bannerAd.dispose();
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
     child:  Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsRow(context, "profile.svg", "Edit Profile", () {
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

            height(height: 5.h),
            _buildSettingsRow(context, "Filter.svg", "Filter", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FilterView()));
            }),
            height(height: 5.h),
            // _buildSettingsRow(context, "BookMarks.svg", "Bookmarks", () {
            //   Navigator.push(context, MaterialPageRoute(builder: (context) => SavedArticles()));
            // }),
            // _buildNotificationRow(),

            _buildSettingsRow(context, "Share_our_app.svg", "Share Our App", () {
              _showShareBottomSheet(context);
              // if (Platform.isIOS) {
              //   Share.share("Check out this app: https://apps.apple.com/in/app/chotanews-daily-telugu-news/id1631068092");
              // } else {
              //   Share.share("Check out this app: https://play.google.com/store/apps/details?id=com.chotanews");
              // }
            }),

            height(height: 5.h),

            _buildSettingsRow(context, "Help_support.svg", "Help & Support", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUs(),
                ),
              );
            }),

            height(height: 5.h),
            _buildSettingsRow(context, "Advertise_icon.svg", "Advertise With Us", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvertiseWithUs(),
                ),
              );
            }),
            // height(height: 5.h),
            // _buildSettingsRow(context, "About_app.svg", "Contact Us", () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => InAppWebViewScreen(
            //         webUrl: BaseUrls.contactPage,
            //         title: "Contact Us",
            //       ),
            //     ),
            //   );
            // }),
            height(height: 5.h),
            _buildSettingsRow(context, "Terms_icon.svg", "Terms & Conditions", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsConditions(),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Private_icon.svg", "Privacy Policy", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicy(),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Feedback.svg", "Feedback", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
            }),
            height(height: 5.h),
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
            }),
            height(height: 10),
           context.watch<SettingsProvider>().bannerAdsLoading ==BannerAdsLoading.fail ?SizedBox.shrink(): Banner300x50Size(),


            Spacer(),
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
                  color: AppColors.borderColor,
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
                                color: Colors.black,
                              ),
                            ),
                            height(height: 8),
                            Text(
                              "App Store",
                              style: newAppFont(fontWeight: FontWeight.w600, color: AppColors.headerTextColor),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                                Icons.android,
                                size: 50,
                                color: Colors.green,
                              ),
                            ),
                            height(height: 8),
                            Text(
                              "Play Store",
                              style: newAppFont(fontWeight: FontWeight.w600, color: AppColors.headerTextColor),
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
                      color: AppColors.appButtonColor,
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(1))),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            width(width: 10.w),
            SvgPicture.asset('assets/svg/$iconName', height: 20.w, width: 20.w),
            width(width: 20.w),
            Text(title, style: newAppFont(fontSize: 14.sp, color: AppColors.textColor)),
          ],
        ),
      ),
    );
  }
}
