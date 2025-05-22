import 'dart:developer';

import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_repo/reels_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/webengage_event_tracks.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../../settings_screen/settings_repository/settings_repo.dart';
import '../reels_models/reels_model.dart';

class ReelsProviders extends ChangeNotifier {
  bool reelsLoading = false;
  List<ReelsModel> getAllReelsList = [];
  List<String> isLikeList = [];
  bool isMuted = false;

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  Future getAllReels({String postId = "0"}) async {
    reelsLoading = true;
    isBookMark = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');
    try {
      Map<String,dynamic> body =
      {
        "user_id":userId??"0",
      };
      Response response = await ReelsRepo().getAllReels(body);

      if (response.statusCode == 200) {
        List data = response.data['data'];
        log(data.toString());
        getAllReelsList = data
            .map(
              (e) => ReelsModel.fromJson(e),
            )
            .toList();
      }
      isBookMark = getAllReelsList
          .where((e) => e.isBookmarked == 1)
          .map((e) => e.id.toString())
          .toList();
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

      isLikeList.add(val.id.toString());
      postLike(val.id.toString(), true);
      sendLikeDetails(userId, val, true, val.contant.toString());
      log(isLikeList.toString());
    } else {
      postLike(val.id.toString(), false);
      isLikeList.remove(val.id.toString());

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
      notifyListeners();
      if (response.statusCode == 200) {}
    } catch (e) {
      log("Error: $e");
    } finally {
      notifyListeners();
    }
  }

  late ReelsModel reelData;

  bool isReelDataLoading = false;

  Future getIndividualReelData(String postId) async {
    isReelDataLoading = true;
    try {
      Map<String, dynamic> body = {"id": postId};
      Response response = await ReelsRepo().getSingleReelData(body);
      if (response.statusCode == 200) {
        reelData = ReelsModel.fromJson(response.data['data']);
        notifyListeners();
      }

    } on DioException catch (e, st) {
      log("Dio Exception -- ${e.toString()}/// ${st.toString()}");
    } catch (e, st) {
      log("Catch Exception -- ${e.toString()}/// ${st.toString()}");
    } finally {
    isReelDataLoading = false;
      notifyListeners();
      return reelData;
    }
  }



  List isBookMark = [];


  void isBookMarkPost(val,context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    log(val.id.toString());
    if (!isBookMark.contains(val.id.toString())) {

      isBookMark.add(val.id.toString());
      Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val.id.toString(), context,1
      );
      // sendLikeDetails(userId, val, true, val['title'].toString());
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val.id.toString(), context,0
      );
      isBookMark.remove(val.id.toString());

      // sendLikeDetails(userId, val.id.toString(), false, val['title'].toString());
      log(isBookMark.toString());
    }

    notifyListeners();
  }
}
