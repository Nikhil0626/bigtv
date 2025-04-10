
import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_repo.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier{
  List<HomeScreenModel> getAllPostList = [];
  int selectedIndex = 0;
  bool isSwitched = false;

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

  Future getIndividualPost(postId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    log("Push Notification Received: get Call ${postId.toString()}");
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      List data = response.data['posts'];
      HomeScreenModel getSinglePost = HomeScreenModel.fromJson(data[0]);
      getAllPostList.add(getSinglePost);
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

}