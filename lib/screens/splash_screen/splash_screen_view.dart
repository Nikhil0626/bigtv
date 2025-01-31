import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';

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
      body: Image.asset(
        "assets/splash1.gif",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),

      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           const SizedBox(
      //             child: Text(
      //               "Chota",
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 30,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: Container(
      //
      //               decoration: const BoxDecoration(
      //                 color: Colors.lightBlue,
      //                 borderRadius: BorderRadius.only(
      //                   topLeft: Radius.circular(20),
      //                   bottomRight: Radius.circular(20),
      //                 ),
      //               ),
      //               child: const Padding(
      //                 padding: EdgeInsets.symmetric(horizontal: 20,vertical: 2),
      //                 child: Text(
      //                   "News",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 30,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Future navigateApp() async {
    String loginId = GlobalVariables().loginId ?? "";
    log(loginId.toString());
    if (loginId.isNotEmpty) {
      Timer(const Duration(seconds: 7), () {
        Navigator.pushNamed(context, RoutesManager.homeScreen);
      });
    } else {
      Timer(const Duration(seconds: 7), () {
        Navigator.pushNamed(context, RoutesManager.login);
      });
    }
  }
}
