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
    notifyListeners();
  }


  void youtubeDispose() {
    log("sbfjhsfnfdsfjsdbnf  ");
    controller.dispose();
    notifyListeners();
  }

  Future getIndividualPost(postId) async {
    isPostLoading = true;
    getSinglePostList = {};
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      getSinglePostList = response.data['data'];
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
    isBookMark = [];
    isWebView = false;
    webUrl = "";
    isHomeLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? deviceId = preferences.getString("deviceId");
    String locationId = preferences.getString("locationId") ?? "";
    List<String> locationIds = locationId.split(',').map((e) => e.trim()).toList();
    log(locationIds.toString());
    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<String> categoriesIds = categoriesId.split(',').map((e) => e.trim()).toList();
    log(categoriesIds.toString());

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "postId": postId,
      "locationIds": locationIds,
      "catgoriesId": categoriesIds,
      "force_refresh": "false",
      "userId":userId??0,
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllPosts(body);

      List data = response.data['posts'];
      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];

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

  Future getAllPostsByAiId(postId) async {
    getAllAiTagsPostList = [];
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
      // isHomeLoading = false;
      notifyListeners();
    }
  }

  Future getAllAiTags() async {
    // isHomeLoading = true;
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
