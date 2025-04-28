import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../services/webengage_event_tracks.dart';
import '../settings_screen/settings_provider/settings_provider.dart';

class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
  List getAllSurveyDataList = [];

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

  Future getIndividualPost(postId,{bool isAds=false}) async {

    isPostLoading = true;
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      getSinglePostList = response.data['data'];
      if(isAds==false) {
        getAllPostList.add(response.data['data']);
        Future.delayed(Duration(milliseconds: 300), () {
          getAllPost(postId: "0");
        },);
      }
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isPostLoading = false;
      notifyListeners();
    }
  }

  Future getAllPost({String postId = "0"}) async {
    if(postId == 0){
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
    List<int> locationIds = locationId
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    log('Location IDs: $locationIds');

    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<int> categoriesIds = categoriesId
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    log('Category IDs: $categoriesIds');


    Map<String, dynamic> body = {
      "device_id": deviceId,
      "postId": postId,
      "locationIds": locationIds,
      "categoriesId": categoriesIds,
      "userId":userId??0,
    };
    log("allpost body ${body.toString()}");
    try {
      Response response = await HomeRepo().getAllPosts(body);

      List data = response.data['posts'];
      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];


      if(isWebView){
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
      log(getAllPostList[0]['image_url'].toString());
      isBookMark = getAllPostList
          .where((e) => e['isBookmarked'] == 1)
          .map((e) => e['id'].toString())
          .toList();
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
  Future getAllPostsByAiId(postId) async {
    getAllAiTagsPostList = [];
    isAiTagsLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");

    Map<String, dynamic> body = {
      "deviceid": deviceId,
      "aitagid": postId,
      "postid": "0",
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllAiTagsById(body);
      log(response.data.toString());
      List data = response.data;

      getAllAiTagsPostList.addAll(data);
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


  void isBookMarkPost(val,context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    log(val['id'].toString());
    if (!isBookMark.contains(val['id'].toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val['id'].toString(), "isLike": true}
      });
      isBookMark.add(val['id'].toString());
   Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val['id'].toString(), context,1
      );
      sendLikeDetails(userId, val, true, val['title'].toString());
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val['id'].toString(), context,0
      );
      isBookMark.remove(val['id'].toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "${GlobalVariables().deviceId}", "userId": userId, "postId": val['id'].toString(), "isLike": false}
      });
      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isBookMark.toString());
    }

    notifyListeners();
  }
}
