import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/utils/local_data.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../globel_keys/app_router.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_enums.dart';
import '../Auth_module/auth_provider/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LoginStatus loginStatus = LoginStatus.none;

  @override
  void initState() {
    getLogin();
    super.initState();
  }

  Future getLogin() async {
    loginStatus = await getLoginStatus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.settingsPageBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Settings",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            InkWell(
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    RoutesManager.contactUs,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/contactus_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Contact Us',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, RoutesManager.advertiseWithUs);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/advertise_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Advertise with Us',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, RoutesManager.termsConditions);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/terms_conditions_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Terms and conditions',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, RoutesManager.privacyPolicy);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/privacy_policy.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Privacy policy',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
              onTap: () async {
                logoutUser();
                context
                    .read<AuthProvider>()
                    .loginStatus(LoginStatus.none, context);
                SharedPreferences sp = await SharedPreferences.getInstance();
                await sp.setString("loginId", "");
                await sp.clear();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutesManager.signInScreen,
                  (route) => false,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/settings_icons/logout_icon.svg',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        loginStatus == LoginStatus.skip ? 'Login' : 'Logout',
                        style: fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            height(height: 20),
            Container(
                height: 40,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "App Version: 5.0.0+10",
                  style: fontStyle(
                    fontSize: 16,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
