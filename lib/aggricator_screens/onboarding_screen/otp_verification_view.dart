
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  int _timerSeconds = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Locale currentLocale = context.locale;
                log("Current Locale: ${currentLocale.languageCode}");

                if (currentLocale.languageCode == 'en') {
                  context.setLocale(Locale('te')); // Switch to Telugu
                } else if (currentLocale.languageCode == 'te') {
                  context.setLocale(Locale('hi')); // Switch to Hindi
                } else {
                  context.setLocale(Locale('en')); // Switch to English
                }

                log("New Locale: ${context.locale.languageCode}");
              },
              child: Text(
                "OTpVerification".tr(),
                style: newAppFont(fontSize: 36.sp, fontWeight: FontWeight.w300, color: Colors.blue),
              ),
            ),
            height(height: 8.h),
            RichText(
              text: TextSpan(
                text: "EnterThe4-digitVerificationCodeSenTo\n".tr(),
                style: newAppFont(color: Colors.black, fontSize: 14.sp,fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: "yourMobileNumber".tr(),
                    style: newAppFont(fontWeight: FontWeight.w500,fontSize: 14.sp,color: Colors.black),
                  ),
                ],
              ),
            ),
            height(height: 24.h),
            Text("EnterTheCodeBelow".tr(),
              style: newAppFont(fontSize: 14.sp,fontWeight: FontWeight.w600),

            ),
            height(height: 16.sp),
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: otpController,
              textStyle: newAppFont(fontSize: 20),
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(15.r),
                fieldHeight: 50.h,
                fieldWidth: 50.w,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                activeColor: Colors.grey.shade50,
                inactiveColor: Colors.grey,
                selectedColor: Colors.blue,
              ),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust spacing
              onChanged: (value) {},
            ),

            height(height: 24.h),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "verify".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            height(height: 16.h),
            Center(
              child: Text(
                "00:${_timerSeconds.toString().padLeft(2, '0')}",
                style: newAppFont(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            height(height: 16.h),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Didn'tReceiveTheCode".tr(),
                  style: newAppFont(color: Colors.black, fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: "  ReSend".tr(),
                      style: newAppFont(color: Colors.blue,fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
