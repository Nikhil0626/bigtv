import 'dart:developer';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_fonts.dart';
import 'otp_verification_view.dart';

class OnbordingScreen2 extends StatefulWidget {
  const OnbordingScreen2({super.key});

  @override
  State<OnbordingScreen2> createState() => _OnbordingScreen2State();
}

class _OnbordingScreen2State extends State<OnbordingScreen2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;
  void _validatePhoneNumber() {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = "Phone number cannot be empty";
      });
    } else if (!RegExp(r'^[6789]\d{9}$').hasMatch(phone)) {
      setState(() {
        _errorMessage = "Please enter a valid 10-digit mobile number";
      });
    } else {
      setState(() {
        _errorMessage = null; // Clear error if valid
      });

      // Navigate to OTP screen if needed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPVerificationScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: InkWell(
                  onTap: () {
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
                  child: SvgPicture.asset(
                    'assets/svg/Chota_news_logo.svg',
                    height: 24,
                    width: 167,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              Text(
                "signIn".tr(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                  color: Colors.blue,
                ),
              ),
              Text(
                "Please enter your phone number and\nexplore latest news",
                style: newAppFont(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                  color: AppColors.newAppButtonColor,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        height: 52,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          // border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 24,
                              child: SvgPicture.asset(
                                'assets/svg/indianFlag.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "+91",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_outlined, size: 20),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          hintText: "".tr(),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        ),
                        // validator: (value) {
                        //
                        //   return "";
                        // },
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  children: [
                    TextSpan(text: "   By continuing you consent to our\n"),
                    TextSpan(
                      text: "   Terms of Service",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(text: "."),
                  ],
                ),
              ),
              height(height: 38.h),
              ElevatedButton(
                onPressed: _validatePhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  "sendOtp".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _validatePhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.lightBlue[50],
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  "continueAsGuest".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
