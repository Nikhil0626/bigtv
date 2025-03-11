import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../globel_keys/global_variables_data.dart';
import '../main.dart';

/// Local Events For New Implementation



























/// Webengage events tracking

void sendAndroidDeviceDetails(AndroidDeviceInfo details) {
  WebEngagePlugin.trackEvent('device_details', {
    "device_id": details.id.toString(),
    "device_brand": details.brand.toString(),
    "device_model": details.model.toString(),
    "device_sdk": details.version.sdkInt.toString(),
    "device_os": "android",
  });
}
void sendiOSDeviceDetails(IosDeviceInfo details) {
  WebEngagePlugin.trackEvent('device_details', {
    "device_id": details.identifierForVendor.toString(),
    "device_brand": details.model.toString(), // iPhone/iPad
    "device_model": details.utsname.machine.toString(), // Corrected field
    "device_sdk": details.systemVersion.toString(),
    "device_os": details.systemName.toString(),
  });
}


void sendLiveLocationDetails( details) {

  WebEngagePlugin.trackEvent('live_location', {
    "device_id": "${GlobalVariables().deviceId}",
    "country": "${details.country}",
    "state": "${details.administrativeArea}",
    "district": details.locality.toString(),
    "mandel": "${details.subLocality}",
    "village": "",
  });
}

void sendLikeDetails( userId,postId,isLike,content) {
  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  WebEngagePlugin.trackEvent('like_post_data', {
    "device_id": "${GlobalVariables().deviceId}",
    "post_id": postId.toString(),
    "user_id": "${userId??""}",
    "date_time": formattedDate,
    "isLike": isLike,
    "title_content": content,
  });
}

void sendShareDetails( userId,postId, String content,) {

  WebEngagePlugin.trackEvent('share_post', {
    "device_id": "${GlobalVariables().deviceId}",
    "post_id": postId.toString(),
    "user_id": "${userId??""}",
    "date_time": DateTime.now().toString(),
    "title_content": content,

  });
}

void sendCommentDetails( userId,postId,isLike,content) {
  WebEngagePlugin.trackEvent('comment_post', {
    "device_id": "${GlobalVariables().deviceId}",
    "post_id": postId.toString(),
    "title_content": content,
    "date_time": DateTime.now().toString(),
    "user_id": "${userId??""}",
    "isComment": isLike,
  });
}

void sandFlipData(userId,count, int isTab,){
  WebEngagePlugin.trackEvent('flip_count', {
    "device_id": "${GlobalVariables().deviceId}",
    "flip_count": count.toString(),
    "user_id": "${userId??""}",
    "flip_time": DateTime.now().toString(),
    "news_type":isTab==0?"News":"District"
  });
}


void districtLocationUpdate(locationName,locationId,userId){
  WebEngagePlugin.trackEvent('district_location', {
    "device_id": "${GlobalVariables().deviceId}",
    "location_name": locationName??"",
    "location_id": "${locationId??""}",
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
}


void contactViaMail(){
  WebEngagePlugin.trackEvent('contact_via_mail', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
}



void contactViaCall(){
  WebEngagePlugin.trackEvent('contact_via_call', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),

    /// add mail
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
}

void mobileVerificationDetails(number,status){
  WebEngagePlugin.trackEvent(
    'mobile_verification_details',
    {
      'mobile_number':number??"",
      "date_time": DateTime.now().toString(),
      "verify_status": status
    },
  );
  if(status){
    loginUser();
  }
}

void logoutUser(){
  WebEngagePlugin.trackEvent('logout_user', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
  WebEngagePlugin.userLogout();
}


void loginUser(){
  WebEngagePlugin.trackEvent('login_user', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });

}


void skipUser(){
  WebEngagePlugin.trackEvent('skip_user', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": "SkipUser",
  });
}


void sendUserAttribute(String nameOfDistrict)async{
  log("list of district names $nameOfDistrict");
  WebEngagePlugin.setUserAttribute("userLocations", nameOfDistrict);
}

// WebEngagePlugin.setUserAttribute("userLocations", "కృష్ణ,గుంటూరు")

void connectViaNotification(){
  WebEngagePlugin.trackEvent('connect_via_notification', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "post_title":"",
    "post_id":"",
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
}


void connectViaPostLink(){
  WebEngagePlugin.trackEvent('connect_via_postlink', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "post_title":"",
    "post_id":"",
    "user_id": mainNavigatorKey.currentContext!.read<FlipProvider>().userId??"",
  });
}


