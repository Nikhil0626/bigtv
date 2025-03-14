import 'package:shared_preferences/shared_preferences.dart';

import '../globel_keys/global_variables_data.dart';
import '../screens/home_screen/home_repo/event_repo.dart';
import 'app_enums.dart';


// Save login status
Future<void> saveLoginStatus(LoginStatus status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('loginStatus', status.toString());
}

// Get login status
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
}

Future<String?> getUserid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('loginId') ?? "";
}

