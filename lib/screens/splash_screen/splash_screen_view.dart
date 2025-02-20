import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
