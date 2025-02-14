
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../globel_keys/app_router.dart';
import '../../globel_keys/global_variables_data.dart';
import '../../utils/app_toasts.dart';
import 'auth_repo.dart';

class AuthProvider extends ChangeNotifier{
  String currentOtp = '';
  String loginSkip = '';

  bool isLoading = false;



  Future sendOtp(phoneNumber,context) async{
    isLoading = true;
    try {
      String? deviceId = GlobalVariables().deviceId;
      Map<String, dynamic> body = {
        "mobile_number": phoneNumber.toString(),
        "device_id": deviceId.toString(),
      };
      log(body.toString());
      Response response = await AuthRepo().sendOtp(body);
      if (response.statusCode == 200) {
        log(response.data.toString());
        CustomToast.showSuccessToast(msg: response.data['message']);
        currentOtp = response.data['Otp'].toString();
        log(currentOtp);
        Navigator.pushNamed(context, RoutesManager.enterOtpScreen,
            arguments: {
              "mobileNumber": phoneNumber.toString(),
              "otp": currentOtp
            });
        WebEngagePlugin.userLogin(phoneNumber.toString());
        WebEngagePlugin.trackEvent('enterOtpScreen', {'mobileNumber': phoneNumber.toString()});

      }
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Otp Not Send Try Again");
      log("error  $e");
      log("error  $st");
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future verifyOtp(context,mobileNumber,otp)async{
    isLoading = true;
    try {
      String? deviceId = GlobalVariables().deviceId;
      Map<String, dynamic> body = {
        "mobile_number": mobileNumber.toString(),
        "otp": otp,
        "authType": "Apple",
        "deviceId": deviceId,
        "email": "",
        "familyName": "",
        "givenName": "",
        "id": "",
        "name": "User${mobileNumber.toString().substring(6,10)}",
        "photo": ""
      };
      log(body.toString());
      Response response = await AuthRepo().validateOtp(body);
      if (response.statusCode == 200) {
        log(response.data.toString());
        CustomToast.showSuccessToast(msg: response.data['message']);
        currentOtp = "";
        GlobalVariables().userId = response.data['data']['id'].toString();
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString(
            "loginId", response.data['data']['id'].toString());
        preferences.setString(
            "referralCode", response.data['code'].toString());

        Navigator.pushNamed(
            context,
            RoutesManager.districtSelectionScreen,
            arguments: {
              "className":""
            }
        );
      }
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Otp Not Verify");
      log("error  $e");
      log("error  $st");
    }finally{
      isLoading = true;
      notifyListeners();
    }
  }


  Future skipLogin(context)async{
    loginSkip = "Skip";
    Navigator.pushNamed(context, RoutesManager.districtSelectionScreen,
        arguments: {
          "className": ""
        });
    notifyListeners();
  }
}