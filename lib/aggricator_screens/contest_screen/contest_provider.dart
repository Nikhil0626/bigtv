import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../events_data/event_repo.dart';
import 'contest_model.dart';
import 'contest_repo.dart';

class AdsContestProvider extends ChangeNotifier {
  bool isLoading = false;
  List<JoinDataModel> joinedContestsList = [];
  List<WinnerDataModel> contestWinnersList = [];

  Future getContestList() async{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userId = preferences.getString("userId");
    try{
      Response response = await ContestRepo().getContestList(userId);
      if(response.statusCode == 200){
        joinedContestsList = response.data['all_contests'].map<JoinDataModel>((item) => JoinDataModel.fromJson(item)).toList();
        contestWinnersList = response.data['contest_winners'].map<WinnerDataModel>((item) => WinnerDataModel.fromJson(item)).toList();
        // availableContestsList =response.data['available_contests'].map<AvailableDataModel>((item) => AvailableDataModel.fromJson(item)).toList();
        notifyListeners();
        EventRepo().addEvent({"user_id": userId.toString(), "isCheck": "true"}, "check_contest");
      }
    }on DioException catch (e, st) {
      log("ad get imager send data $e  --- $st");
    } catch (e, st) {
      log("ad get imager send data $e  --- $st");
    }
  }
}
