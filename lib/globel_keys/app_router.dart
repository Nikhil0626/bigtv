
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/screens/testing_screen/test2.dart';
import 'package:flutter/material.dart';

import '../screens/testing_screen/test1.dart';
import '../screens/testing_screen/test_view.dart';

abstract class RoutesManager {
  RoutesManager._();

  static const splashScreen = '/';
  static const onboardingScreen = '/onboardingScreen';
  static const signUpScreen = '/signUpScreen';
  static const login = '/login';
  static const dashBoardScreen = '/dashBoardScreen';
  static const homeScreen = '/homeScreen';
  static const newsGenerateScreen = '/newsGenerateScreen';

  static Route<dynamic>? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) =>  HomeScreenView());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen(),);
      case homeScreen:

        return MaterialPageRoute(builder: (context) => const HomeScreenView(),);



      // case newsGenerateScreen:
      //   final args = setting.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //       builder: (context) => NewsGenerateScreen(
      //             tweetId:
      //                 args?['tweetId'] ?? '', // Use a default value if null
      //             tweetText: args?['tweetText'] ?? '',
      //         screenType: args?['screenType'] ?? '',
      //           ));

      default:
        // return null;
        return MaterialPageRoute(builder: (context) =>  HomeScreenView());
    }
  }
}
