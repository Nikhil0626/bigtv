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
import '../videos_main/tab_screen.dart';

class ChotaInfo extends StatelessWidget {
  const ChotaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        body: ListView(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Card
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/profile_icon.svg',
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                title: Text(
                  'Profile',
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
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
            ),

            // Refer&Earn Card
             const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
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
                    MaterialPageRoute(builder: (context) => AboutUs()),
                  );
                },
              ),
            ),

            // Share app Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUs()),
                  );
                },
              ),
            ),

            // Contact Us Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/contactus_icon.svg',  // Add the correct asset path
                      height: 30,
                      width: 30,
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
                    MaterialPageRoute(builder: (context) => ContactUs()),
                  );
                },
              ),
            ),

            // Advertise with Us Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/advertise_icon.svg',  // Add the correct asset path
                      height: 30,
                      width: 30,
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
                    MaterialPageRoute(builder: (context) => AdvertiseWithUs()),
                  );
                },
              ),
            ),

            // Terms and Conditions Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/terms_conditions_icon.svg',  // Add the correct asset path
                      height: 30,
                      width: 30,
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
                    MaterialPageRoute(builder: (context) => TermsConditions()),
                  );
                },
              ),
            ),

            // Privacy Policy Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/privacy_policy.svg',  // Add the correct asset path
                      height: 30,
                      width: 30,
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
                    MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                  );
                },
              ),
            ),

            // Logout Card
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
            Card(
              color: isDarkTheme ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shadowColor: Colors.black12,
              elevation: 2,
              child: ListTile(
                leading: Card(
                  color: AppColors.appButtonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/settings_icons/logout_icon.svg',  // Add the correct asset path
                      height: 30,
                      width: 30,
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

            const Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Locations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
