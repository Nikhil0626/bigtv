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
      log("Dynamic Links  ${data?.link}");
      final Uri? deepLink = data?.link;
      if (deepLink != null) {
        handleDeepLink(deepLink);
      }
    }).onError((error) {
      print('Dynamic Link Failed: $error');
    });

    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink?.link != null) {
      handleDeepLink(initialLink!.link);
    }
  }

  void handleDeepLink(Uri deepLink) {
    Uri uri = Uri.parse(deepLink.toString());

    String? postId = uri.queryParameters["postId"];

    print(postId);
    print('Deep Link: $deepLink');

    if (postId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IndividualPost(postId: postId,)),
      );
    }else{
      navigateApp();
    }
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
      Timer(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, RoutesManager.homeScreen);
      });
    } else {
      Timer(const Duration(seconds: 1), () {
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
