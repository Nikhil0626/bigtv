import 'dart:async';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../referral_code_screen/referral_code.dart';
import 'auth_event.dart';

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
  OtpFieldController otpController = OtpFieldController();
  String enteredOtp = "";

  int _remainingTime = 60; // Initial time (60 seconds)
  late Timer _timer;
  bool canResend = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCountdown();
  }

  void verifyOtp() {

    if (enteredOtp.length == 4) {
      context.read<AuthBloc>().add(
          VerificationOtp(Otp: enteredOtp, mobileNumber: widget.mobileNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP!')),
      );
    }
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
          canResend = true; // Enable "Resend OTP" button
        });
      }
    });
  }

  void resendOtp() {
    context
        .read<AuthBloc>()
        .add(SendOtp(phoneNumber: widget.mobileNumber.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     "Back",
      //     style: fontStyle(fontWeight: FontWeight.w600, fontSize: 16),
      //   ),
      //   leading: InkWell(
      //     onTap: () {
      //       Navigator.pushNamedAndRemoveUntil(
      //         context,
      //         RoutesManager.signInScreen,
      //         (route) => false,
      //       );
      //     },
      //     child: const Icon(
      //       Icons.arrow_back_ios,
      //       size: 24,
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state is SuccessScreen) {
            if (state.message == "OTP Verify") {
              Navigator.pushNamed(context, RoutesManager.referralCode,arguments: {
        "mobileNumber":widget.mobileNumber
              });
            }
          }
        }, builder: (context, state) {
          return state is LoadingScreen
              ? const Center(
                  child: AppLoadingScreen(),
                )
              : state is LoadingScreen
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height(height: 100),
                          SvgPicture.asset(
                            'assets/svg/Chota_news_logo.svg',
                            height: 24,
                            width: 166,
                          ),
                          height(height: 30),
                          Text(
                            "OTP: ${widget.otp}",
                            style: fontStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
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
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RoutesManager.signInScreen,
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Change Phone Number",
                                  style: fontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          height(height: 10),
                          OTPTextField(
                            length: 4,
                            width: MediaQuery.of(context).size.width,
                            fieldWidth: 70,
                            style: const TextStyle(fontSize: 18),
                            textFieldAlignment: MainAxisAlignment.spaceEvenly,
                            fieldStyle: FieldStyle.box,
                            controller: otpController,
                            onChanged: (otp) {
                              setState(() {
                                enteredOtp = otp;
                              });
                            },
                            onCompleted: (otp) {
                              setState(() {
                                enteredOtp = otp;
                              });
                            },
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
                                onTap: canResend ? resendOtp : null,
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
                            onTap: verifyOtp,
                            child: Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: AppColors.appButtonColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
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
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height(height: 100),
                          SvgPicture.asset(
                            'assets/svg/Chota_news_logo.svg',
                            height: 24,
                            width: 166,
                          ),
                          height(height: 30),
                          Text(
                            "OTP: ${widget.otp}",
                            style: fontStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          height(height: 30),
                          Text(
                            "Sign In",
                            style: fontStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          height(height: 10),
                          Text(
                            "Please enter the OTP sent to",
                            style: fontStyle(fontSize: 16, color: Colors.grey),
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
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RoutesManager.signInScreen,
                                    (route) => false,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 13),
                                  child: Text(
                                    "Edit",
                                    style: fontStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text("Enter OTP",style: fontStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                          ),
                          height(height: 5),
                          OTPTextField(
                            // key: UniqueKey(),
                            length: 4,
                            width: MediaQuery.of(context).size.width,
                            fieldWidth: 70,
                            style: const TextStyle(fontSize: 18),
                            textFieldAlignment: MainAxisAlignment.spaceEvenly,
                            fieldStyle: FieldStyle.box,

                            controller: otpController,
                            onChanged: (otp) {
                              setState(() {
                                enteredOtp = otp;
                              });
                            },
                            onCompleted: (otp) {
                              setState(() {
                                enteredOtp = otp;
                              });
                            },
                          ),
                          height(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "OTP is valid for ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
                                  style: fontStyle(color: Colors.grey),
                                ),
                              ),
                              GestureDetector(
                                onTap: canResend ? resendOtp : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 9),
                                  child: Text(
                                    "Resend OTP",
                                    style: TextStyle(
                                        color:
                                            canResend ? Colors.blue : Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height(height: 30),
                          InkWell(
                            onTap: verifyOtp,

                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: enteredOtp.length < 3
                                      ? Colors.grey
                                      : AppColors.appButtonColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
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
                    );
        }),
      ),
    );
  }
}
