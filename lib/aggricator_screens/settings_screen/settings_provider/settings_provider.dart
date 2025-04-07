import 'dart:developer';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class SettingsProvider extends ChangeNotifier {
  Future bookMarks() async {
    Map<String, dynamic> body = {"userid": 3456};
    try {
      log("body $body");
      Response response = await SettingsRepo().bookMarks(body);
      if(response.statusCode == 200){
        log(response.data.toString());
      }
    } catch (e) {}
  }
}
