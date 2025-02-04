import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/screens/profile_screen/profile_screen.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appButtonColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24),
          ),
          title: const Text(
            "Settings",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),  // Reduced padding for the body
          child: ListView(
            children: [
              // Refer&Earn Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),  // Adjusted left padding for leading icon
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/refer_earn.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Refer&Earn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewReferEarnScreen()),
                      );
                    },
                  ),
                ),
              ),

              // Share app Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/shareapp_icon.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Share app',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      // Add share app logic here
                    },
                  ),
                ),
              ),

              // Contact Us Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/contactus_icon.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactUs()),
                      );
                    },
                  ),
                ),
              ),

              // Advertise with Us Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/advertise_icon.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Advertise with Us',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdvertiseWithUs()),
                      );
                    },
                  ),
                ),
              ),

              // Terms and Conditions Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/terms_conditions_icon.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditions()),
                      );
                    },
                  ),
                ),
              ),

              // Privacy Policy Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/privacy_policy.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
                      );
                    },
                  ),
                ),
              ),

              // Logout Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),  // Further reduced horizontal padding
                child: Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
                  shadowColor: Colors.black12,
                  elevation: 2,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Card(
                        color: AppColors.appButtonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/settings_icons/logout_icon.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
                      // Add your logout logic here
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
