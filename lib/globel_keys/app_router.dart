
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/dashboard_view/dashboard_view.dart';
import '../screens/dashboard_view/news_generate_screen.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/intial_screen/spalsh_screen.dart';

abstract class RoutesManager {
  RoutesManager._();

  static const splashScreen = '/';
  static const onboardingScreen = '/onboardingScreen';
  static const signUpScreen = '/signUpScreen';
  static const login = '/login';
  static const dashBoardScreen = '/dashBoardScreen';
  static const homeScreen = '/homeScreen';
  static const newsGenerateScreen = '/newsGenerateScreen';

  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case dashBoardScreen:
        return MaterialPageRoute(builder: (context) => const DashboardScreen());
      case newsGenerateScreen:
        final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (context) => NewsGenerateScreen(
                  tweetId:
                      args?['tweetId'] ?? '', // Use a default value if null
                  tweetText: args?['tweetText'] ?? '',
              screenType: args?['screenType'] ?? '',
                ));

      default:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
