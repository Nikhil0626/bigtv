import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/app_router.dart';
import '../../mixin_class/auth_mixin.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_toasts.dart';
import '../settings_view/user_model.dart';
import 'auth_repo.dart';

class AuthProvider extends ChangeNotifier with AuthMixin {
  TextEditingController userNameController = TextEditingController();
  TextEditingController otpEmail = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController updatePassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool isLogin = false;
  LoginType loginType = LoginType.login;

  void changeType(LoginType changeType) {
    loginType = changeType;
    notifyListeners();
  }

  String password = '';
  int strengthLevel = 0;

  void checkPasswordStrength(String password) {
    password = password;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacter =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isLengthValid = password.length >= 8;

    strengthLevel = 0;
    if (hasUppercase) strengthLevel++;
    if (hasLowercase) strengthLevel++;
    if (hasDigit) strengthLevel++;
    if (hasSpecialCharacter) strengthLevel++;
    if (isLengthValid) strengthLevel++;

    notifyListeners();
  }

  Color getSegmentColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future login(BuildContext context) async {
    try {
      isLogin = true;
      notifyListeners();
      Map<String, dynamic> body = {
        "email": userNameController.text,
        "password": passwordController.text
      };
      Response response = await AppRepo().login(body);

      if (response.statusCode == 200 && context.mounted) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString(
            "accessToken", response.data['data']['token']);
        UserModel data = UserModel.fromJson(response.data['data']);
        log(data.profilePic);
        log("data.profilePic");
        await setUserData(
                data.name,
                data.email,
                response.data['data']['profile_pic'] ?? "",
                data.id.toString(),
                data.phoneNumber,
                data.lastName,
                data.firstName)
            .then(
          (value) => loadUserData(),
        );
        sharedPreferences.setString(
            "userData", response.data['data'].toString());
        userNameController.clear();
        passwordController.clear();
        isLogin = false;
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.homeScreen,
          (route) => false,
        );
      } else {
        CustomToast.showErrorToast(msg: response.data['message']);
      }
      print(response.data.toString());
    } on DioException catch (e, st) {
      log(e.response.toString());
      CustomToast.showErrorToast(msg: e.response?.data['message'].toString());
      log(st.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
      CustomToast.showErrorToast(msg: "Internal Server Error");
    } finally {
      isLogin = false;
      notifyListeners();
    }
  }

  Future setOtpByEmail(BuildContext context) async {
    try {
      isLogin = true;
      notifyListeners();
      Map<String, dynamic> body = {
        "email": otpEmail.text,
      };
      log(body.toString());
      Response response = await AppRepo().sendOtpByEmail(body);
      if (response.statusCode == 200 && context.mounted) {
        changeType(LoginType.otp);
      } else {
        CustomToast.showErrorToast(msg: response.data['message']);
      }

      print(response.data.toString());
    } on DioException catch (e, st) {
      log(e.response.toString());
      CustomToast.showErrorToast(msg: e.response?.data['message'].toString());
      log(st.toString());
    } catch (e, st) {
      log(st.toString());
      CustomToast.showErrorToast(msg: "Internal Server Error");
    } finally {
      isLogin = false;
      notifyListeners();
    }
  }

  String verifyToken = '';

  Future otpVerification(BuildContext context) async {
    try {
      isLogin = true;
      notifyListeners();
      Map<String, dynamic> body = {
        "otp": enteredOTP,
        "email": otpEmail.text,
      };

      log(body.toString());
      Response response = await AppRepo().verifyOtp(body);

      log(response.data.toString());
      if (response.statusCode == 200 && context.mounted) {
        verifyToken = response.data['token'];
        changeType(LoginType.changePassword);
      } else {
        CustomToast.showErrorToast(msg: response.data['message']??"");
      }

      print(response.data.toString());
    } on DioException catch (e, st) {
      log(e.response.toString());
      CustomToast.showErrorToast(msg: e.response?.data['message']??"");
      log(st.toString());
    } catch (e, st) {
      log(st.toString());
      CustomToast.showErrorToast(msg: "Internal Server Error");
    } finally {
      isLogin = false;
      notifyListeners();
    }
  }

  Future changePassword(BuildContext context) async {
    try {
      isLogin = true;
      notifyListeners();
      Map<String, dynamic> body = {
        "password": updatePassword.text,
        "email": otpEmail.text,
      };

      log(body.toString());
      Response response = await AppRepo().changePassword(body);

      log(response.data.toString());
      if (response.statusCode == 200 && context.mounted) {
        changeType(LoginType.login);
        otpEmail.clear();
      } else {
        CustomToast.showErrorToast(msg: response.data['message']);
      }

      print(response.data.toString());
    } on DioException catch (e, st) {
      log(e.response.toString());
      CustomToast.showErrorToast(msg: e.response?.data['error'].toString());
      log(st.toString());
    } catch (e, st) {
      log(st.toString());
      CustomToast.showErrorToast(msg: "Internal Server Error");
    } finally {
      isLogin = false;
      notifyListeners();
    }
  }

  String enteredOTP = '';

  void saveOtp(value) {
    log("kasmldkmadlalasmdlakd ${value.toString()}");
    enteredOTP = value.toString();
    log(enteredOTP);
  }

  List<String> otpValues = List.generate(6, (_) => '');
}
