import 'dart:developer';

import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../globel_keys/global_variables_data.dart';
import '../screens/home_screen/home_repo/event_repo.dart';


bool _isSubscribed = false; // Add a flag to track subscription

void subscribeToPushCallbacks(WebEngagePlugin webEngagePlugin,) async{
SharedPreferences sp = await SharedPreferences.getInstance();




  webEngagePlugin.pushStream.listen((event) {
    Map<String, dynamic> messagePayload = event.payload!;
    log("Push Notification Received: ${messagePayload["postId"]}");

    EventRepo().sendEvent({"key":"openapp_via_notification",
      "data":{
        "device_id": GlobalVariables().deviceId,
        "userId":sp.getString('loginId')??"",
        "postId":messagePayload["postId"].toString(),
      }});
    Navigator.push(mainNavigatorKey.currentContext!, MaterialPageRoute(builder: (context) => IndividualPostView(postId:messagePayload["postId"] ),));
  });

 webEngagePlugin.pushActionStream.listen((event) {
    Map<String, dynamic>? messagePayload = event.payload;
    log("Push Action Clicked: ${messagePayload!["postId"]}");
    EventRepo().sendEvent({"key":"openapp_via_notification",

      "data":{
        "device_id": GlobalVariables().deviceId,
        "userId":sp.getString('loginId')??"",
        "postId":messagePayload["postId"].toString(),
      }});
    Navigator.pushNamed(mainNavigatorKey.currentContext!, RoutesManager.homeScreen,arguments: {"postId":"${messagePayload["postId"]}","tab":"0"});

 });
}
