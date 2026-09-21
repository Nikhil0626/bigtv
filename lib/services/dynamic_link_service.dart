import 'dart:developer';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../globel_keys/app_router.dart';

bool isLink = false;

class DynamicLinkService {

  static Future<void> handleDeepLink(context, Uri? deepLink) async {
    if (deepLink == null) return;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? referralCode = deepLink.queryParameters["referralCode"];

    if (referralCode != null && referralCode.isNotEmpty) {
      log("Applying Referral Code: $referralCode");
      sharedPreferences.setString("sharedReferralCode", referralCode);
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesManager.welcomeScreen, (route) => false);
      }
      return;
    }

    try {
      if (context.mounted) {
        context.read<HomeProvider>().routeDeepLink(deepLink);
      }
    } catch (e) {
      log("Error in DynamicLinkService routing: $e");
    }
  }

}


