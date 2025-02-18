import 'dart:developer';

import 'package:chotanews/main.dart';
import 'package:flutter/material.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../screens/individual_post_view/individual_post.dart';

bool _isSubscribed = false; // Add a flag to track subscription

void subscribeToPushCallbacks(WebEngagePlugin webEngagePlugin) {


  if (_isSubscribed) return; // Prevent multiple subscriptions

  _isSubscribed = true;

 webEngagePlugin.pushStream.listen((event) {
    Map<String, dynamic> messagePayload = event.payload!;
    log("Push Notification Received: ${messagePayload["postId"]}");
    Navigator.pushAndRemoveUntil(
      mainNavigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => IndividualPost(postId: messagePayload["postId"].toString())),
          (route) => false,
    );
  });

 webEngagePlugin.pushActionStream.listen((event) {
    Map<String, dynamic>? messagePayload = event.payload;
    log("Push Action Clicked: ${messagePayload!["postId"]}");
    Navigator.pushAndRemoveUntil(
      mainNavigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => IndividualPost(postId: messagePayload["postId"].toString())),
          (route) => false,
    );
  });
}
