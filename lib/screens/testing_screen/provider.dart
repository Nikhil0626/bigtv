import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/all_post_comment_model.dart';
import '../home_screen/home_screen_model.dart';

class FlipProvider extends ChangeNotifier {
  List<HomeScreenModel> mainArticlesData = [];
  List<HomeScreenModel> districtArticlesData = [];
  List<AllPostCommentModel> allPostCommentModelList = [];
  int isTab = 0;
  bool isShowTopBottomView = true;
  bool isLastPost = false;
  bool fromLocation = false;

  void isTabChange(val, BuildContext context, {bool isMainPage = false}) {
    // if(){
    //   context.read<HomeBloc>().add(MenuItemClickEvent(
    //       context: context, currentMenuItem: "లొకేషన్స్"));
    //   return ;
    // }
    isTab = val;
    if (!isMainPage) {
      notifyListeners();
    }
  }

  void isShowTopBottomChange(val) {
    print("set change value $val");
    isShowTopBottomView = !val;
    notifyListeners();
  }

  int initialIndex = 0;
  int lastPostIdInMain = 0;
  int lastPostIdInDistrict = 0;

  void setIndex(val) {
    print("set Index $val");
    initialIndex = val;
    if (val == 0) {
      isShowTopBottomChange(isShowTopBottomView);
    } else if (val == 1) {
      isShowTopBottomChange(!isShowTopBottomView);
    }
  }

  bool isLoading = false;
  bool isRefresh = false;

  Future<void> getArticles({bool refresh = false, int index = 0,bool isMain = true}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String locationId = sp.getString("locationId") ?? "";
    String loginId = sp.getString("loginId") ?? "";
    String deviceId = GlobalVariables().deviceId ?? "";


    if (refresh == true) {
      isLoading = true;
      isRefresh = true;
      notifyListeners();

      final Map<String, dynamic> queryParams = isTab == 1
          ? {
              'userid': loginId ?? "",
              'postid': "0",
              'lpostid': "0",
              'homefeed': "1",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
              'locationIds': locationId,
            }
          : {
              'userid': loginId ?? "",
              'postid': "0",
              'lpostid': "0",
              'includeHomePage': "0",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
            };
      getData(queryParams);
      isLoading = false;
      notifyListeners();
    } else if (index != 0 && isTab == 0) {
      log("Home index $index");

      final Map<String, dynamic> queryParams = {
        'userid': loginId ?? "",
        'postid': lastPostIdInMain.toString(),
        'lpostid': "0",
        // 'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      log(queryParams.toString());
      getData(queryParams);
    } else if (index != 0 && isTab == 1) {
      log("State index $index");

      final Map<String, dynamic> queryParams = {
        'userid': loginId ?? "",
        'postid': lastPostIdInDistrict.toString(),
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
      };
      log(queryParams.toString());
      getData(queryParams);
    } else {
      log("elseeeeee $index");
      final Map<String, dynamic> queryParams = isTab != 0
          ? {
              'userid': loginId ?? "",
              'postid': "0",
              'lpostid': "0",
              'homefeed': "1",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
              'locationIds': locationId,
            }
          : {
              'userid': loginId,
              'postid': "0",
              'lpostid': "0",
              'includeHomePage': "0",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
            };
      log(queryParams.toString());
      getData(queryParams,isMain: isMain);
    }
  }

  Future getData(queryParams,{bool isMain = false}) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['posts'];
    List<HomeScreenModel> data =
        jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();

    if (isTab == 0) {
      // mainArticlesController.add([]);
      if (isRefresh||isMain) {
        log("siva");
        if (!mainArticlesController.isClosed) {
          mainArticlesController.add([]);
        }
        mainArticlesData = [];
        notifyListeners();
      }
      mainArticlesData.addAll(data);
      if (mainArticlesData.isEmpty) {
        isLastPost = true;
      }
      lastPostIdInMain = mainArticlesData.last.id;
      log(mainArticlesData.length.toString());
      mainArticlesController.add(data);
    } else if (isTab == 1) {
      if (isRefresh || fromLocation) {
        log("siva");
        districtArticlesController.add([]);
        districtArticlesData = [];
        notifyListeners();
      }
      districtArticlesData.addAll(data);
      if (districtArticlesData.isEmpty) {
        isLastPost = true;
      }
      lastPostIdInDistrict = districtArticlesData.last.id;
      log(lastPostIdInDistrict.toString());

      districtArticlesController.add(data);
    }

    isRefresh = false;
    notifyListeners();
  }


