import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_toasts.dart';
import '../rating_repo/rating_repo.dart';

class RatingProvider extends ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  int selectedStar = 0;
  int selectedOption = 0;
  bool isLoading = false;
  bool isRated = false;

  void ratingUpdate(rating) {
    selectedStar = rating;
    notifyListeners();
  }

  bool isFilterData = false;

  void filterData(rating) {
    isFilterData = !isFilterData;
    notifyListeners();
    getReviews(rating, isFilterData ? "highest_rated" : "lowest_rated");
  }

  Set<int> ratedArticleIds = {};

  void markAsRated(int articleId) {
    ratedArticleIds.add(articleId);
    notifyListeners();
  }

  bool isArticleRated(int articleId) {
    return ratedArticleIds.contains(articleId);
  }

  Future<void> postSubmitRating(article, rated) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "post_id": article.toString()?? 0,
      "user_id": userId ?? "",
      "rating": selectedStar,
      "comment": commentController.text,
      "device_id": deviceId,
    };
    log(body.toString());
    try {
      Response response = await RatingRepo().postSubmitRating(body);
      log(response.data.toString());
      if (response.statusCode == 201) {
        markAsRated(int.tryParse(article.toString()) ?? 0);
        commentController.text = "";
        CustomToast.showSuccessToast(
          msg: response.data["message"],
        );
      } else {}
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: "something went wrong");
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Hello siva catch $e --- $st");
      ;
    } finally {
      notifyListeners();
    }
  }

  Map<String, dynamic> getAllReviews = {};

  Future getReviews(String postId, name) async {
    Map<String, dynamic> body = {
      "sort_by": name,
    };
    try {
      Response response = await RatingRepo().getReviews(postId, body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllReviews = response.data;
        notifyListeners();
        log(getAllReviews.toString());
      }
    } catch (e, st) {
      log("Hello siva catch $e --- $st");
    }
  }
}
