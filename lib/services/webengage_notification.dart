import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../aggricator_screens/home_screen/home_provider/home_provider.dart';
import '../globel_keys/globel_keys.dart';

WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
bool _isSubscribed = false;

void onPushClick(Map<String, dynamic>? message, String? s) {
  log("This is a push click callback from native to flutter. Payload $message");
}

void onPushActionClick(Map<String, dynamic>? message, String? s) {
  log("This is a Push action click callback from native to flutter. Payload $message");
  log("This is a Push action click callback from native to flutter. SelectedId $s");
}

void onInAppPrepared(Map<String, dynamic>? message) {
  log("This is a inapp prepared callback from native to flutter. Payload $message");
}

void onInAppClick(Map<String, dynamic>? message, String? s) {
  log("This is a inapp click callback from native to flutter. Payload $message");
}

void onInAppShown(Map<String, dynamic>? message) {
  log("This is a callback on inapp shown from native to flutter. Payload $message");
}

void onInAppDismiss(Map<String, dynamic>? message) {
  log("This is a callback on inapp dismiss from native to flutter. Payload $message");
}

void subscribeToPushCallbacks() {
  if (_isSubscribed) return;
  _isSubscribed = true;
  log("pushActionStream: flutter test 0000");
  _webEngagePlugin.pushStream.listen((event) {

    Map<String, dynamic> messagePayload = event.payload!;
    log("pushActionStream: flutter test  11111 --- ${messagePayload["postId"]}");
    if (Platform.isIOS) {
      log("pushActionStream: flutter test  11111 ${messagePayload['data']['customData'][0]['value']}");

      sendEventToServer(messagePayload['data']['customData'][0]['value']);
    } else {
      sendEventToServer(messagePayload["postId"] ?? "0");
    }
  });

  //Push action click listener
  _webEngagePlugin.pushActionStream.listen((event) {
    Map<String, dynamic>? messagePayload = event.payload;

    log("pushActionStream: flutter test  22222  ${messagePayload}");

    if (Platform.isIOS) {
      log("pushActionStream: flutter test  11111 ${messagePayload?['data']['customData'][0]['value']}");

      sendEventToServer(messagePayload?['data']['customData'][0]['value']);
    } else {
      sendEventToServer(messagePayload?["postId"] ?? "0");
    }
  });
}

void sendEventToServer(msg) async {
  mainNavigatorKey.currentContext?.read<HomeProvider>().aiTagDataLoaded(true);

}

void subscribeToTrackDeeplink() {
  log("pushActionStream:1111111");
}

void subscribeToAnonymousIDCallback() {
  log("pushActionStream:22222");
}

void closeSubscribe() {
  log("pushActionStream:  dispose");
  _webEngagePlugin.pushSink.close();
  _webEngagePlugin.pushActionSink.close();
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
