import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../../globel_keys/app_router.dart';
import '../../../globel_keys/global_variables_data.dart';
import '../../../services/dynamic_link_service.dart';
import '../../../services/local_data.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_toasts.dart';
import '../auth_repo/auth_repo.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController mobileNumberController = TextEditingController();

  String currentOtp = '';
  String loginSkip = '';
  LoginStatus loginType = LoginStatus.none;

  bool isLoading = false;
  String className = "";

  Future sendOtp(phoneNumber, context) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
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
        WebEngagePlugin.trackEvent('loginMobileNumber',
            {'mobileNumber': phoneNumber.toString(), "verifyStatus": "false"});
        Navigator.pushNamed(context, RoutesManager.enterOtpScreen, arguments: {
          "mobileNumber": mobileNumberController.text,
          "otp": currentOtp.toString(),
        });

      }
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Otp Not Send Try Again");
      log("error  $e");
      log("error  $st");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String errorMessage = "";

  Future verifyOtp(context, mobileNumber, otp) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    log(
      mobileNumberController.text.toString(),
    );
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
        "name":
            "User${mobileNumberController.text.substring(mobileNumberController.text.length - 4)}",
        "photo": ""
      };
      log(body.toString());
      Response response = await AuthRepo().validateOtp(body);
      log(response.data.toString());
      if (response.statusCode == 200 && response.data['success'] == true) {
        className = "Login";
        WebEngagePlugin.userLogin(response.data['data']['id'].toString());
        WebEngagePlugin.setUserPhone(mobileNumber.toString());
        WebEngagePlugin.trackEvent(
          'loginMobileNumber',
          {
            'mobileNumber': mobileNumberController.text.toString(),
            "verifyStatus": "true"
          },
        );

        currentOtp = "";
        GlobalVariables().userId = response.data['data']['id'].toString();
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString(
            "loginId", response.data['data']['id'].toString());
        preferences.setString("userName",
            "User${mobileNumberController.text.substring(mobileNumberController.text.length - 4)}");
        preferences.setString("referralCode", response.data['code'].toString());
        isLoading = false;
        loginStatus(LoginStatus.location, context);
        mobileNumberController.text = "";
        notifyListeners();
      } else {
        errorMessage = response.data['message'];
      }
    } on DioException catch (e, st) {
      log("error dio ${e.toString()}");
      log("error dio  ${st.toString()}");
    } catch (e, st) {
      log("error  ${e.toString()}");
      log("error  ${st.toString()}");
      CustomToast.showErrorToast(msg: "testing");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future skipLogin(context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    loginSkip = "Skip";
    sp.setString("loginId", loginSkip);
    Navigator.pushNamed(context, RoutesManager.districtSelectionScreen,
        arguments: {"className": ""});
    notifyListeners();
  }

  void loginStatus(LoginStatus loginStatus, context, {String page=""}) {
    if(page !=""){
      className = page;
    }

    print("nbsdmsjfbsfskfskjfsdkjf ${className}");
    loginType = loginStatus;
    notifyListeners();
    saveLoginStatus(loginStatus);
    checkLoginStatus(context);
  }

  void checkLoginStatus(context) async {
    LoginStatus status = await getLoginStatus();
    print("dfngvdklfgdlkfgdfgnfdk ${status}");
    switch (status) {
      case LoginStatus.skip:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.homeScreen, (route) => false,arguments: {"postId":"","tab":"0"});
        break;
      case LoginStatus.home:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.chotaInfo, (route) => false);
        break;
      case LoginStatus.otp:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.signInScreen,
          (route) => false,
        );
        break;
      case LoginStatus.login:
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.homeScreen, (route) => false,arguments: {"postId":"","tab":"0"});
        break;
      case LoginStatus.location:
        log("className $className");
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
