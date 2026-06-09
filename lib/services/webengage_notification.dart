import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
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
