import 'dart:async';
import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String otp;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.otp,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  String enteredOtp = "";

  int _remainingTime = 60; // Initial time (60 seconds)
  late Timer _timer;
  bool canResend = false;

  @override
  void initState() {
    log("mobile number ${widget.mobileNumber}");
    log("mobile number ${widget.otp}");
    super.initState();
    enteredOtp = "";
    startCountdown();
    _listenForSms();
  }

  void _listenForSms() async {
    var otpCode = SmsAutoFill().listenForCode;
    log("otp autofill $otpCode");
  }


  void startCountdown() {
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Consumer<AuthProvider>(builder: (context, authProvider, __) {
          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: authProvider.isLoading
                  ? const AppLoadingScreen()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height(height: 150),
                          SvgPicture.asset(
                            'assets/svg/Chota_news_logo.svg',
                            height: 24,
                            width: 166,
                          ),
                          // height(height: 30),
                          // Text(
                          //   "OTP: ${widget.otp}",
                          //   style: fontStyle(
                          //       fontSize: 24, fontWeight: FontWeight.bold),
                          // ),
                          height(height: 30),
                          Text(
                            "Sign In",
                            style: fontStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          height(height: 10),
                          Text(
                            "Please enter the OTP sent to",
                            style: fontStyle(fontSize: 14, color: Colors.grey),
                          ),
                          height(height: 10),
                          Row(
                            children: [
                              Text(
                                "+91 ${widget.mobileNumber}",
                                style: fontStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  if(!canResend){

                                  }else{
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RoutesManager.signInScreen,
                                          (route) => false,
                                    );
                                  }

                                },
                                child: Text(
                                  "Edit",
                                  style: fontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:!canResend?Colors.grey: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          height(height: 10),
                          PinCodeTextField(
                            appContext: context,
                            length: 4, // OTP length
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              print("jshvfsjfsjfjhs ${value.length}");

                             if(value.isEmpty){
                               authProvider.errorMessage = "";
                             }
                            },
                            cursorColor: Colors.grey,
                            enablePinAutofill: true,
                            pinTheme: PinTheme(

                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 50,
                              fieldWidth: 70,
                              activeFillColor: Colors.white,
                              activeColor: Colors.blue,
                              selectedColor: Colors.blueAccent,
                              selectedFillColor: Colors.white,
                              inactiveColor: Colors.grey,
                              inactiveFillColor: Colors.white,
                              borderWidth: 1,
                              errorBorderColor: authProvider.errorMessage != "" ? Colors.red : Colors.transparent, // Show red border if error
                            ),
                            autoDisposeControllers: false,
                            autoDismissKeyboard: false,
                          ),
                          if (authProvider.errorMessage != "")
                            Text(
                              authProvider.errorMessage,
                              style: fontStyle(color: Colors.red,fontSize: 14),
                            ),
                            height(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "OTP is valid for ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
                                style: fontStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: canResend
                                    ? () {

                                        authProvider.sendOtp(
                                            widget.mobileNumber.toString(),
                                            context);
                                      }
                                    : () {},
                                child: Text(
                                  "Resend OTP",
                                  style: fontStyle(
                                      color:
                                          canResend ? Colors.blue : Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          height(height: 20),
                          InkWell(
                            onTap: () {
                              if (otpController.text.length == 4) {
                                context.read<AuthProvider>().verifyOtp(context,
                                    widget.mobileNumber, otpController.text);
                              } else {
                                // CustomToast.showErrorToast(msg: "Invalid OTP");
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration:  BoxDecoration(
                                  color: otpController.text.length<4?AppColors.borderColor:AppColors.appButtonColor,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(8))),
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                "Verify",
                                style: fontStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
