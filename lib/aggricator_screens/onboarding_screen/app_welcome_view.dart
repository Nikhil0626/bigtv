// import 'dart:developer';
//
// import 'package:chotanews/aggricator_screens/onboarding_screen/login_view.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../utils/app_fonts.dart';
// import '../../utils/app_spaces.dart';
//
// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//              InkWell(
//               onTap: () {
//                 Locale currentLocale = context.locale;
//
//                 if (currentLocale.languageCode == 'en') {
//                   context.setLocale(Locale('te')); // Switch to Telugu
//                 } else if (currentLocale.languageCode == 'te') {
//                   context.setLocale(Locale('hi')); // Switch to Hindi
//                 } else {
//                   context.setLocale(Locale('en')); // Switch to English
//                 }
//
//                 log("New Locale: ${context.locale.languageCode}");
//               },
//               child: SvgPicture.asset(
//                 'assets/svg/Chota_news_logo.svg',
//                 height: 32.h,
//                 width: 224.w,
//                 alignment: Alignment.centerLeft,
//               ),
//             ),
//             height(height: 40.h),
//             Text(
//               "welcome".tr(),
//               style: TextStyle(
//                   color: Colors.lightBlue,
//                   fontSize: 42.sp,
//                   fontWeight: FontWeight.w300),
//             ),
//             height(height: 5.h),
//             Text(
//               "theBigAppForTheHyperlocalShortNews".tr(),
//               textAlign: TextAlign.center,
//               style: newAppFont(
//                   color: Colors.black,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w500),
//             ),
//             height(height: 10.h),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => OnbordingScreen2()),
//                 );
//               },
//               child: Container(
//                 height: 52.h,
//                 width: 326.w,
//                 margin: EdgeInsets.symmetric(horizontal: 20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.lightBlue,
//                   borderRadius: BorderRadius.all(Radius.circular(25.r)),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   "signInWithMobileNumber".tr(),
//                   style: fontStyle(
//                       fontSize: 16.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             height(height: 20.h),
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 height: 50.h,
//                 margin: EdgeInsets.symmetric(horizontal: 20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.lightBlue[50], // Very very light color
//                   borderRadius: BorderRadius.all(Radius.circular(25.r)),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   "continueAsGuest".tr(),
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'login_view.dart';

class AppWelcomeView extends StatefulWidget {
  const AppWelcomeView({super.key});

  @override
  State<AppWelcomeView> createState() => _AppWelcomeViewState();
}

class _AppWelcomeViewState extends State<AppWelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Column(
            children: [
              Expanded(
                flex: 13, // 65% of the screen
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 7, // 35% of the screen
                child: Container(color: Colors.white),
              ),
            ],
          ),

          // Foreground Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/logo_ChotaNews_black.svg',
                    height: 34.h,
                    width: 237.w,
                  ),
                  height(height: 24.h),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: ' Get hyperlocal news\n',
                          style: newAppFont(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: 'in your local language',
                          style: newAppFont(fontSize: 12.sp, color: Colors.white),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  height(height: 30.h),

                  // White Card
                  Container(
                    height: 361.h,
                    width: 327.w,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Phone Input Field
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 37.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey[50], // Light gray background
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 18.h,
                                      width: 24.w,
                                      child: SvgPicture.asset('assets/svg/indianFlag.svg', fit: BoxFit.cover),
                                    ),
                                    // SizedBox(width: 3.w),

                                    // Used Expanded to avoid overflow issues
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        // Allow only numbers
                                        style: newAppFont(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          hintText: "",
                                          border: InputBorder.none,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly, // Allow only numbers
                                          LengthLimitingTextInputFormatter(10), // Max 10 digits
                                        ],
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'This field cannot be empty';
                                          } else if (value.length < 10) {
                                            return 'Enter exactly 10 digits';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    Icon(Icons.keyboard_arrow_down_outlined, size: 22),
                                    // SizedBox(width: 8.w), // Added gap before the line
                                    Container(
                                      height: 32.h,
                                      width: 1.w, // Thin vertical border line
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        height(height: 10.h),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: 'By clicking on Login/Signup you consent to our\n',
                            style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' and ',
                                style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                              ),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),

                        height(height: 40.h),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text('Log In / Signup', style: newAppFont(color: Colors.white)),
                        ),

                        height(height: 40.h),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Or', style: newAppFont(color: Colors.black54)),
                            ),
                            Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                          ],
                        ),
                        height(height: 60.h),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text('Continue as Guest', style: newAppFont(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
