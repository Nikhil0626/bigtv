import 'dart:developer';

import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PollProvider extends ChangeNotifier {
  TextEditingController commentController = TextEditingController();
  int? selectedIndex;
  final List<int> votes = [80, 20];

  void initialPollData(votesList){
    votes.addAll(votesList);
    notifyListeners();
  }

  Future submitPolls(postId,index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    Map<String, dynamic> body = {"post_id": postId ?? 0, "user_id": userId ?? "0", "selected_option": 0, "comment": commentController.text ?? "hai"};
    try {
      Response response = await PollRepo().submitPolls(body);
      log(response.data.toString());
      if(response.statusCode == 200){
        updatePollData(index);
      }
    } on DioException catch (e, st) {
      log("catch dio error $e ---- $st");
    } catch (e, st) {
      log("catch error $e ---- $st");
    } finally {
      notifyListeners();
    }
  }

  void updatePollData(index) {
    selectedIndex = index;
    votes[index]++;
    notifyListeners();
  }
}
