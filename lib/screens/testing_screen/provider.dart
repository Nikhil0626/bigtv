import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/home_screen_model.dart';

class FlipProvider extends ChangeNotifier {
  List<HomeScreenModel> mainArticlesData = [];
  List<HomeScreenModel> districtArticlesData = [];
  final ScreenshotController screenshotController = ScreenshotController();
  int isTab = 0;
  bool isShowTopBottomView = true;

  void isTabChange(val) {
    isTab = val;
    notifyListeners();
  }

  void isShowTopBottomChange(val) {
    print("set change value $val");
    isShowTopBottomView = !val;
    notifyListeners();
  }

  int initialIndex = 0;

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

    if (refresh==true) {
      isLoading = true;
      isRefresh = true;
      notifyListeners();
      final Map<String, dynamic> queryParams = isTab ==1?{
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
      }:{
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
    } else if (index != 0 && isTab == 0) {
      log("Home index $index");
      String? lastPostId = mainArticlesData[index].id.toString() ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      log(queryParams.toString());
      getData(queryParams);
    } else if (index != 0 && isTab == 1) {
      log("State index");
      int last = index - 1;
      String? lastPostId = districtArticlesData[last].id.toString() ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
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
      if(isRefresh){
        log("siva");
        mainArticlesController.add([]);
        mainArticlesData= [];

        notifyListeners();
      }
      mainArticlesData.addAll(data);
      mainArticlesController.add(mainArticlesData);
    } else if (isTab == 1) {
      if(isRefresh){
        log("siva");
        districtArticlesController.add([]);
        districtArticlesData= [];

        notifyListeners();
      }
      districtArticlesData.addAll(data);
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

  // void loadArticles() {
  //   print("loadArticles");
  //   // List<HomeScreenModel> articles = data1.map((e) => Article.fromJson(e)).toList();
  //   // _articlesController.add(articles);
  //   print("_articlesController");
  //   print(_articlesController);
  //
  //   notifyListeners();
  // }
  // void addMorerAticles() {
  //   print("Adding more articles from data2");
  //   // List<HomeScreenModel> articles = data2.map((e) => Article.fromJson(e)).toList();
  //   // _articlesController.add(articles);
  //   notifyListeners();
  // }

  @override
  void dispose() {
    districtArticlesController
        .close(); // ✅ Close stream when provider is disposed
    mainArticlesController.close(); // ✅ Close stream when provider is disposed
    super.dispose();
  }


  Future<void> takeScreenshotAndShare( article) async {
    try {


      final image = await screenshotController.capture(
        pixelRatio: 3.0,
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/siva.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        // Share the image

        // InkWell(
        //     onTap: () {
        //
        //     },
        //     child: Text("www.google.com"));

        Share.shareXFiles([XFile(imageFile.path)], text: 'https:/kdsbfjksdfkjhbsdjfds');

      } else {
        CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
      }
    } catch (e) {
      CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
    }
  }
}
