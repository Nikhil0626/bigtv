import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth_module/welcome_screen.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenView();
}

class _SplashScreenView extends State<SplashScreenView> {
  @override
  void initState() {
    initDynamicLinks();
    super.initState();
    navigateApp();
  }


  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink?.link != null) {
      handleDeepLink(initialLink!.link);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      handleDeepLink(dynamicLinkData.link);
    }).onError((error) {
      print("Dynamic Link Error: $error");
    });
  }

  void handleDeepLink(Uri deepLink) {
    print("Opened with deep link: ${deepLink.toString()}");
    // Navigate based on the deep link path
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Image.asset(
        "assets/splash1.gif",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
  Future navigateApp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String loginId = sharedPreferences.getString("loginId")??"";
    log(loginId.toString());
    if (loginId != null || loginId.isNotEmpty) {
      Timer(const Duration(seconds: 8), () {
        Navigator.pushNamed(context, RoutesManager.homeScreen);
      });
    } else {
      Timer(const Duration(seconds: 8), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(), // Replace `NewScreen` with the screen you want to navigate to
          ),
        );
      });
    }
  }
}
