import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/app_toasts.dart';
import '../../events_data/event_repo.dart';
import '../rating_model.dart';
import '../rating_repo/rating_repo.dart';

class RatingProvider extends ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int selectedStar = 0;
  int selectedOption = 0;
  bool isLoading = false;
  bool isRated = false;
  List<Map<String, dynamic>> ratingsList = [];

  // Movie review breakdown & critic scores
  MovieReviewDetails? movieReviewDetails;
  Map<String, dynamic> getAllReviews = {};
  final Map<String, List<dynamic>> _postReviewsMap = {};
  bool isLoadingComments = false;
  bool isFilterData = false;

  Set<int> ratedArticleIds = {};

  List<dynamic> getReviewsForPost(String postId) {
    if (_postReviewsMap.containsKey(postId)) {
      return _postReviewsMap[postId] ?? [];
    }
    return (getAllReviews['reviews'] as List?) ?? [];
  }

  void addLocalReview(String postId, Map<String, dynamic> review) {
    _postReviewsMap.putIfAbsent(postId, () => []);
    _postReviewsMap[postId]!.removeWhere((r) => r is Map && r['comment'] == review['comment']);
    _postReviewsMap[postId]!.insert(0, review);
    notifyListeners();
  }

  // Add or update rating properly
  void ratingUpdate(int rating, dynamic article, {bool isNew = false}) {
    String postId = article.toString();

    final existingIndex = ratingsList.indexWhere(
      (element) => element['postId'].toString() == postId,
    );

    if (existingIndex != -1) {
      ratingsList[existingIndex]['starRating'] = rating;
    } else {
      ratingsList.add({"postId": postId, "starRating": rating});
    }

    selectedStar = rating;
    if (!isNew) {
      notifyListeners();
    }
  }

  // Safe getPostRating without errors
  int getPostRating(dynamic article) {
    final ratingEntry = ratingsList.firstWhere(
      (element) => element['postId'].toString() == article.toString(),
      orElse: () => {},
    );

    if (ratingEntry.isEmpty) return 0;

    selectedStar = ratingEntry['starRating'] ?? 0;
    return selectedStar;
  }

  void markAsRated(int articleId) {
    ratedArticleIds.add(articleId);
    notifyListeners();
  }

  bool isArticleRated(int articleId) {
    return ratedArticleIds.contains(articleId);
  }

  // Submit or update user star rating & review comment
  Future<bool> postSubmitRating(dynamic article, dynamic rated, dynamic title) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    final parsedPostId = int.tryParse(article.toString());
    final parsedUserId = int.tryParse(userId ?? "0");

    Map<String, dynamic> body = {
      "post_id": parsedPostId ?? article.toString(),
      "user_id": parsedUserId != null && parsedUserId > 0 ? parsedUserId : (userId ?? "0"),
      "rating": selectedStar,
      "comment": commentController.text.trim(),
      "device_id": deviceId ?? "",
    };

    log("Submitting rating: $body");

    try {
      Response response = await RatingRepo().postSubmitRating(body);
      log("Submitting rating response status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        ratingsList.removeWhere((element) => element['postId'].toString() == article.toString());
        ratingsList.add({"postId": article.toString(), "starRating": selectedStar});

        markAsRated(int.tryParse(article.toString()) ?? 0);
        final commentSaved = commentController.text.trim();
        commentController.clear();

        final msg = response.data is Map ? (response.data["message"] ?? "రేటింగ్ విజయవంతంగా నమోదు చేయబడింది!") : "రేటింగ్ విజయవంతంగా నమోదు చేయబడింది!";
        CustomToast.showSuccessToast(msg: msg);
        EventRepo().addEvent({
          "post_id": article.toString(),
          "user_id": userId ?? "",
          "post_title": title?.toString() ?? "",
          "rating": selectedStar,
          "comment": commentSaved,
          "device_id": deviceId.toString(),
        }, "submit_rating");
        return true;
      } else {
        final errorMsg = response.data is Map ? (response.data["message"] ?? "సమర్పించడం విఫలమైంది") : "సమర్పించడం విఫలమైంది";
        CustomToast.showErrorToast(msg: errorMsg);
        return false;
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: e.response?.data?['message'] ?? "Something went wrong");
      log("Dio error: ${e.toString()} ---- ${st.toString()}");
      return false;
    } catch (e, st) {
      log("Catch error: $e --- $st");
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Filter reviews
  void filterData(dynamic rating) {
    isFilterData = !isFilterData;
    notifyListeners();
    getReviews(rating.toString(), isFilterData ? "highest_rated" : "lowest_rated");
  }

  // Fetch Review Details & Critic Breakdown (GET /moviereviews/{post_id})
  Future<void> getReviews(String postId, dynamic name) async {
    Map<String, dynamic> queryParams = {
      "sort_by": name?.toString() ?? "newest",
      "limit": 50,
    };
    isLoadingComments = true;
    try {
      Response response = await RatingRepo().getReviews(postId, queryParams);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          getAllReviews = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          getAllReviews = Map<String, dynamic>.from(response.data as Map);
        }
        movieReviewDetails = MovieReviewDetails.fromJson(getAllReviews);
        if (getAllReviews['reviews'] is List) {
          _postReviewsMap[postId] = List<dynamic>.from(getAllReviews['reviews'] as List);
        }
        notifyListeners();
      }
    } catch (e, st) {
      log("Review fetch error: $e --- $st");
    } finally {
      isLoadingComments = false;
      notifyListeners();
    }
  }
}
