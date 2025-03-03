import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo/home_repo.dart';
import 'package:chotanews/utils/local_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/app_router.dart';
import '../../../globel_keys/global_variables_data.dart';
import '../../../services/webengage_event_tracks.dart';
import '../home_models/all_post_comment_model.dart';
import '../home_models/home_screen_model.dart';

class FlipProvider extends ChangeNotifier {
  List<HomeScreenModel> mainArticlesData = [];
  List<HomeScreenModel> districtArticlesData = [];
  List<AllPostCommentModel> allPostCommentModelList = [];
  int isTab = 0;
  bool isShowTopBottomView = true;
  bool isLastPost = false;
  bool fromLocation = false;

  String? get userId => _userId;

  String get deviceId => _deviceId!;

  void isTabChange(val, BuildContext context, {bool isMainPage = false}) {
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

  int flipCount = 0;

  Future<void> loadUserId(count) async {
    _userId = await getUserid();
    log(_userId.toString());
    flipCount = flipCount + 1;
    sandFlipData(userId, flipCount, isTab,);
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

  Future getIndividualPost(postId) async {
    log("Push Notification Received: get Call ${postId.toString()}");
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      List data = response.data['posts'];
      HomeScreenModel getSinglePost = HomeScreenModel.fromJson(data[0]);
      List<HomeScreenModel> currentList =
          mainArticlesController.valueOrNull ?? [];
      currentList.insert(0, getSinglePost);
      mainArticlesController.add([]);
      mainArticlesController.add(currentList);
      notifyListeners();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      notifyListeners();
    }
  }

  String? _userId;
  String? _deviceId;

  Future isDeviceData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _userId = getUserid().toString();
    _deviceId = preferences.getString("");
  }

  Future<void> getArticles(
      {bool refresh = false, int index = 0, bool isMain = true}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String locationId = sp.getString("locationId") ?? "";
    String loginId = sp.getString("loginId") ?? "1";
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
      isLoading = false;
      log(queryParams.toString());
      getData(queryParams);
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
      fromLocation = false;
      getData(queryParams);
    } else {
      log("elseeeeee $index");
      final Map<String, dynamic> queryParams = isTab != 0
          ? {
              'userid': loginId ?? "1",
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
      getData(queryParams, isMain: isMain);
    }
  }

  Future getData(queryParams, {bool isMain = false}) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['posts'];
    List<HomeScreenModel> data =
        jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
    if (isTab == 0) {
      if (isRefresh) {
        log("siva $isTab");

        // Clear the previous data properly
        mainArticlesData.clear();
        isLastPost = false; // Reset last post flag

        // Refresh Stream
        mainArticlesController.sink.add([]);
      }

      // Append new data and update stream
      mainArticlesData.addAll(data);

      if (mainArticlesData.isEmpty) {
        isLastPost = true;
      } else {
        lastPostIdInMain = mainArticlesData.last.id;
      }

      log(mainArticlesData.length.toString());

      // Send updated data to stream
      mainArticlesController.add(data);
      notifyListeners();
    } else if (isTab == 1) {
      if (isRefresh || fromLocation) {
        log("siva $isTab");

        // Clear the previous data properly
        districtArticlesData.clear();
        isLastPost = false; // Reset last post flag

        // Refresh Stream
        districtArticlesController.add([]);
      }

      // Append new data and update stream
      districtArticlesData.addAll(data);

      if (districtArticlesData.isEmpty) {
        isLastPost = true;
      } else {
        lastPostIdInDistrict = districtArticlesData.last.id;
      }

      log(lastPostIdInDistrict.toString());

      // Send updated data to stream
      districtArticlesController.add(data);
      notifyListeners();
    }

    // if (isTab == 0) {
    //   // mainArticlesController.add([]);
    //   if (isRefresh) {
    //     log("siva  $isTab");
    //       mainArticlesController.add([]);
    //     mainArticlesData = [];
    //     notifyListeners();
    //   }
    //   mainArticlesData.addAll(data);
    //   if (mainArticlesData.isEmpty) {
    //     isLastPost = true;
    //   }
    //   lastPostIdInMain = mainArticlesData.last.id;
    //   log(mainArticlesData.length.toString());
    //   mainArticlesController.add(data);
    // }
    // else if (isTab == 1) {
    //   if (isRefresh ) {
    //     log("siva  $isTab");
    //     districtArticlesController.add([]);
    //     districtArticlesData = [];
    //     notifyListeners();
    //   }
    //   districtArticlesData.addAll(data);
    //   if (districtArticlesData.isEmpty) {
    //     isLastPost = true;
    //   }
    //   lastPostIdInDistrict = districtArticlesData.last.id;
    //   log(lastPostIdInDistrict.toString());
    //
    //   districtArticlesController.add(data);
    // }

