// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../utils/app_toasts.dart';
// import '../rating_repo/rating_repo.dart';
//
// class RatingProvider extends ChangeNotifier {
//   final TextEditingController commentController = TextEditingController();
//   final FocusNode commentFocusNode = FocusNode();
//   int selectedStar = 0;
//   int selectedOption = 0;
//   bool isLoading = false;
//   bool isRated = false;
//   List ratingsList = [];
//
//   void ratingUpdate(rating, article) {
//
//     Map<String, dynamic> ratingBody = {"postId":article,"starRating":rating,};
//     log("post data $ratingBody");
//     if(rating != null) {
//       ratingsList.add(ratingBody);
//       final ratingEntry = ratingsList.firstWhere(
//             (element) => element['postId'].toString() == article.toString(),
//         orElse: () => 0,
//       );
//       selectedStar = ratingEntry['starRating'];
//     }
//
//     if(rating != 0) {
//       notifyListeners();
//     }
//   }
//    getPostRating(dynamic article) {
//     final ratingEntry = ratingsList.firstWhere(
//           (element) => element['postId'].toString() == article.toString(),
//       orElse: () => {},
//     );
//     log("rating stars $ratingEntry");
//     selectedStar = ratingEntry['starRating']??0;
//     return selectedStar != 0 ? selectedStar : 0;
//   }
//   bool isFilterData = false;
//
//   void filterData(rating) {
//     isFilterData = !isFilterData;
//     notifyListeners();
//     getReviews(rating, isFilterData ? "highest_rated" : "lowest_rated");
//   }
//
//   Set<int> ratedArticleIds = {};
//
//   void markAsRated(int articleId) {
//     ratedArticleIds.add(articleId);
//     notifyListeners();
//   }
//
//   bool isArticleRated(int articleId) {
//     return ratedArticleIds.contains(articleId);
//   }
//
//   Future<void> postSubmitRating(article, rated) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? deviceId = preferences.getString("deviceId");
//     String? userId = preferences.getString("userId");
//     Map<String, dynamic> body = {
//       "post_id": article.toString()?? 0,
//       "user_id": userId ?? "",
//       "rating": selectedStar,
//       "comment": commentController.text,
//       "device_id": deviceId,
//     };
//     log(body.toString());
//     try {
//       Response response = await RatingRepo().postSubmitRating(body);
//       log(response.data.toString());
//       if (response.statusCode == 201) {
//         Map<String, dynamic> ratingBody = {"postId":article.toString(),"starRating":selectedStar,};
//         ratingsList.add(ratingBody);
//         markAsRated(int.tryParse(article.toString()) ?? 0);
//         commentController.text = "";
//         CustomToast.showSuccessToast(
//           msg: response.data["message"],
//         );
//       } else {}
//     } on DioException catch (e, st) {
//       CustomToast.showErrorToast(msg: "something went wrong");
//       log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
//     } catch (e, st) {
//       log("Hello siva catch $e --- $st");
//       ;
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   Map<String, dynamic> getAllReviews = {};
//
//   Future getReviews(String postId, name) async {
//     Map<String, dynamic> body = {
//       "sort_by": name,
//     };
//     try {
//       Response response = await RatingRepo().getReviews(postId, body);
//       log(response.data.toString());
//       if (response.statusCode == 200) {
//         getAllReviews = response.data;
//         notifyListeners();
//         log(getAllReviews.toString());
//       }
//     } catch (e, st) {
//       log("Hello siva catch $e --- $st");
//     }
//   }
// }

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
  List<Map<String, dynamic>> ratingsList = [];

  // ✅ Updated: Add or update rating properly
  void ratingUpdate(int rating, dynamic article,{bool isNew = false}) {
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
    if(!isNew) {
      notifyListeners();
    }
  }

  // ✅ Updated: Safe getPostRating without errors
  int getPostRating(dynamic article) {
    final ratingEntry = ratingsList.firstWhere(
      (element) => element['postId'].toString() == article.toString(),
      orElse: () => {},
    );

    if (ratingEntry.isEmpty) return 0;

    selectedStar = ratingEntry['starRating'] ?? 0;
    return selectedStar;
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
      "post_id": article.toString(),
      "user_id": userId ?? "",
      "rating": selectedStar,
      "comment": commentController.text,
      "device_id": deviceId,
    };

    log("Submitting rating: $body");

    try {
      Response response = await RatingRepo().postSubmitRating(body);

      if (response.statusCode == 201) {
        // ✅ Safely replace or add new entry
        ratingsList.removeWhere((element) => element['postId'].toString() == article.toString());
        ratingsList.add({"postId": article.toString(), "starRating": selectedStar});

        markAsRated(int.tryParse(article.toString()) ?? 0);
        commentController.clear();

        CustomToast.showSuccessToast(msg: response.data["message"]);
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: "Something went wrong");
      log("Dio error: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Catch error: $e --- $st");
    } finally {
      notifyListeners();
    }
  }

  // Review logic
  bool isFilterData = false;
  Map<String, dynamic> getAllReviews = {};

  void filterData(rating) {
    isFilterData = !isFilterData;
    notifyListeners();
    getReviews(rating, isFilterData ? "highest_rated" : "lowest_rated");
  }

  bool isLoadingComments = false;

  Future getReviews(String postId, name) async {
    Map<String, dynamic> body = {
      "sort_by": name,
    };
    isLoadingComments = true;
    try {
      Response response = await RatingRepo().getReviews(postId, body);
      if (response.statusCode == 200) {
        getAllReviews = response.data;
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
