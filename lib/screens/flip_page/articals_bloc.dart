import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/screens/home_screen/home_repo/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/home_models/home_screen_model.dart';

class ArticleBloc extends  ChangeNotifier {


  int totalItemsForRequestedSources = 1;

  final articlesController = PublishSubject<List<HomeScreenModel>?>();
  // final _sourcesController = PublishSubject<List<HomeScreenModel>?>();
  final HomeRepo api;

  ArticleBloc({required this.api});

  void close() {
    articlesController.close();
    // _sourcesController.close();
  }

  List<HomeScreenModel> articlesData = [];

  bool isRefresh = false;

  Future<void> getArticles(
      {bool refresh = false, int index = 0, bool isTab = false}) async
  {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String locationId = sp.getString("locationId") ?? "";
    String deviceId = GlobalVariables().deviceId ?? "";

    if (refresh) {
      isRefresh = true;
      log("refresh $isRefresh");
      notifyListeners();
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      articlesData = [];
      articlesController.add(null);
      getData(queryParams);
    } else if (index != 0 && isTab == false) {
      isRefresh = false;
      log("Home index $index");
      String? lastPostId = articlesData[index].id.toString() ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      log(queryParams.toString());
      articlesData.clear();
      articlesController.add([]);

      getData(queryParams);
    } else if (index == 0 && isTab == true) {
      log("iaTab");
      isRefresh = false;
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
      };
      articlesData = [];
      articlesController.add([]);

      getData(queryParams);
    } else if (index != 0 && isTab == true) {
      log("State index");
      isRefresh = false;
      int last = index - 1;
      String? lastPostId = articlesData[last].id.toString() ?? "";
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

      articlesController.add([]);
      articlesData = [];

      getData(queryParams);
    } else {
      log("elseeeeee $index");
      isRefresh = false;
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      // articlesData = [];
      // articlesController.add(null);
      getData(queryParams);
    }
  }

  Future getData(queryParams) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['posts'];
    articlesData =
        jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();

    totalItemsForRequestedSources = articlesData.length;
    articlesController.add(articlesData);
  }

  Stream<List<HomeScreenModel>?> get articles => articlesController.stream;

  // Stream<List<HomeScreenModel>?> get allSources => _sourcesController.stream;
}
