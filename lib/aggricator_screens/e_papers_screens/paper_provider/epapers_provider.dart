import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../paper_models/ePaper_main_model.dart';
import '../paper_models/single_paper_model.dart';
import '../paper_repo/epaper_repo.dart';

class EPapersProvider extends ChangeNotifier {
  bool isMainPapers = false;
  List<EPaperMainModel> getAllMainPapersList = [];
  List<SinglePaperModel> getSinglePapersList = [];

  Future getMainEPapers() async {

    isMainPapers = true;

    try {
      Response response = await EPaperRepo().getMainEPapers();
      if (response.statusCode == 200) {
        log(response.data.toString());
        List data = response.data;
        getAllMainPapersList = data.map((e) => EPaperMainModel.fromJson(e)).toList();
        isBookMark = getAllMainPapersList
            .where((e) => e.isBookmarked == 1)
            .map((e) => e.id.toString())
            .toList();
      }
    } on DioException catch (e, st) {
      getAllMainPapersList = [];
      log("main epaper dio error ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      getAllMainPapersList = [];
      log("main epaper error ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainPapers = false;
      notifyListeners();
    }
  }

  Future getSingleEPapers(String paper) async {
    isMainPapers = true;
    getSinglePapersList = [];

    try {
      Response response = await EPaperRepo().getSingleEPapers(paper);
      if (response.statusCode == 200) {
        log(response.data.toString());
        List data = response.data;
        getSinglePapersList = data.map((e) => SinglePaperModel.fromJson(e)).toList();
        isBookMark = getSinglePapersList.first.data!
            .where((e) => e.isBookmarked == 1)
            .map((e) => e.id.toString())
            .toList();
      }
    } on DioException catch (e, st) {
      getSinglePapersList = [];
      log("Single paper dio error ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      getSinglePapersList = [];
      log("Single paper error ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainPapers = false;
      notifyListeners();
    }
  }


  List isBookMark = [];

  void isBookMarkPost(val,context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    log(val.id.toString());
    if (!isBookMark.contains(val.id.toString())) {
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "$deviceId", "userId": userId, "postId": val.id.toString(), "isLike": true}
      });
      isBookMark.add(val.id.toString());
      Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val.id.toString(), context,1
      );
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context,listen: false).saveBookmarks(
          val.id.toString(), context,0
      );
      isBookMark.remove(val.id.toString());
      EventRepo().sendEvent({
        "key": "liked_article",
        "data": {"device_id": "$deviceId", "userId": userId, "postId": val.id.toString(), "isLike": false}
      });
      log(isBookMark.toString());
    }

    notifyListeners();
  }
}
