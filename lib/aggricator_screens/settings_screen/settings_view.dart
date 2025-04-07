import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_view.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../utils/app_enums.dart';
import '../../utils/local_data.dart';
import '../auth_screens/authentication_view/login_background_view.dart';
import '../book_marks_view/book_marks_screen.dart';
import '../filters_screen/filter_view.dart';
import '../profile_screen/profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key,});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  LoginStatus loginStatus = LoginStatus.none;
  bool isNotificationsEnabled = true;

  @override
  void initState() {
    getLogin();
    context.read<AuthProvider>().sendEvent("SettingsView");
    super.initState();
  }

  Future getLogin() async {
    loginStatus = await getLoginStatus();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // if (loginStatus == LoginStatus.skip)
            _buildSettingsRow(context, "Profile.svg", "Edit Profile", () {
              if (loginStatus == LoginStatus.skip) {
                CustomToast.showErrorToast(msg: 'Please login with mobile number');
              } else if (loginStatus == LoginStatus.loggedIn) {
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
            _buildSettingsRow(context, "BookMarks.svg", "Bookmarks", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SavedArticles()));
            }),
            // _buildNotificationRow(),

            _buildSettingsRow(context, "Share_our_app.svg", "Share Our App", () {
              Share.share("Check out this app: https://play.google.com/store/apps/details?id=com.example.yourapp");
            }),

            height(height: 5.h),

            _buildSettingsRow(context, "Help_support.svg", "Help & Support", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InAppWebViewScreen(
                    webUrl: BaseUrls.aboutPage,
                    title: "About Us", // Add a title here
                  ),
                ),
              );
            }),

            height(height: 5.h),
            _buildSettingsRow(context, "Advertise_icon.svg", "Advertise With Us", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InAppWebViewScreen(
                    webUrl: BaseUrls.advertisePage,
                    title: "Advertise with us",
                  ),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "About_app.svg", "Contact Us", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InAppWebViewScreen(
                    webUrl: BaseUrls.contactPage,
                    title: "Contact Us",
                  ),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Terms_icon.svg", "Terms & Conditions", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InAppWebViewScreen(
                    webUrl: BaseUrls.termsPage,
                    title: "Terms & Conditions",
                  ),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Private_icon.svg", "Privacy Policy", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InAppWebViewScreen(
                    webUrl: BaseUrls.privacyPage,
                    title: "Privacy policy",
                  ),
                ),
              );
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Feedback.svg", "Feedback", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
            }),
            height(height: 5.h),
            _buildSettingsRow(context, "Signout.svg", "Logout", () {

              context.read<AuthenticationProvider>().newAppLoginStatus = NewAppLoginStatus.login;
              context.read<AuthenticationProvider>().saveLoginState();
              // context.read<AuthenticationProvider>().isPageNavigation(context);
              // loginStatus == LoginStatus.skip ? 'Login' : 'Logout';
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginBackgroundView()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, String iconName, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset('assets/svg/$iconName', height: 20, width: 20),
            SizedBox(width: 25),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
//
// Widget _buildNotificationRow() {
//   return Padding(
//     padding: EdgeInsets.symmetric(vertical: 8),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             SvgPicture.asset('assets/svg/Notifications.svg', height: 20, width: 20),
//             SizedBox(width: 15),
//             Text("Notifications", style: TextStyle(fontSize: 16)),
//           ],
//         ),
//         Switch(
//           value: isNotificationsEnabled,
//           onChanged: (value) {
//             setState(() {
//               isNotificationsEnabled = value;
//             });
//           },
//         ),
//       ],
//     ),
//   );
// }
}
