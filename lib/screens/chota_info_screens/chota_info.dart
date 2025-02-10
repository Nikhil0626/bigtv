import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/screens/profile_screen/profile_screen.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/app_router.dart';
import '../new_refer_earn_screen/new_refer_earn_screen.dart';
import '../videos_main/tab_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.settingsPageBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "Settings",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewReferEarnScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                          'assets/settings_icons/refer_earn.svg',
                          height: 40,
                          width: 40,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Refer&Earn',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewReferEarnScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                          'assets/settings_icons/shareapp_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Share app',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactUs()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdvertiseWithUs()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                        SizedBox(width: 16),
                        Text(
                          'Advertise with us',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TermsConditions()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                        SizedBox(width: 16),
                        Text(
                          'Terms and Conditions',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicy()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                        SizedBox(width: 16),
                        Text(
                          'Privacy Policy',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
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
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  sp.clear();
                  Navigator.pushNamed(context, RoutesManager.signInScreen);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[800] : Colors.white,
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
                          'assets/settings_icons/logout_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Logout',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black,
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
            const Spacer(),
            Container(
                height: 40,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "App Version: 1.0.0+2",
                  style: fontStyle(
                    fontSize: 14,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
