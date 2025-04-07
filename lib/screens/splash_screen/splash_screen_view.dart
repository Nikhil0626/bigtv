import 'dart:developer';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_view.dart';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../services/dynamic_link_service.dart';
import '../Auth_module/auth_screens/welcome_screen.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenView();
}

class _SplashScreenView extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5),() {
      context.read<AuthProvider>().checkLoginStatus(context);

    },);
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
                context.read<AuthProvider>().checkLoginStatus(context);
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
}




class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showGif = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkLastShownDate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('last_shown_date');
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

    if (lastDate != today) {
      setState(() {
        showGif = true;
      });
      await prefs.setString('last_shown_date', today);
    }
    Future.delayed( Duration(seconds:showGif? 5:2),() {
      context.read<AuthenticationProvider>().isPageNavigation(context);
    },);
  }

  @override
  Widget build(BuildContext context) {
    checkLastShownDate(context);

    return Scaffold(
      body: Center(
        child: showGif
            ?  Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Image.asset(
                        "assets/svg/splash_video.gif",
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
            )// Show GIF
            :  Container(
          color: AppColors.loginBgColor,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
              child: Center(
                child: Image.asset(
                      "assets/playstore.png",
                      height: 100,
                      width: 100,
                    ),
              ),
            ), // Show Image
      ),
    );
  }
}
