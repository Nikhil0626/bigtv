import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth_module/welcome_screen.dart';
import '../individual_post_view/individual_post.dart';

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
  }


  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? data) {
      final Uri? deepLink = data?.link;
      log("Dynamic Links  ${data?.link}");

      if (deepLink != null) {
        handleDeepLink(deepLink);
      }
    }).onError((error) {
      print('Dynamic Link Failed: $error');
    });

    // final PendingDynamicLinkData? initialLink =
    // await FirebaseDynamicLinks.instance.getInitialLink();
    //
    // if (initialLink?.link != null) {
    //   handleDeepLink(initialLink!.link);
    // }else{
    //   navigateApp();
    // }
  }

  Future handleDeepLink(Uri deepLink) async {
    Uri uri = Uri.parse(deepLink.toString());
    bool isValid = uri.queryParameters.containsKey("postId");

    String? postId = isValid ? uri.queryParameters["postId"] : "";
    String? referralCode = !isValid ? uri.queryParameters["referralCode"] : "";

    log("post iddddddddd $postId");
    log("post iddddddddd $referralCode");

    if (postId != null && postId != "") {
      log("post iddddddddd $postId");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IndividualPost(postId: postId)),
      );
    } else if (referralCode != null && referralCode != "") {
      log("code iddddddddd $referralCode");
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("sharedReferralCode", referralCode);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    } else {
      log("normalllllll $referralCode");
      navigateApp();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Image.asset(
        "assets/svg/splash_video.gif",
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
      Timer(const Duration(seconds: 5), () {
        Navigator.pushNamed(context, RoutesManager.homeScreen);
      });
    } else {
      Timer(const Duration(seconds: 5), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      });
    }
  }
}
