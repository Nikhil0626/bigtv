import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              // Navigator.pushNamed(context, RoutesManager.homeScreen);
              // print("fgcfcvcv");
            },
            child:  Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          title: Text(
            "Chota News Info",
            style: fontStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 70),
            // About Us Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Card(
                  color: Colors.purple,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.info_outline, color: Colors.white),
                  ),
                ),
                title: const Text(
                  'About Us',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  AboutUs()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Contact Us Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.phone_outlined, color: Colors.white),
                  ),
                ),
                title: const Text(
                  'Contact Us',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactUs()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Advertise With Us Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.tv_outlined, color: Colors.white),
                  ),
                ),
                title: const Text(
                  'Advertise With Us',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdvertiseWithUs()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Terms & Conditions Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Card(
                  color: Colors.deepOrangeAccent,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.article_outlined, color: Colors.white),
                  ),
                ),
                title: const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TermsConditions()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Privacy Policy Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Card(
                  color: Colors.lightGreen,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.lock_clock_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicy()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.purple,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Us",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Chota News is a first-of-its-kind unique mobile media company in the country. We produce and distribute “Made for Mobile Content” to Indian local language audiences.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
