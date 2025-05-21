import 'dart:developer';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/main.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../aggricator_screens/event_repo.dart';
import '../globel_keys/app_router.dart';
import '../globel_keys/global_variables_data.dart';

bool isLink = false;

class DynamicLinkService {
  static final FirebaseDynamicLinks _firebaseDynamicLinks =
      FirebaseDynamicLinks.instance;

  static Future<void> handleDynamicLinks(BuildContext context) async {
    log("Checking Initial Dynamic Link...");
    try {
      final PendingDynamicLinkData? initialLink =
          await _firebaseDynamicLinks.getInitialLink();
      if (initialLink!.link.toString().isEmpty) return;
      if (!context.mounted) return;
      handleDeepLink(context, initialLink.link);
    } catch (e) {
      log("Dynamic Link Exception: $e");
      handleDeepLink(context, null);
    }
  }

  static Future<void> handleDeepLink(
       context, Uri? deepLink) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? postId = deepLink?.queryParameters["postId"];
    String? referralCode = deepLink?.queryParameters["referralCode"];
    log("Navigating to : $deepLink");

    if (postId != null && postId.isNotEmpty) {
      EventRepo().sendEvent({"key":"dynamic_link_app_open",
        "data":{
          "device_id": GlobalVariables().deviceId,
          "userId":sharedPreferences.getString('loginId')??"",
          "postId":postId.toString(),
        }});
      log("Navigating to Post ID: $postId");
      if (!context.mounted) return;
      Navigator.pushNamed(mainNavigatorKey.currentContext!, RoutesManager.homeScreen,arguments: {"postId":postId,"tab":"0"});
      return;
    }

    if (referralCode != null && referralCode.isNotEmpty) {
      log("Applying Referral Code: $referralCode");
      sharedPreferences.setString("sharedReferralCode", referralCode);
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesManager.welcomeScreen, (route) => false);
      return;
    }


    context.read<AuthenticationProvider>().checkLoginStatus(context);

  }

}


