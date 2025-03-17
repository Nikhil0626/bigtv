import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo/home_repo.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/utils/local_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/app_router.dart';
import '../../../globel_keys/global_variables_data.dart';
import '../../../services/deviice_details.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../Auth_module/auth_provider/auth_provider.dart';
import '../home_models/all_post_comment_model.dart';
import '../home_models/home_screen_model.dart';
import '../home_repo/event_repo.dart';

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



  NativeAd? _nativeAd;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;
  NativeAd? get nativeAd => _nativeAd;
  BannerAd? get bannerAd => _bannerAd;

  void closeAds() {
    // nativeAd!.dispose();
    _isAdLoaded = false;
    notifyListeners();
  }
  void loadAds() {

    // _bannerAd = BannerAd(
    //   adUnitId: 'ca-app-pub-2405357352181832/9297875326',
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(),
    // )..load();
    // _nativeAd!.dispose();

  }

  void isTabChange(val, BuildContext context, {bool isMainPage = false}) {
    if(isTab ==0){
      context.read<AuthProvider>().sendEvent("HomePage");

    }else{
      context.read<AuthProvider>().sendEvent("DistrictPage");

    }
    isTab = val;
    if (!isMainPage) {
      notifyListeners();
    }
  }
  //
  // Future<void> trackArticlesRead() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String today = DateTime.now().toString().substring(0, 10);
  //   int count = prefs.getInt("articles_read_$today") ?? 0;
  //   count++;
  //   prefs.setInt("articles_read_$today", count);
  //
  //   if (count == 10) {
  //     logEvent("user_red_10_article_on_day_0", null);
  //   }
  //   if (count == 20) {
  //     logEvent("user_red_20_article_on_day_0", null);
  //   }
  // }

  void isShowTopBottomChange(val,) {
    print("set change value $val");
    isShowTopBottomView = !val;
    notifyListeners();
  }

  void flipEvent(val,  index,{bool isHome =false}) {
    print("set change value $val");
    isShowTopBottomView = !val;
    EventRepo().sendEvent({"key":"flip_count",

      "data":{"deviceId": GlobalVariables().deviceId,
        "userId":_userId,
        "isFlip":val,
        "isHome":isHome,
        "postId":isHome?mainArticlesData[index].id.toString():districtArticlesData[index].id.toString(),
      }});
    AnalyticsService().trackArticlesRead();
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

    SharedPreferences sp = await SharedPreferences.getInstance();
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
    String deviceId = sp.getString("deviceId") ?? "1";
    // String deviceId = GlobalVariables().deviceId ?? "";
    getUniqueDeviceId("",);

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
        "Ads":"true"
      }
          : {
        'userid': loginId ?? "",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        "Ads":"true"
      };
      isLoading = false;
      log(queryParams.toString());
      getData(queryParams);
      notifyListeners();
    }
    else if (index != 0 && isTab == 0) {
      log("Home index $index");

      final Map<String, dynamic> queryParams = {
        'userid': loginId ?? "",
        'postid': lastPostIdInMain.toString(),
        'lpostid': "0",
        // 'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        "Ads":"true"
      };
      log(queryParams.toString());
      getData(queryParams);
    }
    else if (index != 0 && isTab == 1) {
      log("State index $index");

      final Map<String, dynamic> queryParams = {
        'userid': loginId ?? "",
        'postid': lastPostIdInDistrict.toString(),
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
        "Ads":"true"
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
        "Ads":"true"
      }
          : {
        'userid': loginId,
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        "Ads":"true"
      };
      log(queryParams.toString());
      getData(queryParams, isMain: isMain);
    }
  }

  Future getData(queryParams, {bool isMain = false}) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['response']['Posts'];
    List<HomeScreenModel> data =
    jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
    if (isTab == 0) {
      if (isRefresh) {
        log("siva $isTab");
        mainArticlesData.clear();
        isLastPost = false; // Reset last post flag
        mainArticlesController.sink.add([]);
      }

      mainArticlesData.addAll(data);

      if (mainArticlesData.isEmpty) {
        isLastPost = true;
      } else {
        lastPostIdInMain = mainArticlesData.last.id;
      }

      log(mainArticlesData.length.toString());
      mainArticlesController.add(mainArticlesData);
      notifyListeners();
    } else if (isTab == 1) {
      if (isRefresh || fromLocation) {
        log("siva $isTab");
        districtArticlesData.clear();
        isLastPost = false; // Reset last post flag
        districtArticlesController.add([]);
      }
      districtArticlesData.addAll(data);
      if (districtArticlesData.isEmpty) {
        isLastPost = true;
      } else {
        lastPostIdInDistrict = districtArticlesData.last.id;
      }
      log(lastPostIdInDistrict.toString());
      districtArticlesController.add(data);
      notifyListeners();
    }


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
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("loginId");
    log(val.id.toString());
    if (!isLikeList.contains(val.id.toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {
          "device_id": "${GlobalVariables().deviceId}",
          "userId":userId,
          "postId":val.id.toString(),
          "isLike":true
        }
      });
      isLikeList.add(val.id.toString());
      sendLikeDetails(userId, val, true,val.title.toString());
      log(isLikeList.toString());
    } else {
      isLikeList.remove(val.id.toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {
          "device_id": "${GlobalVariables().deviceId}",
          "userId":userId,
          "postId":val.id.toString(),
          "isLike":false
        }
      });
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