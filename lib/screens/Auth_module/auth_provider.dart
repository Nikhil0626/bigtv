
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../globel_keys/app_router.dart';
import '../../globel_keys/global_variables_data.dart';
import '../../services/dynamic_link_service.dart';
import '../../services/local_data.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_toasts.dart';
import 'auth_repo.dart';

class AuthProvider extends ChangeNotifier{
  final TextEditingController mobileNumberController = TextEditingController();


  String currentOtp = '';
  String loginSkip = '';
  LoginStatus loginType = LoginStatus.none ;
  bool isLoading = false;
  String className = "";



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

        // loginStatus(LoginStatus.,context);

        // WebEngagePlugin.userLogin(phoneNumber.toString());
        WebEngagePlugin.trackEvent('loginMobileNumber', {'mobileNumber': phoneNumber.toString(),   "verifyStatus":"false"});
        Navigator.pushNamed(context, RoutesManager.enterOtpScreen,arguments: {
          "mobileNumber":mobileNumberController.text,
          "otp":currentOtp.toString(),
        });

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
    log(mobileNumberController.text.toString(),);
    try {
      String? deviceId = GlobalVariables().deviceId;
      Map<String, dynamic> body = {
        "mobile_number": mobileNumberController.text.toString(),
        "otp": otp,
        "authType": "Apple",
        "deviceId": deviceId,
        "email": "",
        "familyName": "",
        "givenName": "",
        "id": "",
        "name": "User${ mobileNumberController.text.substring(mobileNumberController.text.length - 4)}",
        "photo": ""
      };
      log(body.toString());
      Response response = await AuthRepo().validateOtp(body);
      if (response.statusCode == 200) {
        log(response.data.toString());

        className = "Login";
        WebEngagePlugin.userLogin(response.data['data']['id'].toString());
        WebEngagePlugin.setUserPhone(mobileNumber.toString());
        WebEngagePlugin.trackEvent('loginMobileNumber', {'mobileNumber': mobileNumberController.text.toString(),
          "verifyStatus":"true"
        },);
        CustomToast.showSuccessToast(msg: response.data['message']);
        currentOtp = "";
        GlobalVariables().userId = response.data['data']['id'].toString();
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString(
            "loginId", response.data['data']['id'].toString());
        preferences.setString(
            "referralCode", response.data['code'].toString());

        loginStatus(LoginStatus.location,context);
      }
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Otp Not Verify");
      log("error  $e");
      log("error  $st");

    }finally{
      isLoading = false;
      notifyListeners();
    }
  }


  Future skipLogin(context)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    loginSkip = "Skip";
    sp.setString("loginId", loginSkip);
    Navigator.pushNamed(context, RoutesManager.districtSelectionScreen,
        arguments: {
          "className": ""
        });
    notifyListeners();
  }

  void loginStatus(LoginStatus loginStatus,context){
    loginType = loginStatus;
    notifyListeners();
    saveLoginStatus(loginStatus);
    checkLoginStatus(context);
  }



  void checkLoginStatus(context) async {
    LoginStatus status = await getLoginStatus();

    switch (status) {
      case LoginStatus.skip:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.homeScreen, (route) => false);
        break;
      case LoginStatus.home:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.chotaInfo, (route) => false);
        break;
      case LoginStatus.otp:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.signInScreen, (route) => false,);
        break;
      case LoginStatus.login:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.homeScreen, (route) => false);
        break;
      case LoginStatus.location:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.districtSelectionScreen,
          arguments: {"className": className},
              (route) => false,
        );
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.welcomeScreen, (route) => false);
    }
  }
}