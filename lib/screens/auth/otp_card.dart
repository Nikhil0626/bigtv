import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

import '../../utils/app_buttons.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_strings.dart';
import 'auth_provider.dart';

class OtpCard extends StatelessWidget {
  const OtpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, authProvider, __) {
      return Card(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 30.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  authProvider.changeType(LoginType.login);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_sharp,
                      size: 20.sp,
                    ),
                    width(width: 15),
                    Text(
                      AppStrings.backToSign,
                      style: fontStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              height(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 10.0.sp),
                child: Image.asset(
                  "assets/signup.png",
                  height: 40.h,
                  width: 30.w,
                ),
              ),
              height(height: 10),
              Text(
                "OTP verification",
                style: fontStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              height(height: 2),
              Text(
                "We will send you a one time password on your email ${authProvider.otpEmail.text} please enter the OTP sent.",
                style: fontStyle(color: Colors.black, fontSize: 12),
              ),
              height(height: 15),
              SizedBox(
                height: 40,
                child: Pinput(
                  length: 6, // Length of the PIN
                  onCompleted: (pin) {
                    authProvider.saveOtp(pin);
                  },
                  onChanged: (value) => print('Current Value: $value'),
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: fontStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.green),
                    ),
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children:
              //
              //
              //   // List.generate(6, (index) {
              //   //   return SizedBox(
              //   //     width: 50.w,
              //   //     height: 50.w,
              //   //     child: Padding(
              //   //       padding: EdgeInsets.all(3.0.sp),
              //   //       child: TextField(
              //   //         textAlign: TextAlign.center,
              //   //         keyboardType: TextInputType.number,
              //   //         maxLength: 1,
              //   //         style: const TextStyle(
              //   //           fontSize: 14,
              //   //           fontWeight: FontWeight.bold,
              //   //           // letterSpacing: ,
              //   //         ),
              //   //         decoration: InputDecoration(
              //   //           counterText: "",
              //   //           filled: true,
              //   //           fillColor: Colors.white,
              //   //           enabledBorder: OutlineInputBorder(
              //   //             borderRadius: BorderRadius.circular(25.sp),
              //   //             borderSide: const BorderSide(color: Colors.grey),
              //   //           ),
              //   //           focusedBorder: OutlineInputBorder(
              //   //             borderRadius: BorderRadius.circular(25.sp),
              //   //             borderSide: const BorderSide(color: Colors.blue),
              //   //           ),
              //   //         ),
              //   //         onChanged: (value) {
              //   //           if (value.isNotEmpty && index < 5) {
              //   //             authProvider.otpValues[index] = value;
              //   //             FocusScope.of(context).nextFocus();
              //   //           }  else {
              //   //             authProvider.otpValues[index] = '';
              //   //
              //   //             if (index > 0) FocusScope.of(context).previousFocus();
              //   //           }
              //   //           if (authProvider.otpValues.contains('')) {
              //   //             final otp = authProvider.otpValues.join();
              //   //             authProvider.saveOtp(otp);
              //   //           }
              //   //         },
              //   //       ),
              //   //     ),
              //   //   );
              //   // }),
              // ),
              height(height: 15),
              if (authProvider.isLogin)
                const AppLoadingScreen()
              else
                AppButtons(
                    name: AppStrings.verifyOTP,
                    onTap: () {
                      authProvider.otpVerification(context);
                    })
            ],
          ),
        ),
      );
    });
  }
}
