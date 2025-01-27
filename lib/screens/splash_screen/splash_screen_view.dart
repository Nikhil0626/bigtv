import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenView();
}

class _SplashScreenView extends State<SplashScreenView> {
  @override
  void initState() {
    navigateApp();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Text(
                    "Chota",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "News",
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.lightBlue,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future navigateApp() async {
    String loginId = GlobalVariables().loginId ?? "";
    log(loginId.toString());
    if (loginId != null || loginId != "") {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushNamed(context, RoutesManager.homeScreen);
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushNamed(context, RoutesManager.login);
      });
    }
  }
}
