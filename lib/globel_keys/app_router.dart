
import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:flutter/material.dart';

import '../onbording_screens/onboarding_screen.dart';
import '../screens/chota_info_screens/chota_info.dart';
import '../screens/districts_selection/districts_selection_screen.dart';
import '../screens/splash_screen/splash_screen_view.dart';

abstract class RoutesManager {
  RoutesManager._();

  static const splashScreen = '/';
  static const districtSelectionScreen = '/districtSelectionScreen';
  static const onboardingScreen = '/onboardingScreen';
  static const signUpScreen = '/signUpScreen';
  static const login = '/login';
  static const dashBoardScreen = '/dashBoardScreen';
  static const homeScreen = '/homeScreen';
  static const newsGenerateScreen = '/newsGenerateScreen';
  static const chotaInfo = '/chotaInfo';
  static const aboutUs = '/aboutUs';
  static const contactUs = '/contactUs';
  static const advertiseWithUs = '/advertiseWithUs';
  static const termsConditions = '/termsConditions';
  static const privacyPolicy = '/privacyPolicy';

  static Route<dynamic>? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) =>  const SplashScreenView());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen(),);
      case homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreenView(),);

      case onboardingScreen:
        return MaterialPageRoute(builder: (context) => const OnboardingScreen());
      case districtSelectionScreen:
        return MaterialPageRoute(builder: (context) =>  const DistrictsSelectionScreen()) ;
      case chotaInfo:
        return MaterialPageRoute(builder: (context) => const ChotaInfo());
      case aboutUs:
        return MaterialPageRoute(builder: (context) => const AboutUs());
      case contactUs:
        return MaterialPageRoute(builder: (context) => const ContactUs());
      case advertiseWithUs:
        return MaterialPageRoute(builder: (context) => const AdvertiseWithUs());
      case termsConditions:
        return MaterialPageRoute(builder: (context) => const TermsConditions());
      case privacyPolicy:
        return MaterialPageRoute(builder: (context) => const PrivacyPolicy());



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
        return MaterialPageRoute(builder: (context) =>  const SplashScreenView());
    }
  }
}
