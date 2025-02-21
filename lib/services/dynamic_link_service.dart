import 'dart:developer';
import 'package:chotanews/main.dart';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/Auth_module/auth_screens/welcome_screen.dart';
import 'package:chotanews/screens/home_screen/home_screens/home_top_tabs.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../globel_keys/app_router.dart';
import '../screens/individual_post_view/individual_post.dart';
import 'local_data.dart';

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
      log("Navigating to Post ID: $postId");
      if (!context.mounted) return;
      Navigator.pushNamed(mainNavigatorKey.currentContext!, RoutesManager.homeScreen,arguments: {"postId":"$postId","tab":"0"});
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

    log("Applying Skip : ${context.read<AuthProvider>().loginType}");

    context.read<AuthProvider>().checkLoginStatus(context);

  }

}


