import 'dart:developer';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../globel_keys/app_router.dart';
import '../globel_keys/globel_keys.dart';

bool isLink = false;

class DynamicLinkService {

  static Future<void> handleDeepLink(
       context, Uri? deepLink) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? postId = deepLink?.queryParameters["postId"];
    String? referralCode = deepLink?.queryParameters["referralCode"];
    log("Navigating to : $deepLink");

    if (postId != null && postId.isNotEmpty) {

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


