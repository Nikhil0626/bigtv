import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_colors.dart';
import '../../event_repo.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  String enteredOtp = "";

  int _remainingTime = 60; // Initial time (60 seconds)
  late Timer _timer;
  bool canResend = false;

  @override
  void initState() {
    startCountdown();
    // _listenForSms();
    super.initState();
  }



  void startCountdown() {
    log("its working");
    setState(() {
      _remainingTime = 60;
      canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (_, authenticationProvider, __) {
      return Container(
        height: MediaQuery.of(context).size.height * .46,
        width: 326.w,
        padding: EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Text(
                "Enter the code below",
                style: newAppFont(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
            height(height: 15.h),
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: authenticationProvider.otpController,
              keyboardType: TextInputType.number,
              onChanged: (value) => authenticationProvider.checkOtpFilled(value),
              cursorColor: Colors.grey,
              enablePinAutofill: true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10.r),
                fieldHeight: 48.w,
                fieldWidth: 48.w,
                activeFillColor: Colors.white,
                activeColor: Colors.lightBlue,
                selectedColor: Colors.lightBlue,
                selectedFillColor: Colors.white,
                inactiveColor: Colors.grey.shade400,
                inactiveFillColor: Colors.white,
                borderWidth: 1,
              ),
              autoDisposeControllers: false,
              autoDismissKeyboard: false,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            height(height: 24.h),
            InkWell(
              onTap: authenticationProvider.isOtpButtonEnabled
                  ? () async {


                // if (!canResend) {
                      // } else {
                      authenticationProvider.verifyOtp(context);
                      // }
                    }
                  : null,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 36.h,
                  decoration: BoxDecoration(
                      color: authenticationProvider.isOtpButtonEnabled ? AppColors.loginBgColor : AppColors.bodyTextColor.withOpacity(.2), borderRadius: BorderRadius.all(Radius.circular(8.r))),
                  child: Center(
                      child: authenticationProvider.isVerifyLoading
                          ? AppLoadingScreen(
                              loadingColor: Colors.white,
                            )
                          : Text('Verify', style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500)))),
            ),
            height(height: 24.h),
            Divider(
              height: 1,
              color: AppColors.borderColor,
            ),
            height(height: 24.h),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 36.h,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: "Didn’t receive any OTP? ",
                    style: newAppFont(color: Colors.black, fontWeight: FontWeight.w600, fontSize: Platform.isIOS ? 12.sp : 14.sp),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = canResend
                              ? () {
                                  startCountdown();
                                  authenticationProvider.sendOtp(context);
                                }
                              : null,
                        text: "Resend Again",
                        style: newAppFont(color: canResend ? Colors.blue : Colors.grey, fontWeight: FontWeight.w600, fontSize: Platform.isIOS ? 12.sp : 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                textAlign: TextAlign.center,
                "Request new OTP in ${formatTime(_remainingTime)}",
                style: fontStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
