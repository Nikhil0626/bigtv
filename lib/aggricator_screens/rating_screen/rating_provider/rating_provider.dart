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
    getReviews(rating,isFilterData?"highest_rated":"lowest_rated");
  }

  Future<void> postSubmitRating(article, rated) async {
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
        isRated = true;
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
    }finally{
      notifyListeners();
    }
  }



  Map<String, dynamic> getAllReviews = {};

  Future getReviews(String postId,name) async {

    Map<String, dynamic> body ={
      "sort_by":name,

    };
    try {
      Response response = await RatingRepo().getReviews(postId,body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getAllReviews = response.data;
        notifyListeners();
        log(getAllReviews.toString());
      }
    } catch (e, st) {}
  }
  //
  // Future<void> postPolling(article) async   {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userId = preferences.getString("userId");
  //   Map<String, dynamic> body = {
  //     "post_id": int.parse(article.toString()) ?? 0,
  //     "user_id": userId ?? "",
  //     "comment": commentController.text,
  //     "selected_option": (selectedOption! + 1).toString(),
  //   };
  //   log(body.toString());
  //   try {
  //     // Response response = await RatingRepo().postPolling(body);
  //     if (response.statusCode == 201) {
  //     }
  //   } catch (e, st) {
  //     print(e.toString());
  //     print(st.toString());
  //   }
  // }
  //
  //
  // Future getComments(String postId) async {
  //   try {
  //     Response response = await RatingRepo().getComments(postId);
  //     log(response.data.toString());
  //     if (response.statusCode == 200) {
  //       notifyListeners();
  //     }
  //   } catch (e, st) {}
  // }

}
