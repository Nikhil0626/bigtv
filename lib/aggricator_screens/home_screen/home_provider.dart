import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  var getSinglePostList = {};
  int selectedIndex = 0;
  bool isSwitched = false;
  bool isWebView = false;
  String webUrl = '';
  bool isHomeLoading = false;
  bool isPlaying = false;
  bool isPostLoading = false;
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

  void youtubeInitial(url){
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

  void youtubeDispose(){
    log("sbfjhsfnfdsfjsdbnf  ");
    controller.dispose();
    notifyListeners();
  }

  Future getIndividualPost(postId) async {
    isPostLoading = true;
    getSinglePostList ={};
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      getSinglePostList =response.data['data'];
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
    isWebView = false;
    webUrl = "";
    isHomeLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
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
      "force_refresh": "false"
      // "ad": "true"
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllPosts(body);

      List data = response.data['posts'];
      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];

      getAllPostList.addAll(data);
      log(getAllPostList[0]['image_url'].toString());
      // = data
      //     .map(
      //       (e) => HomeScreenModel.fromJson(e),
      //     )
      //     .toList();
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
}
