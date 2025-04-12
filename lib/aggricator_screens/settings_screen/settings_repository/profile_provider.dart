import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  bool isButtonEnabled = false;
  var profileData;

  Future getProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
    };
    bool isMainLoading = true;
    try {
      Response response = await SettingsRepo().getProfile(body);
      if (response.statusCode == 200) {
        profileData = response.data;
        phoneController.text = response.data['profile']['mobileNumber']??"";


        String dob = response.data['profile']['dob'].toString();
       List data = dob.split("-");
        dayController.text = data[2]??"";
        monthController.text = data[1]??"";
        yearController.text = data[0]??"";
        nameController.text = response.data['profile']['name']??"";


        log("Like posted successfully: ${response.data}");
      } else {
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainLoading = false;
      notifyListeners();
    }
  }

  Future postProfile() async {
    bool isMainLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "user_id":userId,
      "":"",
      "":"",
      "":"",
    };
    try {
      Response response = await SettingsRepo().postProfile(body);
      if (response.statusCode == 200) {
        log("Like posted successfully: ${response.data}");
      } else {
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainLoading = false;
      notifyListeners();
    }
  }
}
