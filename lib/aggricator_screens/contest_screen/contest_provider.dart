import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../events_data/event_repo.dart';
import '../../globel_keys/globel_keys.dart';
import '../auth_screens/authentication_view/login_background_view.dart';
import 'contest_model.dart';
import 'contest_repo.dart';

class AdsContestProvider extends ChangeNotifier {
  bool isLoading = false;
  List<JoinDataModel> joinedContestsList = [];
  List<WinnerDataModel> contestWinnersList = [];
  int _timercount = 10;
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timercount == 0) {
        _timer!.cancel();
      } else {
        _timercount--;
        if(_timercount == 0){
          Navigator.pop(mainNavigatorKey.currentContext!);
          Navigator.pushAndRemoveUntil(mainNavigatorKey.currentContext!, MaterialPageRoute(builder: (contexts) => LoginBackgroundView()), (route) => false);
        }
        notifyListeners();
      }
    });
  }

  Future getContestList(context) async{
    _timercount = 10;
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
      } if(response.statusCode == 404){
        startTimer();
        showUserInvalidPopUp(context);
      }
    }on DioException catch (e, st) {
      log("ad get imager send data $e  --- $st");
    } catch (e, st) {
      log("ad get imager send data $e  --- $st");
    }
  }

  void showUserInvalidPopUp(contexti) {
    showModalBottomSheet(
      context: contexti,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext contexts) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                "Contest Program Unavailable",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "The contest program is currently not available. Please try logging in again and joining the contest.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Consumer<AdsContestProvider>(
                  builder: (context,adsContestProvider,__) {
                    return ElevatedButton(
                        onPressed: () {

                          Navigator.pop(contexts);
                          Navigator.pushAndRemoveUntil(contexts, MaterialPageRoute(builder: (contexts) => LoginBackgroundView()), (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Go to Login $_timercount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                    );
                  }
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
