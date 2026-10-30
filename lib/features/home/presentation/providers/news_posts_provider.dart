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

  static String toCommentPostId(dynamic rawId) {
    if (rawId == null) return "0";
    final s = rawId.toString().trim();
    if (s.isEmpty) return "0";
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return s;
    }
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = (31 * hash + s.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  Future getAllComments(postId) async {
    isLoadingComments = true;
    notifyListeners();
    final normalizedId = toCommentPostId(postId);
    Map<String, dynamic> body = {"post_id": normalizedId};
    try {
      Response response = await NewsPostRepo().getAllComments(body);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['comments'] is List) {
          List data = response.data['comments'];
          getAllCommentsList = data
              .map(
                (e) => CommentsModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        }
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

  Future sendCommentsOnPost(postId, text) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    sendCommentLoading = true;
    notifyListeners();
    final normalizedId = toCommentPostId(postId);
    final validUserId = (userId != null && userId.isNotEmpty && userId != "null")
        ? userId.toString()
        : (deviceId != null && deviceId.isNotEmpty ? deviceId : "0");

    Map<String, dynamic> body = {
      "device_id": deviceId?.toString() ?? "",
      "user_id": validUserId,
      "post_id": normalizedId,
      "comment": text
    };

    log("comment body ---- $body");
    try {
      Response response = await NewsPostRepo().sendPostComments(body);
      if (response.statusCode == 200) {
        if (response.data != null && response.data['comment'] is Map) {
          try {
            final newComment = CommentsModel.fromJson(
              Map<String, dynamic>.from(response.data['comment'] as Map),
            );
            if (!getAllCommentsList.any((c) => c.id == newComment.id && newComment.id != 0)) {
              getAllCommentsList.insert(0, newComment);
              notifyListeners();
            }
          } catch (e) {
            log("Error inserting new comment optimistically: $e");
          }
        }
        await getAllComments(postId.toString());
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