import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../globel_keys/global_variables_data.dart';


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


void sendLiveLocationDetails( details) async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  WebEngagePlugin.trackEvent('live_location', {
    "device_id": sp.getString("deviceId")??"",
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
    "user_id": userId??0,
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



void contactViaMail() async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? userId = sp.getString("userId");
  WebEngagePlugin.trackEvent('contact_via_mail', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": userId??"",
  });
}



void contactViaCall() async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? userId = sp.getString("userId");
  WebEngagePlugin.trackEvent('contact_via_call', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),

    /// add mail
    "user_id":userId??"",
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

void logoutUser()async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? userId = sp.getString("userId");
  WebEngagePlugin.trackEvent('logout_user', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id":userId??"",
  });
  WebEngagePlugin.userLogout();
}


void loginUser()async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? userId = sp.getString("userId");
  WebEngagePlugin.trackEvent('login_user', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "user_id": userId??"",
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

void connectViaNotification()async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? userId = sp.getString("userId");
  WebEngagePlugin.trackEvent('connect_via_notification', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "post_title":"",
    "post_id":"",
    "user_id": userId??"",
  });
}


void connectViaPostLink()async{
  SharedPreferences sp = await SharedPreferences.getInstance();
String? userId = sp.getString("userId");

  WebEngagePlugin.trackEvent('connect_via_postlink', {
    "device_id": "${GlobalVariables().deviceId}",
    "date_time": DateTime.now().toString(),
    "post_title":"",
    "post_id":"",
    "user_id": userId??"",
  });
}


