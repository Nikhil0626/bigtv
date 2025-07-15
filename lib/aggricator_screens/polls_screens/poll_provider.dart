import 'dart:developer';

import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PollProvider with ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  int? selectedIndex;
  final List<int> votes = [];

  void initialPollData(List<dynamic> votesList) {
    if (votes.isEmpty) {
      votes.addAll(votesList.map((e) => e['votes'] as int));
      notifyListeners();
    }
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> submitPolls(int postId, int index, pollsOptions, {VoidCallback? onSuccess}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    final body = {
      "post_id": postId,
      "user_id": userId ?? "0",
      "selected_option": pollsOptions[index]['id'], // 1-based index expected by backend
      "comment": commentController.text.trim(),
    };
    log(body.toString());
    try {
      Response response = await PollRepo().submitPolls(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        updatePollData(index);
        commentController.clear();
        if (onSuccess != null) onSuccess(); // call back to set hasVoted true
      }
    } on DioException catch (e, st) {
      log("DioException: $e \nStackTrace: $st");
    } catch (e, st) {
      log("Exception: $e \nStackTrace: $st");
    } finally {
      notifyListeners();
    }
  }

  void updatePollData(int index) {
    if (index >= 0 && index < votes.length) {
      votes[index]++;
    }
    selectedIndex = null;
    notifyListeners();
  }

  List getAllPollCommentsList = [];

  Future getAllPollComments(String postId, name) async {

    try {
      Response response = await PollRepo().getAllPollComments(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllPollCommentsList.addAll( response.data);
        notifyListeners();
        log(getAllPollCommentsList.toString());
      }
    } catch (e, st) {
      log("Hello siva catch $e --- $st");
    }
  }
}
