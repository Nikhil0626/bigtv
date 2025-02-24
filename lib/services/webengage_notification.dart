import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/main.dart';
import 'package:flutter/material.dart';
import 'package:webengage_flutter/webengage_flutter.dart';


bool _isSubscribed = false; // Add a flag to track subscription

void subscribeToPushCallbacks(WebEngagePlugin webEngagePlugin) {


  if (_isSubscribed) return; // Prevent multiple subscriptions

  _isSubscribed = true;

 webEngagePlugin.pushStream.listen((event) {
    Map<String, dynamic> messagePayload = event.payload!;
    log("Push Notification Received: ${messagePayload["postId"]}");
    Navigator.pushNamed(mainNavigatorKey.currentContext!, RoutesManager.homeScreen,arguments: {"postId":"${messagePayload["postId"]}","tab":"0"});
  });

 webEngagePlugin.pushActionStream.listen((event) {
    Map<String, dynamic>? messagePayload = event.payload;
    log("Push Action Clicked: ${messagePayload!["postId"]}");
    Navigator.pushNamed(mainNavigatorKey.currentContext!, RoutesManager.homeScreen,arguments: {"postId":"${messagePayload["postId"]}","tab":"0"});

 });
}
