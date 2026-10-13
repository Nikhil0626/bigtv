import 'dart:developer';

import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import '../globel_keys/globel_keys.dart';

import '../features/home/presentation/widgets/html_notification_dialog.dart';

WebEngagePlugin _webEngagePlugin = WebEngagePlugin();

void onPushClick(Map<String, dynamic>? message, String? s) {
  log("This is a push click callback from native to flutter. Payload $message");
  if (message != null && mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(message);
  }
}

void onPushActionClick(Map<String, dynamic>? message, String? s) {
  log("This is a Push action click callback from native to flutter. Payload $message");
  log("This is a Push action click callback from native to flutter. SelectedId $s");
  if (message != null && mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(message);
  }
}

void onInAppPrepared(Map<String, dynamic>? message) {
  log("This is a inapp prepared callback from native to flutter. Payload $message");
}

void onInAppClick(Map<String, dynamic>? message, String? s) {
  log("This is a inapp click callback from native to flutter. Payload $message");
  if (message != null && mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(message);
  }
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
  showHtmlNotificationDialog(content: msg);
}

// void list
