import 'dart:developer';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_repo/authentication_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../onboarding_screen/otp_verification_view.dart';

class AuthenticationProvider  extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool isLoginLoading = false;

  Future sendOtp(BuildContext context) async {
    log("ButtonClicked __${phoneController.text}");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");


    Map<String, dynamic> body = {
      "mobile_number": phoneController.text.toString(),
      "device_id": deviceId.toString(),

    };
    log(body.toString());


    try {
      Response response = await AuthenticationRepo().sendOtp(body);
      log(response.toString());
      if (response.statusCode == 200){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpVerificationView()),
        );
      }
    } catch (e,st) {
   log(e.toString());
    }
  }
}