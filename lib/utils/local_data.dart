import 'package:shared_preferences/shared_preferences.dart';

import 'app_enums.dart';



Future<void> saveLoginStatus(LoginStatus status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('loginStatus', status.toString());
}

Future<LoginStatus> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? status = prefs.getString('loginStatus');


  if (status != null) {
    return LoginStatus.values.firstWhere((e) => e.toString() == status, orElse: () => LoginStatus.none);
  }
  return LoginStatus.none;
}


Future<void> saveUserid(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('loginId', userId.toString());
  if (userId.isNotEmpty && userId != "0") {
    prefs.setString('userId', userId.toString());
  }
}

Future<String?> getUserid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  if (userId != null && userId.trim().isNotEmpty && userId != "0" && userId != "null") {
    return userId.trim();
  }
  final loginId = prefs.getString('loginId');
  if (loginId != null && loginId.trim().isNotEmpty && loginId != "0" && loginId != "null") {
    return loginId.trim();
  }
  return "";
}

Future<bool> isUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginType = prefs.getString('loginType');
  final userId = prefs.getString('userId');
  final loginId = prefs.getString('loginId');

  final hasValidUserId = userId != null && userId.trim().isNotEmpty && userId != "0" && userId != "null";
  final hasValidLoginId = loginId != null && loginId.trim().isNotEmpty && loginId != "0" && loginId != "null";

  if (loginType == 'login') {
    return hasValidUserId || hasValidLoginId;
  }
  return hasValidUserId || hasValidLoginId;
}

