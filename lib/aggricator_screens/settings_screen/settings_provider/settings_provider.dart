import 'dart:developer';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_model/bookmarks_model.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';

class SettingsProvider extends ChangeNotifier {
  List<BookmarksModel> getAllBookmarkList = [];
  bool isMainLoading = false;
  bool isOthersSelected = false;

  List feedbackList = [];
  List<String> selectedFeedbackList = [];
  TextEditingController feedbackController = TextEditingController();

  bool isBookMarkLoading = false;

  Future getAllBookMarks() async {
    isBookMarkLoading =true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"user_id": userId};
    try {
      log("body $body");
      Response response = await SettingsRepo().bookMarks(body);
      log("body ${response.data}");
      if (response.statusCode == 200) {
        List data = response.data['bookMarks'];
        getAllBookmarkList = data
            .map(
              (e) => BookmarksModel.fromJson(e),
        )
            .toList();
        log(response.data.toString());
      }
    } catch (e,st) {
      log("kjsbdcjksjksdhbcfk${e.toString()} -- ${st}");
    } finally {
      isBookMarkLoading = false;
      notifyListeners();
    }
  }


  Future<void> saveBookmarks(String postId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"post_id": postId, "user_id": userId, "bookmark": 1};
    try {
      log("body $body");
      Response response = await SettingsRepo().saveBookMarks(body);
      if (response.statusCode == 200) {
        CustomToast.showSuccessToast(msg: "Bookmark added successfully", duration: Duration(seconds: 3));
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      notifyListeners();
    }
  }


  Future<void> postLike(String postId, isLike) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
     Map<String, dynamic> body = {"deviceId": deviceId,
      "postId": postId,
      "userId": userId,
      "isLiked": isLike};
    try {
      log("body $body");
      Response response = await SettingsRepo().liked(body);
      if (response.statusCode == 200) {}
    } catch (e) {
      log("Error: $e");
    } finally {
      notifyListeners();
    }
  }



  List<String> isLikeList = [];
  void isLikePost(val) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    log(val['id'].toString());
    if (!isLikeList.contains(val['id'].toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val['id'].toString(), "isLike": true}
      });
      isLikeList.add(val['id'].toString());
      postLike(val['id'].toString(),true);
      sendLikeDetails(userId, val, true, val['title'].toString());
      log(isLikeList.toString());
    } else {
      postLike(val['id'].toString(),false);
      isLikeList.remove(val['id'].toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val['id'].toString(), "isLike": false}
      });
      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isLikeList.toString());
    }

    notifyListeners();
  }



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
