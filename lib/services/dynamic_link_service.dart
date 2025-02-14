import 'dart:developer';
import 'package:chotanews/screens/Auth_module/welcome_screen.dart';
import 'package:chotanews/screens/home_screen/home_top_tabs.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../globel_keys/app_router.dart';
import '../screens/individual_post_view/individual_post.dart';

class DynamicLinkService {
  static final FirebaseDynamicLinks _firebaseDynamicLinks = FirebaseDynamicLinks.instance;

  static Future<void> handleDynamicLinks(BuildContext context) async {
    log("Checking Initial Dynamic Link...");

    try {
      final PendingDynamicLinkData? initialLink = await _firebaseDynamicLinks.getInitialLink();
      if (initialLink?.link != null) {
        log("Initial Deep Link Found: ${initialLink!.link}");
        _handleDeepLink(context, initialLink.link);
      }else{
        _handleDeepLink(context, "");
      }

      _firebaseDynamicLinks.onLink.listen((PendingDynamicLinkData? data) {
        log("Dynamic Link Triggered: ${data?.link}");
        if (data?.link != null) {
          _handleDeepLink(context, data!.link);
        }
        else{
          _handleDeepLink(context, "");
        }
      }).onError((error) {
        log('Dynamic Link Error: $error');
      });
    } catch (e) {
      log("Dynamic Link Exception: $e");
    }
  }

  static Future<void> _handleDeepLink(BuildContext context,  deepLink) async {

    if (deepLink == null || deepLink =="") {
      log("No deep link parameters found, navigating normally.");
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, RoutesManager.welcomeScreen,(route) => false,);
      return;
    };



    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? postId = deepLink.queryParameters["postId"];
    String? referralCode = deepLink.queryParameters["referralCode"];

    if (postId != null && postId.isNotEmpty) {
      log("Navigating to Post ID: $postId");
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IndividualPost(postId: postId)),
      );
    } else if (referralCode != null && referralCode.isNotEmpty) {
      log("Applying Referral Code: $referralCode");
      sharedPreferences.setString("sharedReferralCode", referralCode);
      if (!context.mounted) return;
      Navigator.pushNamed(context, RoutesManager.welcomeScreen);
    } else {
      log("No deep link parameters found, navigating normally.");
      if (!context.mounted) return;
        Navigator.pushNamed(context, RoutesManager.welcomeScreen);
    }
  }
}
