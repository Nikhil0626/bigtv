
import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  List getSinglePostList = [];
  int selectedIndex = 0;
  bool isSwitched = false;
  bool isWebView = false;
  String webUrl = '';
  bool isHomeLoading = false;

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
  void isReloadData(){
    isReload =true;
    notifyListeners();
  }
bool isPostLoading = false;

  Future getIndividualPost(postId) async {
    isPostLoading = true;
    log("sdknfksdfndskjfnkdsfndskj  ");

    getSinglePostList =[];
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      List data = response.data['data'];
      getSinglePostList.addAll(data);
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
    List<String> locationIds = locationId
        .split(',')
        .map((e) => e.trim())
        .toList();
    log(locationIds.toString());
    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<String> categoriesIds = categoriesId
        .split(',')
        .map((e) => e.trim())
        .toList();
    log(categoriesIds.toString());

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "postId": postId,
      "locationIds": locationIds,
      "catgoriesId":categoriesIds,
      "force_refresh":"false"
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
