import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_enums.dart';
import 'district_view.dart';
import 'categories_view.dart';
import 'otp_verification_view.dart';
import '../authentication_provider/authentication_provider.dart';
import 'login_view.dart';

class LoginBackgroundView extends StatelessWidget {
  const LoginBackgroundView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<AuthenticationProvider>(
      builder: (_, authenticationProvider, __) {
        return Scaffold(
          body: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.65,
                      alignment: Alignment.center,
                      color: AppColors.loginBgColor,
                      padding: EdgeInsets.only(top: 100.sp),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Chota ",
                                style: fontStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 30.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.appButtonColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.r),
                                    bottomLeft: Radius.circular(10.r),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "News",
                                  textAlign: TextAlign.center,
                                  style: fontStyle(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height(height: 10.h),
                         if(authenticationProvider.newAppLoginStatus == NewAppLoginStatus.login)
                         Column(
                           children: [
                             Text(
                               'Get hyperlocal news',
                               style: newAppFont(
                                 fontSize: 18.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             Row(
                               children: [
                                 Padding(
                                   padding:  EdgeInsets.only(top: 10.0,left: MediaQuery.of(context).size.width/4),
                                   child: Text(
                                     'in your local language',
                                     style: newAppFont(
                                       fontSize: 12.sp,
                                       color: Colors.white,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                 ),
                                 SvgPicture.asset("assets/svg/mic.svg",height: 50,)
                               ],
                             ),
                           ],
                         ),
                          if(authenticationProvider.newAppLoginStatus == NewAppLoginStatus.otp)
                         Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Text(
                               'OTP Verification',
                               style: newAppFont(
                                 fontSize: 22.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             height(height: 20),
                             Text(
                               'Please enter the 6-digit code sent to your phone number for verification',
                               textAlign: TextAlign.center,
                               style: newAppFont(
                                 fontSize: 12.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w400,
                               ),
                             ),
                           ],
                         ),
                          if(authenticationProvider.newAppLoginStatus == NewAppLoginStatus.category)
                         Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Text(
                               'Select Topics',
                               style: newAppFont(
                                 fontSize: 24.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             height(height: 20),
                             Text(
                               'Choose categories for personalised news updates and stories',
                               textAlign: TextAlign.center,
                               style: newAppFont(
                                 fontSize: 12.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w400,
                               ),
                             ),
                           ],
                         ),
                          if(authenticationProvider.newAppLoginStatus == NewAppLoginStatus.location)
                         Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Text(
                               'Select Region',
                               style: newAppFont(
                                 fontSize: 24.sp,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             height(height: 20),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 16.0),
                               child: Text(
                                 'Select region to receive hyperlocal news and relevant local information tailored to your area.',
                                 textAlign: TextAlign.center,
                                 style: newAppFont(
                                   fontSize: 12.sp,
                                   color: Colors.white,
                                   fontWeight: FontWeight.w400,
                                 ),
                               ),
                             ),
                           ],
                         )
                        ],
                      ),
                    ),
                    // White Section (Empty Placeholder)
                    Expanded(
                      child: Container(color: Colors.white),
                    ),
                  ],
                ),

                // Login / OTP Verification Widget (Positioned)
                Positioned(
                  bottom: screenHeight * 0.12,
                  left: 0,
                  right: 0,
                  child: authenticationProvider.newAppLoginStatus == NewAppLoginStatus.location
                      ? const DistrictView()
                      : authenticationProvider.newAppLoginStatus == NewAppLoginStatus.category
                          ? CategoriesView()
                          : authenticationProvider.newAppLoginStatus == NewAppLoginStatus.otp
                              ? OtpVerificationView()
                              : LoginView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
