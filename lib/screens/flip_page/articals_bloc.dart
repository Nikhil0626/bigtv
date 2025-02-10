import 'dart:async';
import 'dart:convert';
import 'dart:developer';


import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/home_screen_model.dart';

class ArticleBloc {
  static const String _kSourcesKey = "sources_key";

  bool isChange = true;

  static const int _pageSize = 10;
  int _nextPage = 1;

  int _totalItemsForRequestedSources = 1;

  late SharedPreferences prefs;
  List<String>? activeSources;
  late String _activeSourcesStr;

  final articlesController = PublishSubject<List<HomeScreenModel>?>();
  final _sourcesController = PublishSubject<List<HomeScreenModel>?>();
  final HomeRepo api;
  ArticleBloc({required this.api});

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    loadSources();
    _activeSourcesStr = sourcesListToUrlString();
  }

  void close() {
    articlesController.close();
    _sourcesController.close();
  }
  List<HomeScreenModel>? articlesData;

  Future<void> getArticles({bool refresh = false,int index= 0,bool isTab = false}) async {


    if (activeSources == null) {
      await init();
    }

    if(index != 0 && isTab==false){
      log("Home index");
      int last = index ;
      String? lastPostId = articlesData![last].id.toString() ?? "";
      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        'includeHomePage': "1",
        'deviceid': deviceId,
        'platform': platForm,
        'locationIds': '64',
      };

      log(queryParams.toString());
      Response response = await HomeRepo().getAllNewsFeeds(queryParams);
      print(response.toString());
      List jsonList = response.data['posts'];
      List<HomeScreenModel> articles = jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
      _totalItemsForRequestedSources = articles.length;
    }
   else if(index == 0 && isTab==true){
      log("iaTab");
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      String locationId = sharedPreferences.getString(
        "locationId",
      ) ??
          "";
      log(locationId);
      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        // 'includeHomePage': "1",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': platForm,
        'locationIds':locationId,
      };
      articlesController.add(null);
      articlesData = [];
      log(queryParams.toString());
      Response response = await HomeRepo().getAllNewsFeeds(queryParams);
      print(response.toString());
      List jsonList = response.data['posts'];
      articlesData = jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
      articlesController.add(articlesData!);
      _totalItemsForRequestedSources = articlesData!.length;
    }
   else if(index != 0 && isTab==true){
      log("State index");
      int last = index - 1;
      String? lastPostId = articlesData![last].id.toString() ?? "";
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      String locationId = sharedPreferences.getString(
        "locationId",
      ) ??
          "";
      log(locationId);
      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        // 'includeHomePage': "1",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': platForm,
        'locationIds':locationId,
      };
      articlesController.add(null);
      articlesData = [];
      log(queryParams.toString());
      Response response = await HomeRepo().getAllNewsFeeds(queryParams);
      print(response.toString());
      List jsonList = response.data['posts'];
      articlesData = jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
      articlesController.add(articlesData!);
      _totalItemsForRequestedSources = articlesData!.length;
    }
    else if (refresh) {
      log("refresh");
      articlesController.add(null);
      // articlesData=[];
      articlesData = await _getArticles();
      articlesController.add(articlesData!);

    } else {
      log("elseeeeee");
      if (_totalItemsForRequestedSources > (_nextPage - 1) * _pageSize) {
        articlesData = await _getArticles(page: _nextPage);
        if (articles != null) {
          log("siva3");
          articlesController.add(articlesData);
          _nextPage++;
        }
      }
      // else no more items;
    }
  }

  // Future<void> getSources() async {
  //   String deviceId = GlobalVariables().deviceId ?? "";
  //   String platForm = GlobalVariables().platForm ?? "";
  //
  //   final Map<String, dynamic> queryParams = {
  //     'userid': "1",
  //     'postid': "0",
  //     'lpostid': "0",
  //     'includeHomePage': "0",
  //     'isByNotification': "false",
  //     'deviceid': deviceId,
  //     'platform': platForm,
  //     'homefeed': "0",
  //     // 'hasAds': true,
  //     // 'locationIds': '21,22,43,44,55,64',
  //     // "debugMode": true
  //   };
  //   _sourcesController.add(await HomeRepo().getAllNewsFeeds(queryParams));
  // }

  // Outputs
  Stream<List<HomeScreenModel>?> get articles => articlesController.stream;

  Stream<List<HomeScreenModel>?> get allSources => _sourcesController.stream;

  Future<List<HomeScreenModel>?> _getArticles({int page = 1, int pageSize = _pageSize}) async {

    String deviceId = GlobalVariables().deviceId ?? "";
    String platForm = GlobalVariables().platForm ?? "";

    final Map<String, dynamic> queryParams = {
      'userid': "1",
      'postid': "0",
      'lpostid': "0",
      'includeHomePage': "0",
      'isByNotification': "false",
      'deviceid': deviceId,
      'platform': platForm,
      'homefeed': "0",
      // 'hasAds': true,
      // 'locationIds': '21,22,43,44,55,64',
      // "debugMode": true
    };
    Response jsonString =
    await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    // var data = jsonString.data['posts'];
    List jsonList = jsonString.data['posts'];
    List<HomeScreenModel> articles = jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();

    _totalItemsForRequestedSources = articles.length;
      return articles;
      return null;
  }

  /// Loads active sources from localstorage
  void loadSources() {
    String? sources = prefs.getString(_kSourcesKey);
    if (sources != null) {
      activeSources = json.decode(sources).cast<String>();
      if (activeSources!.isNotEmpty) {
        return;
      }
    }
    // Getting here means we were not able to get valid sources
    activeSources = ['cnn', 'bbc-news'];
    saveSources();
    return;
  }

  /// Saves active sources to localstorage
  void saveSources() {
    prefs.setString(_kSourcesKey, jsonEncode(activeSources));
  }

  /// Converts the active sources list to a string that will be used in the url
  /// to fetch articles from the server
  /// TOD: this should be moved to the api
  String sourcesListToUrlString() {
    String str = '';
    for (var source in activeSources!) {
      str += "$source,";
    }
    if (str.endsWith(',')) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  /// Updates the active sources with the passed source id
  void activateSource({required String id, required bool activate}) {
    if (!activeSources!.contains(id) && activate) {
      activeSources!.add(id);
    } else if (activeSources!.contains(id) && !activate) {
      activeSources!.remove(id);
    }
    saveSources();
    _activeSourcesStr = sourcesListToUrlString();
  }
}
