import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweet_model.dart';

import '../auth/auth_repo.dart';

class XTweetsProvider extends ChangeNotifier{
  TextEditingController xTweetsSearchController = TextEditingController();


  bool isEngageTweetsLoading = false;
  bool deleteTweetLoading = false;
  List<XTwitterModel> getTweetMetricList = [];
  List<XTwitterModel> filteredTweetList = [];
  List<String> userNamesList = [];



  Future getTweetMetric({isCall = false}) async {
    isEngageTweetsLoading = true;
    if(isCall) {
      notifyListeners();
    }
    try {
      Response response = await AppRepo().getTweetMetric();

      if (response.statusCode == 200) {
        List data = response.data['data']['tweets'];
        List userNames = response.data['data']['tweets'];
// log(response.data['data']['tweets']);
        for(var name in userNames){
          userNamesList.add(name['username']);
        }
        getTweetMetricList = data
            .map(
              (e) => XTwitterModel.fromJson(e),
        )
            .toList();

        filteredTweetList = getTweetMetricList;
        log("XTwitterModel---- ${getTweetMetricList.length}");
        isEngageTweetsLoading = false;
      }
    } on DioException catch (e, st) {
      log("dio error --- ${e}");
      log("dio error --- ${st}");
    } catch (e, st) {
      log("error --- ${e}");
      log("error --- ${st}");
    } finally {
      isEngageTweetsLoading = false;
      notifyListeners();
    }
  }

  void searchTweet(String value, BuildContext context, String page) {
    filteredTweetList = getTweetMetricList.where((user) {
      final query = value.toLowerCase();
      return user.userName!.toLowerCase().contains(query) ||
          user.likeCount!.toString().toLowerCase().contains(query) ||
          user.userId!.toString().toLowerCase().contains(query) ||
          user.tweetId!.toString().toLowerCase().contains(query) ||
          user.retweetCount!.toString().toLowerCase().contains(query) ||
          user.engagementCount!.toString().toLowerCase().contains(query) ||
          user.replyCount!.toString().toLowerCase().contains(query) ||
          user.viewCount!.toString().toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  Future deleteXTweets(index, XTwitterModel item, context) async {
    deleteTweetLoading = true;
    notifyListeners();
    try {
      getTweetMetricList.removeAt(index);
      Map<String, dynamic> body = {
        "ids": [item.id]
      };
      log(body.toString());
      Response response = await AppRepo().deleteHandle(body);

      if (response.statusCode == 200) {
        deleteTweetLoading = false;
        notifyListeners();
        Navigator.pop(context);
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      deleteTweetLoading = false;
      notifyListeners();
    }
  }
  List<String> selectNamesList = [];
  void toggleSelection(String username) {
    if (selectNamesList.contains(username)) {
      selectNamesList.remove(username);
    } else {
      selectNamesList.add(username);
    }
    notifyListeners();
  }
  Future<void> filterNamesData() async {
   filteredTweetList = getTweetMetricList ;
   if(selectNamesList.isEmpty){
     return;
   }
    filteredTweetList = filteredTweetList
        .where((element) => selectNamesList.contains(element.userName))
        .toList();

    notifyListeners();
  }

}