    isRefresh = false;
    notifyListeners();
  }

  final BehaviorSubject<List<HomeScreenModel>> districtArticlesController =
      BehaviorSubject<List<HomeScreenModel>>();
  final BehaviorSubject<List<HomeScreenModel>> mainArticlesController =
      BehaviorSubject<List<HomeScreenModel>>();

  Stream<List<HomeScreenModel>> get mainArticles =>
      mainArticlesController.stream;

  Stream<List<HomeScreenModel>> get districtArticles =>
      districtArticlesController.stream;

  @override
  void dispose() {
    super.dispose();
  }

  bool isSendComment = false;

  Future<void> getAllPostById(String postId) async {
    isSendComment = true;
    allPostCommentModelList = [];


    try {
      Response response = await HomeRepo().getAllCommentByPost(postId);
      List data = response.data['comments'];
      print("comment list  ${data.toString()}");
      print("comment list  ${localCommentsList.length.toString()}");
      allPostCommentModelList =
      data.map((e) => AllPostCommentModel.fromJson(e)).toList();

      for(var record in localCommentsList){
        print("comment id  ${record.postId}========= ${postId.toString()}");
        if(record.postId.toString()==postId.toString()){
          allPostCommentModelList.add(record);
          // if(allPostCommentModelList.isEmpty){
          //   allPostCommentModelList.add(record);
          // }else{
          //   allPostCommentModelList.map((e) {
          //     print("comment id 123c  ${e.postId.toString()}-------${record.postId.toString()}");
          //     if(e.postId.toString() == record.postId.toString()){
          //       allPostCommentModelList.add(record);
                // localCommentsList.remove(record);
          //     };
          //   },);
          // }
        }



      }



    } on DioException catch (e) {
      log("Get News API error: ${e.toString()}");
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
    } finally {
      isSendComment = false;
      notifyListeners();
    }
  }



  List<AllPostCommentModel> localCommentsList=[];
  Future addCommentPostById( postData, comment) async {
    isSendComment = true;
    notifyListeners();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loginId = sp.getString("loginId") ?? "";
    String userName = sp.getString("userName") ?? "";
    Map<String, dynamic> body = {
      "UserId": loginId ?? "",
      "PostId": postData.id.toString(),
      "Content": comment
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().addCommentByPost(body);
      log(response.data.toString());
      DateTime now = DateTime.now().toUtc();
      String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
      print(formattedDate.toString());
      if (response.statusCode == 200) {
        localCommentsList.add(
          AllPostCommentModel.fromJson({
            "_id": 0000,
            "postId": int.parse(postData.id.toString()),
            "text": comment,
            "status": 1,
            'displayText': comment,
            "userId": 0,
            'createdAt': now.toString(),
            "user": {
              "_id": int.parse(loginId.toString()),
              "name": userName,
              "avatar": null
            },
            "redisId": ""
          }),
        );
        allPostCommentModelList.add(AllPostCommentModel.fromJson({
          "_id": 0000,
          "postId": int.parse(postData.id.toString()),
          "text": comment,
          "status": 1,
          'displayText': comment,
          "userId": 0,
          'createdAt': now.toString(),
          "user": {
            "_id": int.parse(loginId.toString()),
            "name": userName,
            "avatar": null
          },
          "redisId": ""
        }));
        sendCommentDetails(userId, postData.id, true,postData.title);
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

  void isLikePost( val) async {
    log(val.id.toString());
    if (!isLikeList.contains(val.id.toString())) {
      isLikeList.add(val.id.toString());
      sendLikeDetails(userId, val, true,val.title.toString());
      log(isLikeList.toString());
    } else {
      isLikeList.remove(val.id.toString());
      sendLikeDetails(userId, val.id.toString(), false,val.title.toString());
      log(isLikeList.toString());
    }

    notifyListeners(); // Notify listeners if using ChangeNotifier
  }

  void isLocationChange(val) {
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

  Future menuChange(currentMenuItem, context) async {
    if (currentMenuItem == "హోమ్") {
      Navigator.pushNamed(context, RoutesManager.homeScreen,
          arguments: {"postId": "", "tab": "0"});
    } else if (currentMenuItem == "లొకేషన్స్") {
      Navigator.pushNamed(context, RoutesManager.districtSelectionScreen,
          arguments: {
            "className": "Home",
          });
    } else {
      Navigator.pushNamed(
        context,
        RoutesManager.getAllMenuItemScreen,
      );
    }
  }
}
