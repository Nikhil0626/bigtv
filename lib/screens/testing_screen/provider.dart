import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/screens/videos_main/videos_model/videos_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  void isTabChange(val,{bool isMainPage =false}) {
    isTab = val;
    if(!isMainPage){
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

  Future<void> getArticles({bool refresh = false, int index = 0}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String locationId = sp.getString("locationId") ?? "";
    String deviceId = GlobalVariables().deviceId ?? "";


    if (refresh == true) {
      isLoading = true;
      isRefresh = true;
      notifyListeners();
      final Map<String, dynamic> queryParams = isTab == 1
          ? {
              'userid': "1",
              'postid': "0",
              'lpostid': "0",
              'homefeed': "1",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
              'locationIds': locationId,
            }
          : {
              'userid': "1",
              'postid': "0",
              'lpostid': "0",
              'includeHomePage': "0",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
            };
      getData(queryParams);
      isLoading = false;
      notifyListeners();
    }
    else if (index != 0 && isTab == 0) {
      log("Home index $index");

      final Map<String, dynamic> queryParams = {
        'userid': GlobalVariables().userId.toString(),
        'postid': lastPostIdInMain.toString(),
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      log(queryParams.toString());
      getData(queryParams);
    } else if (index != 0 && isTab == 1) {
      log("State index");

      final Map<String, dynamic> queryParams = {
        'userid': GlobalVariables().userId.toString(),
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
              'userid': GlobalVariables().userId.toString(),
              'postid': "0",
              'lpostid': "0",
              'homefeed': "1",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
              'locationIds': locationId,
            }
          : {
              'userid': GlobalVariables().userId.toString(),
              'postid': "0",
              'lpostid': "0",
              'includeHomePage': "0",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
            };
      log(queryParams.toString());
      getData(queryParams);
    }
  }

  Future getData(queryParams) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['posts'];
    List<HomeScreenModel> data =
        jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();

    if (isTab == 0) {
      // if (isRefresh) {
      //   log("siva");
        mainArticlesController.add([]);
        mainArticlesData = [];
        notifyListeners();
      // }
      mainArticlesData.addAll(data);
      lastPostIdInMain = mainArticlesData.last.id;
      log(mainArticlesData.length.toString());
      mainArticlesController.add(mainArticlesData);
    } else if (isTab == 1) {
      // if (isRefresh) {
      //   log("siva");
        districtArticlesController.add([]);
        districtArticlesData = [];
        notifyListeners();
      // }
      districtArticlesData.addAll(data);
      lastPostIdInDistrict = districtArticlesData.last.id;
      log(lastPostIdInDistrict.toString());
      districtArticlesController.add(districtArticlesData);
    }

    isRefresh = false;
    notifyListeners();
  }

  bool isIconcolor = false;

  updateColor() {
    isIconcolor = !isIconcolor;
    notifyListeners();
  }

  final StreamController<List<HomeScreenModel>> districtArticlesController =
      StreamController<List<HomeScreenModel>>.broadcast();
  final StreamController<List<HomeScreenModel>> mainArticlesController =
      StreamController<List<HomeScreenModel>>.broadcast();

  Stream<List<HomeScreenModel>> get mainArticles =>
      mainArticlesController.stream;

  Stream<List<HomeScreenModel>> get districtArticles =>
      districtArticlesController.stream;

  @override
  void dispose() {
    districtArticlesController
        .close();
    mainArticlesController.close();
    super.dispose();
  }

  bool isSendComment = false;

  Future getAllPostById(postId) async {
    isSendComment = true;
    notifyListeners();
    try {
      Response response = await HomeRepo().getAllCommentByPost(postId);
      List data = response.data['comments'];
      allPostCommentModelList = data.map((e)=> AllPostCommentModel.fromJson(e),).toList();
      log(response.data.toString());
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    }finally{
      isSendComment = false;
      notifyListeners();
    }
  }

  Future addCommentPostById(postData, comment) async {
    isSendComment = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "UserId": GlobalVariables().userId.toString(),
      "PostId": postData.toString(),
      "Content": comment
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().addCommentByPost(body);
      log(response.data.toString());

      if (response.statusCode == 200) {
        getAllPostById(postData.toString());
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

  void handelLeftDragStart(DragStartDetails details,){
    log("vertical dra start");
    notifyListeners();

  }
  void handelLeftDragUpdate(DragUpdateDetails details){
    log("vertical dra update");
    notifyListeners();

  }
}
