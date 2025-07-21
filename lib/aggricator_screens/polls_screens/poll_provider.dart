import 'dart:developer';

import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_toasts.dart';

class PollProvider with ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  int? selectedIndex;
  List<int> votes = [];

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



  Set<int> ratedArticleIds = {};

  void markAsRated(int articleId) {
    ratedArticleIds.add(articleId);
    notifyListeners();
  }

  bool isArticleRated(int articleId) {
    return ratedArticleIds.contains(articleId);
  }

  Future<void> submitPolls(int postId, int index, pollsOptions, {VoidCallback? onSuccess}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    final body = {
      "post_id": postId,
      "user_id": userId ?? "0",
      "selected_option": pollsOptions[index]['id'],
      "comment": commentController.text.trim(),
    };

    log("Request Body: $body");

    try {
      Response response = await PollRepo().submitPolls(body);
      log("Response: ${response.data}");

      if (response.statusCode == 200) {
        markAsRated(int.tryParse(postId.toString()) ?? 0);
        initialPollData(pollsOptions);
        updatePollData(index);
        commentController.clear();
        await getAllPollComments(postId.toString(), "sort_by");

        CustomToast.showSuccessToast(msg: "Poll submitted successfully!");

        if (onSuccess != null) onSuccess();
      } else {
        final errorMessage = response.data['message'] ?? "Something went wrong!";
        CustomToast.showErrorToast(msg: errorMessage);
      }
    } on DioException catch (e, st) {
      log("DioException: $e \nStackTrace: $st");
      final errorMsg = e.response?.data['message'] ?? "Network error occurred!";
      CustomToast.showErrorToast(msg: errorMsg);
    } catch (e, st) {
      log("Exception: $e \nStackTrace: $st");
      CustomToast.showErrorToast(msg: "Unexpected error occurred!");
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

  Map<dynamic, dynamic> getAllPollCommentsList = {};

  Future getAllPollComments(String postId, name) async {
    try {
      Response response = await PollRepo().getAllPollComments(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllPollCommentsList = response.data;
        notifyListeners();
        log(getAllPollCommentsList.toString());
      }
    } catch (e, st) {
      log("Hello siva catch $e --- $st");
    }
  }
}

/*
import 'dart:developer';
import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_toasts.dart';

class PollProvider with ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  int? selectedIndex;
  List<int> votes = [];
  Set<int> ratedArticleIds = {};
  Map<dynamic, dynamic> getAllPollCommentsList = {};

  // Cache for poll data by postId
  final Map<int, Map<String, dynamic>> _pollCache = {};

  void initialPollData(List<dynamic> votesList, int postId, bool userHasVoted) {
    // Check cache first
    if (_pollCache.containsKey(postId)) {
      votes = List<int>.from(_pollCache[postId]!['votes']);
      notifyListeners();
      return;
    }

    // Initialize fresh data
    votes = votesList.map((e) => e['votes'] as int).toList();
    _pollCache[postId] = {
      'votes': List<int>.from(votes),
      'hasVoted': userHasVoted,
    };
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  bool isArticleRated(int articleId) {
    return ratedArticleIds.contains(articleId);
  }

  void markAsRated(int articleId) {
    ratedArticleIds.add(articleId);
    notifyListeners();
  }

  Future<void> submitPolls(int postId, int index, List<dynamic> pollsOptions, {VoidCallback? onSuccess}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    final body = {
      "post_id": postId,
      "user_id": userId ?? "0",
      "selected_option": pollsOptions[index]['id'],
      "comment": commentController.text.trim(),
    };

    log("Request Body: $body");

    try {
      Response response = await PollRepo().submitPolls(body);
      log("Response: ${response.data}");

      if (response.statusCode == 200) {
        markAsRated(postId);
        updatePollData(index, postId);
        commentController.clear();
        await getAllPollComments(postId.toString(), "sort_by");

        CustomToast.showSuccessToast(msg: "Poll submitted successfully!");

        if (onSuccess != null) onSuccess();
      } else {
        final errorMessage = response.data['message'] ?? "Something went wrong!";
        CustomToast.showErrorToast(msg: errorMessage);
      }
    } on DioException catch (e, st) {
      log("DioException: $e \nStackTrace: $st");
      final errorMsg = e.response?.data['message'] ?? "Network error occurred!";
      CustomToast.showErrorToast(msg: errorMsg);
    } catch (e, st) {
      log("Exception: $e \nStackTrace: $st");
      CustomToast.showErrorToast(msg: "Unexpected error occurred!");
    }
  }

  void updatePollData(int index, int postId) {
    if (index >= 0 && index < votes.length) {
      votes[index]++;
      // Update cache
      if (_pollCache.containsKey(postId)) {
        _pollCache[postId]!['votes'] = List<int>.from(votes);
        _pollCache[postId]!['hasVoted'] = true;
      }
      selectedIndex = null;
      notifyListeners();
    }
  }

  Future getAllPollComments(String postId, String sortBy) async {
    try {
      Response response = await PollRepo().getAllPollComments(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllPollCommentsList = response.data;
        notifyListeners();
      }
    } catch (e, st) {
      log("Error fetching comments: $e --- $st");
    }
  }

  // Clear cache when needed (optional)
  void clearPollCache(int postId) {
    _pollCache.remove(postId);
    notifyListeners();
  }
}*/
