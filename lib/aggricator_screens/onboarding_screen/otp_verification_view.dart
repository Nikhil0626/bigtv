import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../categories_screen/categories_view.dart';

class OtpVerificationView extends StatefulWidget {
  @override
  _OtpVerificationViewState createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  TextEditingController otpController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void checkOtpFilled(String value) {
    setState(() {
      isButtonEnabled = value.length == 4;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Padding(
          padding:  EdgeInsets.only(left: 10),
          child: Container(
            width: 5.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  color: Colors.blue,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        height(height: 20.h),
                        SvgPicture.asset(
                          'assets/svg/logo_ChotaNews_black.svg',
                          height: 26.h,
                          width: 181.w,
                        ),
                        height(height: 20.h),
                        Text(
                          "OTP Verification",
                          style: newAppFont(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        height(height: 10.h),
                        Text(
                          "Please enter the 6-digit code sent to your\nphone number for verification",
                          textAlign: TextAlign.center,
                          style: newAppFont(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              height: 300.h,
              width: MediaQuery.of(context).size.width * 0.9.w,
              padding: EdgeInsets.all(16),
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
                  Text(
                    "     Enter the code below",
                    style: newAppFont(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  height(height: 15.h),
                  PinCodeTextField(
                    appContext: context,
                    length: 4,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    onChanged: checkOtpFilled,
                    cursorColor: Colors.grey,
                    enablePinAutofill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50.h,
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

                  height(height: 40.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriesView(),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(279.w, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Verify",
                        style: newAppFont(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  height(height: 20.h),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: RichText(
                        text: TextSpan(
                          text: "Didn’t receive any OTP? ",
                          style: newAppFont(
                              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14.sp),
                          children: [
                            TextSpan(
                              text: "Resend Again",
                              style: newAppFont(color: Colors.lightBlue, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
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
