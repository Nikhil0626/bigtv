import 'dart:developer';

import 'package:chotanews/features/home/data/repositories/news_post_repo.dart';
import 'package:chotanews/features/home/domain/models/comments_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';



class NewsPostsProvider extends ChangeNotifier {
  List<CommentsModel> getAllCommentsList = [];

  bool isLoadingComments = false;
  bool sendCommentLoading = false;

  Future getAllComments(postId) async {
    isLoadingComments = true;
    Map<String, dynamic> body = {"post_id": postId};
    try {
      Response response = await NewsPostRepo().getAllComments(body);
      if (response.statusCode == 200) {
        List data = response.data['comments'];
        getAllCommentsList = data
            .map(
              (e) => CommentsModel.fromJson(e),
            )
            .toList();
      }
    } on DioException catch (e, st) {
      log("dio catch error ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log(" catch error ${e.toString()} --- ${st.toString()}");
    } finally {
      isLoadingComments = false;
      notifyListeners();
    }
  }

  Future sendCommentsOnPost(postId,text) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    sendCommentLoading = true;
    Map<String, dynamic> body = {
      "device_id": deviceId.toString(),
      "user_id": userId.toString(),
      "post_id": postId.toString(),
      "comment": text
    };

    log("comment body ---- ${body}");
    try {
      Response response = await NewsPostRepo().sendPostComments(body);
      if (response.statusCode == 200) {
        getAllComments(postId.toString());
      }
    } on DioException catch (e, st) {
      log("dio catch error ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log(" catch error ${e.toString()} --- ${st.toString()}");
    } finally {
      sendCommentLoading = false;
      notifyListeners();
    }
  }

  bool isBottomIsShow = false;
}