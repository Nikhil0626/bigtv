import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/dynamic_link_service.dart';
import '../Auth_module/welcome_screen.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenView();
}

class _SplashScreenView extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    navigateApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "assets/svg/splash_video.gif",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: InkWell(
              onTap: () {
                skipMethod();
              },
              child: Text(
                "Skip  >>>",
                style: fontStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future navigateApp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String loginId = sharedPreferences.getString("loginId").toString();
    log(loginId.toString());
    if (loginId != "null") {
      Timer(const Duration(seconds: 5), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.homeScreen,
          (route) => false,
        );
      });
    } else {
      Timer(const Duration(seconds: 5), () {
        DynamicLinkService.handleDynamicLinks(context);
      });
    }
  }

  Future skipMethod() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String loginId = sharedPreferences.getString("loginId").toString();
    log(loginId.toString());
    if (loginId != "null") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.homeScreen,
          (route) => false,
        );
    } else {
        DynamicLinkService.handleDynamicLinks(context);
    }
  }
}
