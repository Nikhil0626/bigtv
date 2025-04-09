import 'dart:developer';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/bookmarks_model/bookmarks_model.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';

class SettingsProvider extends ChangeNotifier {
  List<BookmarksModel> getAllBookmarkList = [];

  Future getAllBookMarks() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"userid": userId};
    try {
      log("body $body");
      Response response = await SettingsRepo().bookMarks(body);
      if (response.statusCode == 200) {
        List data = response.data['bookmarks'];
        getAllBookmarkList = data
            .map(
              (e) => BookmarksModel.fromJson(e),
        )
            .toList();
        log(response.data.toString());
      }
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }


  Future<void> saveBookmarks(String postId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"postid": postId, "userid": userId, "bookmark": 1};
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
    Map<String, dynamic> body = {"deviceId": deviceId, "postId": postId, "userId": userId, "isLiked": isLike};
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
    log(val.id.toString());
    if (!isLikeList.contains(val.id.toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val.id.toString(), "isLike": true}
      });
      isLikeList.add(val.id.toString());
      postLike(val.id.toString(),true);
      sendLikeDetails(userId, val, true, val.title.toString());
      log(isLikeList.toString());
    } else {
      postLike(val.id.toString(),false);
      isLikeList.remove(val.id.toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val.id.toString(), "isLike": false}
      });
      sendLikeDetails(userId, val.id.toString(), false, val.title.toString());
      log(isLikeList.toString());
    }

    notifyListeners();
  }




}
