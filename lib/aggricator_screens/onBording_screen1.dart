import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_fonts.dart';
import '../utils/app_spaces.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/Chota_news_logo.svg',
              height: 32,
              width: 223,
            ),
            height(height: 40),
            Text(
              "Welcome",
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 42,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              "The Big App for the Hyperlocal short news",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            height(height: 40),
            InkWell(
              onTap: () {},
              child: Container(
                height: 50,
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Sign in with mobile number",
                  style: fontStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            height(height: 20),
            InkWell(
              onTap: () {},
              child: Container(
                height: 50,
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50], // Very very light color
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
