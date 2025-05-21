import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../aggricator_screens/event_repo.dart';
import '../aggricator_screens/individual_post_details/individual_post_view.dart';
import '../main.dart';



void onPushClick(Map<String, dynamic>? message, String? s) {
  print("This is a push click callback from native to flutter. Payload " +
      message.toString());
}

void onPushActionClick(Map<String, dynamic>? message, String? s) {
  print(
      "This is a Push action click callback from native to flutter. Payload " +
          message.toString());
  print(
      "This is a Push action click callback from native to flutter. SelectedId " +
          s.toString());
}

void onInAppPrepared(Map<String, dynamic>? message) {
  print("This is a inapp prepared callback from native to flutter. Payload " +
      message.toString());
}

void onInAppClick(Map<String, dynamic>? message, String? s) {
  print("This is a inapp click callback from native to flutter. Payload " +
      message.toString());
}

void onInAppShown(Map<String, dynamic>? message) {
  print("This is a callback on inapp shown from native to flutter. Payload " +
      message.toString());
}

void onInAppDismiss(Map<String, dynamic>? message) {
  print(
      "This is a callback on inapp dismiss from native to flutter. Payload " +
          message.toString());
}


void subscribeToPushCallbacks()  {
  log("pushActionStream: flutter test 0000" );
  WebEngagePlugin().pushStream.listen((event) {
    log("pushActionStream: flutter test  11111" );
    String? deepLink = event.deepLink;
    Map<String, dynamic> messagePayload = event.payload!;

    log("pushActionStream: flutter test  11111 ${messagePayload}" );

    sendEventToServer("4118381");
  });

  //Push action click listener
  WebEngagePlugin().pushActionStream.listen((event) {
    log("pushActionStream: flutter test  22222" );
    sendEventToServer("4118381");
  //   print("pushActionStream:" + event.toString());
  //   String? deepLink = event.deepLink;
  //   Map<String, dynamic>? messagePayload = event.payload;
  // sendEventToServer(messagePayload?["postId"]??"0");
    // showDialogWithMessage("PushAction click callback: " + event.toString());
  });
}

void sendEventToServer(msg) async{

  Navigator.push(mainNavigatorKey.currentContext!, MaterialPageRoute(builder: (context) => IndividualPostView(postId:msg ),));
  SharedPreferences sp = await SharedPreferences.getInstance();
  EventRepo().sendEvent({
    "key": "openapp_via_notification",
    "data": {
      "device_id": sp.getString("deviceId")??"1234",
      "userId": sp.getString('userId') ?? "",
      "postId": msg,
    }
  });
}
void subscribeToTrackDeeplink() {
  print("pushActionStream:1111111" );
}

void subscribeToAnonymousIDCallback() {
  print("pushActionStream:22222" );
}


void showDialogWithMessage(String msg) {
  showDialog(
      context: mainNavigatorKey.currentState!.overlay!.context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: EdgeInsets.all(5.0),
            child: new Container(
              // padding: new EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                color: Colors.white,
              ),
              child: new Text(
                msg,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontFamily: 'helvetica_neue_light',
                ),
                textAlign: TextAlign.center,
              ),
            ));
      });
}

// void list