  final BehaviorSubject<List<HomeScreenModel>> districtArticlesController = BehaviorSubject<List<HomeScreenModel>>();
  final BehaviorSubject<List<HomeScreenModel>> mainArticlesController = BehaviorSubject<List<HomeScreenModel>>();


  Stream<List<HomeScreenModel>> get mainArticles =>
      mainArticlesController.stream;

  Stream<List<HomeScreenModel>> get districtArticles =>
      districtArticlesController.stream;

  @override
  void dispose() {
    // mainArticlesController.close();
    // districtArticlesController.close();
     super.dispose();
  }

  bool isSendComment = false;

  Future<void> getAllPostById(String postId) async {
    isSendComment = true;
    try {
      Response response = await HomeRepo().getAllCommentByPost(postId);
      List data = response.data['comments'];

      List<AllPostCommentModel> newComments =
      data.map((e) => AllPostCommentModel.fromJson(e)).toList();
      for (var comment in newComments) {
        if (!allPostCommentModelList.contains(comment)) {
          log(comment.postId.toString());
          allPostCommentModelList.map((e) {
            if(e.postId != comment.postId){
              allPostCommentModelList.add(comment);
            }
          },);
        }
      }

      log(response.data.toString());
    } on DioException catch (e) {
      log("Get News API error: ${e.toString()}");
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
    } finally {
      isSendComment = false;
      notifyListeners();
    }
  }




  Future addCommentPostById(postData, comment) async {
    isSendComment = true;
    notifyListeners();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loginId = sp.getString("loginId") ?? "";
    String userName = sp.getString("userName") ?? "";
    Map<String, dynamic> body = {
      "UserId": loginId??"",
      "PostId": postData.toString(),
      "Content": comment
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().addCommentByPost(body);
      log(response.data.toString());
      DateTime now = DateTime.now().add(const Duration(minutes: -330));
      String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
      log({"_id": 0000, "postId":int.parse( postData.toString()), "text":comment, "status": 1, 'displayText': comment, "userId": 0, 'createdAt': formattedDate, "user": {"_id":int.parse( loginId.toString()) , "name": userName, "avatar": null}, "redisId": ""}.toString());

      if (response.statusCode == 200) {
        allPostCommentModelList.insert(
          0,
          AllPostCommentModel.fromJson({"_id": 0000, "postId":int.parse( postData.toString()), "text":comment, "status": 1, 'displayText': comment, "userId": 0, 'createdAt': formattedDate, "user": {"_id":int.parse( loginId.toString()) , "name": userName, "avatar": null}, "redisId": ""}),
        );
        isSendComment = false;
        notifyListeners();
      }
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isSendComment = false;
      notifyListeners();
    }


  }

  List<String> isLikeList = [];

  void isLikePost(val) async {
    log(val.toString());
    if (!isLikeList.contains(val)) {
      isLikeList.add(val);
      log(isLikeList.toString());
    } else {
      isLikeList.remove(val);
      log(isLikeList.toString());
    }
    notifyListeners(); // Notify listeners if using ChangeNotifier
  }

  void isLocationChange(val){
    fromLocation = val;
    notifyListeners();
  }


  List<String> isLikeByCommentList = [];

  void isLikeByComment(val) async {
    log(val.toString());
    if (!isLikeByCommentList.contains(val)) {
      isLikeByCommentList.add(val);
      log(isLikeByCommentList.toString());
    } else {
      isLikeByCommentList.remove(val);
      log(isLikeByCommentList.toString());
    }
    notifyListeners(); // Notify listeners if using ChangeNotifier
  }
}


