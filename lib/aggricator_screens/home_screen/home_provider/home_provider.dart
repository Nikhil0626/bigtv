import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../services/analytics_service.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../home_repo/home_repo.dart';
class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
  List getAllSurveyDataList = [];


  String adManageId = "";
  String adManagerNativeId = "";
  String adManagerBannerId = "";
  String adMobNativeId = "";
  String adMobBannerId = "";

  var getSinglePostList = {};
  int aiCurrentPostId = 0;
  int selectedIndex = 0;
  bool isSwitched = false;
  bool isWebView = false;
  String webUrl = '';
  bool isHomeLoading = false;
  bool isPlaying = false;
  bool isPostLoading = false;
  bool isMuted = false;
  late YoutubePlayerController controller;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void isTabChange() {
    isSwitched = false;
    notifyListeners();
  }

  void switchChange(value) {
    isSwitched = !isSwitched;
    notifyListeners();
  }

  bool isReload = false;

  void isReloadData() {
    isReload = true;
    notifyListeners();
  }

  void isReloadFalse() {
    isReload = false;
    notifyListeners();
  }

  void isPlayingYoutube(value) {
    isPlaying = value;
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void currentAiPostId(value) {
    aiCurrentPostId = value;
    notifyListeners();
  }

  void youtubeInitial(url) {
    controller = YoutubePlayerController(
      initialVideoId: url, // Example YouTube video ID
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: false,
        forceHD: false,
        disableDragSeek: true,
        isLive: false,

        showLiveFullscreenButton: false,
        // hideControls: true,
      ),
    );
    // notifyListeners();
  }

  void youtubeDispose() {
    log("sbfjhsfnfdsfjsdbnf  ");
    controller.dispose();
    notifyListeners();
  }

  Future getIndividualPost(postId, {bool isAds = false}) async {
    log("getIndividualPost ${postId}");
    if(isAds !=true) {
      getAllPostList = [];
    }
    isPostLoading = true;
    // notifyListeners();
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (isAds == false) {
          getAllPostList.add(response.data['data']);
          Future.delayed(
            Duration(milliseconds: 300),
            () {
              getAllPost( isGetAllPost: true);
            },
          );
        } else {
          getSinglePostList = response.data['data'];
        }
      }
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
      // getAllPostList = [];
      Future.delayed(
        Duration(milliseconds: 300),
        () {
          getAllPost( isGetAllPost: true);
        },
      );
      isPostLoading = false;
      notifyListeners();
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
      // getAllPostList = [];
      Future.delayed(
        Duration(milliseconds: 300),
        () {
          getAllPost( isGetAllPost: true);
        },
      );
      isPostLoading = false;
      notifyListeners();
    } finally {
      isPostLoading = false;
      isReload = false;
      notifyListeners();
    }
  }

  Future getAllPost({String postId = "0", bool isGetAllPost = false}) async {
    if (isGetAllPost == false && postId =="0") {
      getAllPostList = [];
    }
    isBookMark = [];
    isWebView = false;
    webUrl = "";
    isHomeLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? deviceId = preferences.getString("deviceId");
    String locationId = preferences.getString("locationId") ?? "";
    List<int> locationIds = locationId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Location IDs: $locationIds');

    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<int> categoriesIds = categoriesId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Category IDs: $categoriesIds');

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "postId": postId,
      "locationIds": locationIds,
      "categoriesId": categoriesIds,
      "userId": userId ?? 0,
      "isAdManager":true
    };
    log("allpost body ${body.toString()}");
    try {
      Response response = await HomeRepo().getAllPosts(body);
      List data = response.data['posts'];
      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];
      adManageId =Platform.isIOS?response.data['adUnits']['ios']['admanageid']: response.data['adUnits']['android']['admanageid'];
      adManagerNativeId =Platform.isIOS?response.data['adUnits']['ios']['admanagernativeid']: response.data['adUnits']['android']['admanagernativeid'];
      adManagerBannerId = Platform.isIOS?response.data['adUnits']['ios']['admanagerbannerid']:response.data['adUnits']['android']['admanagerbannerid'];
      adMobNativeId = Platform.isIOS?response.data['adUnits']['ios']['admobnativeid']:response.data['adUnits']['android']['admobnativeid'];
      adMobBannerId = Platform.isIOS?response.data['adUnits']['ios']['admobbannerid']:response.data['adUnits']['android']['admobbannerid'];

      if (isWebView) {
        getAllPostList.insert(0, {
          "id": 000000,
          "postOrder": 00000,
          "author": 9,
          "title": "WebUrl",
          "content": "Hello",
          "created": "2025-04-22T08:36:04",
          "guid": "",
          "post_type": "post",
          "post_name": "సివిల్స్-తుది-ఫలితాలు-వి",
          "post_mime_type": "",
          "totalLikes": 8,
          "totalViews": 14104,
          "totalComments": 0,
          "image_url": "",
          "video_url": "",
          "downloadUrl": null,
          "gallery": null,
          "type": "WebUrl",
          "totalShares": 0,
          "isReporter": 0,
          "reportedBy": "",
          "categoryName": "నేషనల్",
          "postUrl": "",
          "subType": "",
          "isStickyPost": 0,
          "adPosition": null,
          "linkURLAndroid": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
          "linkURLIos": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
          "links": [],
          "categoryId": 2,
          "isBookmarked": 0
        });
      }
      getAllPostList.addAll(data);

      log("sfbsvfjhshfejsosevfuyesfuyiesdfkejswihfveuwfyiwe");
      log(getAllPostList.length.toString());

      isBookMark = getAllPostList.where((e) => e['isBookmarked'] == 1).map((e) => e['id'].toString()).toList();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isReload = false;
      isHomeLoading = false;
      notifyListeners();
    }
  }

  bool isAiTagsLoading = false;
  int currentIndex = 0;

  Future getAllPostsByAiId(postId) async {
    log("sbvjdshgurhgiurehiouerjgjer");
    isBookMark = [];
    getAllAiTagsPostList = [];
    isAiTagsLoading = true;
    currentIndex = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "deviceid": deviceId ?? "",
      "aitagid": postId,
      "user_id": userId ?? "",
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllAiTagsById(body);
      log(response.data.toString());
      List data = response.data;

      getAllAiTagsPostList.addAll(data);

      isBookMark = getAllAiTagsPostList.where((e) => e['isBookmarked'] == 1).map((e) => e['id'].toString()).toList();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isAiTagsLoading = false;
      notifyListeners();
    }
  }

  Future getAllAiTags() async {
    getAllAiTagsList = [];
    try {
      Response response = await HomeRepo().getAllAiTags();
      getAllAiTagsList.addAll(response.data);
      log(getAllAiTagsList.toString());
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      // isHomeLoading = false;
      notifyListeners();
    }
  }

  Future getSurveyData() async {
    try {
      Response response = await HomeRepo().surveyApi();
      getAllSurveyDataList.addAll(response.data['choices']);
      log(getAllSurveyDataList.toString());
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

  List isBookMark = [];

  void isBookMarkPost(val, context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    log(val['id'].toString());
    if (!isBookMark.contains(val['id'].toString())) {

      isBookMark.add(val['id'].toString());
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 1);
      sendLikeDetails(userId, val, true, val['title'].toString());
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 0);
      isBookMark.remove(val['id'].toString());

      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isBookMark.toString());
    }

    notifyListeners();
  }

  void flipEvent(pageName, id, val) async {

    AnalyticsService().trackArticlesRead();
    notifyListeners();
  }
}
