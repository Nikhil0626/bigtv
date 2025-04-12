import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/settings_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool isMainLoading = false;
  bool isOthersSelected = false;

  List feedbackList = [];
  List<String> selectedFeedbackList = [];
  TextEditingController feedbackController = TextEditingController();

  Future getFeedBack() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
    };
    bool isMainLoading = true;
    try {
      Response response = await SettingsRepo().getFeedBack(body);
      if (response.statusCode == 200) {

        feedbackList.addAll(response.data['feedback_options']);

        selectedFeedbackList = feedbackList.where((item) => item.isFollowed == true).map((item) => item['optionText'].toString()).toList();

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

  Future postFeedBack(rating,) async {
    bool isMainLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? userId = preferences.getString("userId");
    List<int> selectedCategoryIds = feedbackList.where((item) => selectedFeedbackList.contains(item['optionText'].toString())).map((item) => item.id as int).toList();


    Map<String, dynamic> body = {
      "user_id": userId,
      "user_rating": rating,
      "comment_ids": selectedCategoryIds,
      "custom_comment": feedbackController.text
    };
    try {
      Response response = await SettingsRepo().postFeedBack(body);
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

  void addToSelectedEngagements(String profileName) {
    isOthersSelected = profileName
        .toString() ==
        "Others"?true: false;
    if (!selectedFeedbackList.contains(profileName)) {
      selectedFeedbackList.add(profileName);
      log(selectedFeedbackList.toString());
      notifyListeners(); // Notify listeners if using ChangeNotifier
    } else {
      selectedFeedbackList.remove(profileName);
      notifyListeners();
    }
  }

}
