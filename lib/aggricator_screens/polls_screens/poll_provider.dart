import 'dart:developer';

import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_toasts.dart';

class PollProvider with ChangeNotifier {

  final TextEditingController commentController = TextEditingController();
  int? userVotedOptionId;
  int? tempSelectedOptionId;
  late Map<String, dynamic> localArticle;

  void addData(artical) async {
    tempSelectedOptionId = null;
    log('Hello siva kumar');
    loadPollFromHive(artical);
  }

  void clearData() async {
    final box = Hive.box('pollBox');
    await box.clear();
    localArticle = {};
    userVotedOptionId = null;
    tempSelectedOptionId = null;
    log('🧹 All Hive data cleared from pollBox');
    notifyListeners();
  }

  Future<void> loadPollFromHive(artical) async {
    final box = Hive.box('pollBox');
    final postId = artical['id'];
    if (postId != null) {
      log('Hello siva kumar1');
      List<dynamic> storedPosts = box.get('pollPosts', defaultValue: []);
      final existingPost = storedPosts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => {},
      );

      if (existingPost.isNotEmpty) {
        log('Hello siva kumar2');
        localArticle = Map<String, dynamic>.from(existingPost);
        if (localArticle['pollData']['userHasVoted'] == true) {
          log('Hello siva kumar3');
          final votedOption = (localArticle['pollData']['options'] as List).firstWhere((opt) => opt['selected'] == true, orElse: () => null);
          if (votedOption != null) {
            log('Hello siva kumar4');
            userVotedOptionId = votedOption['id'];
          }
        }
      } else {
        log('Hello siva kumar5');
        // localArticle = Map<String, dynamic>.from(existingPost);
        await storePostInHive(artical); // If not stored yet
      }
      localArticle = Map<String, dynamic>.from(artical);

      notifyListeners();
    }
  }

  Future<void> storePostInHive(artical) async {

    final box = Hive.box('pollBox');
    final postId = artical['id'];
    if (postId != null) {

      List<dynamic> storedPosts = box.get('pollPosts', defaultValue: []);
      final alreadyExists = storedPosts.any((post) => post['id'] == postId);

      if (!alreadyExists) {
        storedPosts.add(artical);
        log("save current post $storedPosts");
        await box.put('pollPosts', storedPosts);
        notifyListeners();
      }
    }
  }

  Future<void> updatePollVoteInHive({
    required int postId,
    required int optionId,
    required Map<String, dynamic> commentBody,
  }) async {
    final box = Hive.box('pollBox');
    List<dynamic> storedPosts = box.get('pollPosts', defaultValue: []);
    final postIndex = storedPosts.indexWhere((post) => post['id'] == postId);

    if (postIndex != -1) {
      final post = Map<String, dynamic>.from(storedPosts[postIndex]);
      final options = List<Map<String, dynamic>>.from(post['pollData']['options']);
      int totalVotes = 0;

      for (var option in options) {
        if (option['id'] == optionId) {
          option['votes'] = (option['votes'] ?? 0) + 1;
          option['selected'] = true;
        } else {
          option['selected'] = false;
        }
        totalVotes += ((option['votes'] ?? 0) as num).toInt();
      }

      for (var option in options) {
        option['percentage'] = ((option['votes'] / totalVotes) * 100).toDouble();
      }

      post['pollData']['options'] = options;
      post['pollData']['userHasVoted'] = true;
      post['pollData']['totalVotes'] = totalVotes;
      if (commentBody.isNotEmpty) {
        if (post['topComments'] == null || (post['topComments'] as List).isEmpty) {
          post['topComments'] = [commentBody]; // add as new list
        } else {
          (post['topComments'] as List).add(commentBody); // append to existing list
        }
      }


      storedPosts[postIndex] = post;
      await box.put('pollPosts', storedPosts);

      // Update UI state
      // setState(() {
        localArticle = post;
        userVotedOptionId = optionId;
        commentController.text ="";
      // });
      notifyListeners();
    }
  }

  Future<void> submitPolls(int postId, int index, pollsOptions, {VoidCallback? onSuccess}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? userName = sp.getString("userName");

    final body = {
      "post_id": postId,
      "user_id": userId ?? "0",
      "selected_option": pollsOptions,
      "comment": commentController.text.trim(),
    };

    log("Request Body: $body");

    try {
      Response response = await PollRepo().submitPolls(body);
      log("Response: ${response.data}");
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      if (response.statusCode == 200) {
        final commentBody = {
          "userName": userName ?? "user",
          "userPhoto": null,
          "comment": commentController.text.trim(),
          "createdAt": formatter.format(DateTime.now().add(const Duration(hours: -5, minutes: -30))),
        };


          updatePollVoteInHive(optionId: pollsOptions, postId: postId,commentBody: commentController.text.isNotEmpty?commentBody:{});

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

// var selectedIndex;
// List<int> votes = [];
// List listOfComments = [];
//
// bool isCommentPost = false;
// Map<String, List<Map<String, dynamic>>> commentsByPostId = {};
//
// void initialPollData(List<dynamic> votesList) {
//   if (votes.isEmpty) {
//     votes.addAll(votesList.map((e) => e['votes'] as int));
//     notifyListeners();
//   }
// }
//
// void setSelectedIndex(int index) {
//   selectedIndex = index;
//   notifyListeners();
// }
//
// Set<int> ratedArticleIds = {};
//
// void markAsRated(int articleId) {
//   ratedArticleIds.add(articleId);
//   notifyListeners();
// }

// void addAllComments(articleComments, postId) {
//
//   for (var s in articleComments) {
//
//     listOfComments.add({"postId": postId ?? 0, "data": s});
//   }
//    isCommentPost = listOfComments.any((e) => e['postId'] == postId);
//   listOfComments = listOfComments
//       .map((e) => jsonEncode(e)) // Convert each map to string
//       .toSet() // Remove duplicates
//       .map((e) => jsonDecode(e)) // Convert back to map
//       .toList();
//   log("Add All Comments $listOfComments");
//   notifyListeners();
// }
//
// bool isArticleRated(int articleId) {
//   return ratedArticleIds.contains(articleId);
// }

// void updatePollData(int index) {
//   if (index >= 0 && index < votes.length) {
//     votes[index]++;
//   }
//   selectedIndex = null;
//   notifyListeners();
// }
//
  Map<dynamic, dynamic> getAllPollCommentsList = {};

bool isLoading = false;
  Future getAllPollComments(String postId, name) async {
    isLoading = true;
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
    }finally{
      isLoading = false;
      notifyListeners();
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
