import 'dart:developer';

import 'package:chotanews/aggricator_screens/reels_screens/reels_repo/reels_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ReelsProviders extends ChangeNotifier{
  bool isMainLoading = false;
  List reelsDataList = [];

  Future getReels() async {
    isMainLoading = true;

    try {
      Response response = await ReelsRepo().getReels();
      if (response.statusCode == 200) {
        reelsDataList.addAll(response.data['data']);
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

  Future postLikes(String postId) async{
    bool isMainLoading = true;
    Map<String,dynamic> body = {
      "postId":postId,
      "isLike":true,
    };

    try {
      Response response = await ReelsRepo().postLikes(body);
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

