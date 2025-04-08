import 'dart:developer';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/bookmarks_model/bookmarks_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Map<String, dynamic> body = {
      "postid": postId,
      "userid": userId,
      "bookmark": 1
    };
    try {
      log("body $body");
      Response response = await SettingsRepo().bookMarks(body);
      if (response.statusCode == 200) {
        List data = response.data['saveBookMarks'];
        getAllBookmarkList = data.map((e) => BookmarksModel.fromJson(e)).toList();
        log(response.data.toString());
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      notifyListeners();
    }
  }
}
