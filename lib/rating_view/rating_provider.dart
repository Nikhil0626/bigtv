import 'dart:developer';
import 'package:chotanews/rating_view/rating_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_toasts.dart';

class RatingProvider extends ChangeNotifier {
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  int selectedStar = 0;
  bool isLoading = false;

  void ratingUpdate(rating) {
    selectedStar = rating;
    notifyListeners();
  }

  Future<void> postSubmitRating(article) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "post_id": int.parse(article.toString()) ?? 0,
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
        CustomToast.showSuccessToast(
          msg: response.data["message"],
        );
      } else {}
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: "something went wrong");
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      print(e.toString());
      print(st.toString());
    }
  }

  Map<String, dynamic> getAllReviews = {};

  Future getReviews(String postId) async {
    try {
      Response response = await RatingRepo().getReviews(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllReviews = response.data;
        notifyListeners();
        log(getAllReviews.toString());
      }
    } catch (e, st) {}
  }
}
