import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../categories_screen/categories_view.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  bool isOtpValid = true;
  bool isSubmitEnabled = false;
  int _timerSeconds = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void submitOTP() {
    setState(() {
      if (otpController.text.length < 4) {
        isOtpValid = false;
      } else {
        isOtpValid = true;
        print("OTP Submitted: \${otpController.text}");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoriesView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            Text(
              "OTpVerification".tr(),
              style: newAppFont(fontSize: 36.sp, fontWeight: FontWeight.w300, color: Colors.blue),
            ),
            height(height: 8.h),
            RichText(
              text: TextSpan(
                text: "EnterThe4-digitVerificationCodeSenTo\n".tr(),
                style: newAppFont(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: " yourMobileNumber".tr(),
                    style: newAppFont(fontWeight: FontWeight.w500, fontSize: 14.sp, color: Colors.black),
                  ),
                ],
              ),
            ),
            height(height: 24.h),
            Text(
              "EnterTheCodeBelow".tr(),
              style: newAppFont(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            height(height: 16.sp),
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: otpController,
              textStyle: TextStyle(fontSize: 20.sp),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              onChanged: (value) {
                setState(() {
                  isSubmitEnabled = value.length == 4;
                  isOtpValid = true; // Reset error when typing
                });
              },
            ),
            if (!isOtpValid)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  "Please enter a 4-digit OTP",
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            height(height: 24.h),
            ElevatedButton(
              onPressed: isSubmitEnabled ? submitOTP : null,
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
                "",
                style: newAppFont(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            height(height: 16.h),
            Center(
              child: InkWell(
                onTap: _timerSeconds == 0 ? () {
                  setState(() {
                    _timerSeconds = 25;
                    startTimer();
                  });
                } : null,
                child: RichText(
                  text: TextSpan(
                    text: "Didn'tReceiveTheCode".tr(),
                    style: newAppFont(color: Colors.black, fontSize: 14.sp),
                    children: [
                      TextSpan(
                        text: "  ReSend".tr(),
                        style: newAppFont(
                          color: _timerSeconds == 0 ? Colors.blue : Colors.grey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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