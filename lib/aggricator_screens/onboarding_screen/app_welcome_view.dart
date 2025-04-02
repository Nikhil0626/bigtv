import 'dart:developer';

import 'package:chotanews/aggricator_screens/onboarding_screen/otp_verification_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             InkWell(
              onTap: () {
                Locale currentLocale = context.locale;

                if (currentLocale.languageCode == 'en') {
                  context.setLocale(Locale('te')); // Switch to Telugu
                } else if (currentLocale.languageCode == 'te') {
                  context.setLocale(Locale('hi')); // Switch to Hindi
                } else {
                  context.setLocale(Locale('en')); // Switch to English
                }

                log("New Locale: ${context.locale.languageCode}");
              },
              child: SvgPicture.asset(
                'assets/svg/Chota_news_logo.svg',
                height: 32.h,
                width: 224.w,
                alignment: Alignment.centerLeft,
              ),
            ),
            height(height: 40.h),
            Text(
              "welcome".tr(),
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w300),
            ),
            height(height: 5.h),
            Text(
              "TheBigAppForTheHyperlocalShortNews".tr(),
              textAlign: TextAlign.center,
              style: newAppFont(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            ),
            height(height: 10.h),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OTPVerificationScreen()),
                );
              },
              child: Container(
                height: 52.h,
                width: 326.w,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.all(Radius.circular(25.r)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "SignInWithMobileNumber".tr(),
                  style: fontStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            height(height: 20.h),
            InkWell(
              onTap: () {},
              child: Container(
                height: 50.h,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50], // Very very light color
                  borderRadius: BorderRadius.all(Radius.circular(25.r)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "continueAsGuest".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
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
