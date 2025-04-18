import 'dart:developer';

import 'package:chotanews/aggricator_screens/reels_screens/reels_repo/reels_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../settings_screen/settings_repository/settings_repo.dart';
import '../reels_models/reels_model.dart';

class ReelsProviders extends ChangeNotifier {
  bool reelsLoading = false;
  List<ReelsModel> getAllReelsList = [];
  List<String> isLikeList = [];


  Future getAllReels() async {
    reelsLoading = true;
    getAllReelsList = [];
    try {
      Response response = await ReelsRepo().getAllReels();

      if(response.statusCode == 200){
        List data = response.data['data'];
        getAllReelsList = data.map((e) => ReelsModel.fromJson(e),).toList();
      }
    } on DioException catch (e, st) {
      log("dio error --- ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("catch error --- ${e.toString()} ---- ${st.toString()}");
    } finally {
      reelsLoading = false;
      notifyListeners();
    }
  }


  void isLikePost(val) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    log(val.id.toString());
    if (!isLikeList.contains(val.id.toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "$deviceId", "userId": userId, "postId": val.id.toString(), "isLike": true}
      });
      isLikeList.add(val.id.toString());
      postLike(val.id.toString(), true);
      sendLikeDetails(userId, val, true, val.contant.toString());
      log(isLikeList.toString());
    } else {
      postLike(val.id.toString(), false);
      isLikeList.remove(val.id.toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${deviceId}", "userId": userId, "postId": val.id.toString(), "isLike": false}
      });
      sendLikeDetails(userId, val.id.toString(), false, val.contant.toString());
      log(isLikeList.toString());
    }

    notifyListeners();
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
}
