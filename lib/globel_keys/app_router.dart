
import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/devotional_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/gallery_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/myagazines_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/podcost_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/videos_view_screen.dart';
import 'package:chotanews/welcome_screens/enter_otp_screen.dart';
import 'package:chotanews/welcome_screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../onbording_screens/onboarding_screen.dart';
import '../screens/Auth_module/enter_otp_screen.dart';
import '../screens/Auth_module/sign_in_screen.dart';
import '../screens/Auth_module/welcome_screen.dart';
import '../screens/chota_info_screens/chota_info.dart';
import '../screens/districts_selection/districts_selection_screen.dart';
import '../screens/home_screen/home_top_tabs.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/splash_screen/splash_screen_view.dart';
import '../screens/videos_main/tab_screen.dart';
import '../welcome_screens/welcome_screen.dart';

abstract class RoutesManager {
  RoutesManager._();

  static const splashScreen = '/';
  static const districtSelectionScreen = '/districtSelectionScreen';
  static const onboardingScreen = '/onboardingScreen';
  static const signUpScreen = '/signUpScreen';
  // static const login = '/login';
  static const dashBoardScreen = '/dashBoardScreen';
  static const homeScreen = '/homeScreen';
  static const newsGenerateScreen = '/newsGenerateScreen';
  static const chotaInfo = '/chotaInfo';
  static const aboutUs = '/aboutUs';
  static const contactUs = '/contactUs';
  static const advertiseWithUs = '/advertiseWithUs';
  static const termsConditions = '/termsConditions';
  static const privacyPolicy = '/privacyPolicy';
  static const profileScreen = '/profileScreen';
  static const welcomeScreen = '/welcomeScreen';
  static const signInScreen = '/signInScreen';
  static const enterOtpScreen = '/enterOtpScreen';
  static const videoScreen = '/videoScreen';
  static const galleryScreen = '/galleryScreen';
  static const magazineScreen = '/magazineScreen';
  static const devotionalScreen = '/devotionalScreen';
  static const podcastScreen = '/podcastScreen';
  static const getAllMenuItemScreen = '/getAllMenuItemScreen';

  static Route<dynamic>? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) =>  const SplashScreenView());
      // case login:
      //   return MaterialPageRoute(builder: (context) => const LoginScreen(),);
      case homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeTopTabs(),);

      case onboardingScreen:
        return MaterialPageRoute(builder: (context) => const OnboardingScreen());
      case districtSelectionScreen:
        return MaterialPageRoute(builder: (context) =>  const DistrictsSelectionScreen()) ;
      case chotaInfo:
        return MaterialPageRoute(builder: (context) => const ChotaInfo());
      case aboutUs:
        return MaterialPageRoute(builder: (context) =>  AboutUs());
      case contactUs:
        return MaterialPageRoute(builder: (context) => const ContactUs());
      case advertiseWithUs:
        return MaterialPageRoute(builder: (context) => const AdvertiseWithUs());
      case termsConditions:
        return MaterialPageRoute(builder: (context) => const TermsConditions());
      case privacyPolicy:
        return MaterialPageRoute(builder: (context) => const PrivacyPolicy());
      case profileScreen:
        return MaterialPageRoute(builder: (context) =>  ProfileScreen());
      case welcomeScreen:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      case signInScreen:
        return MaterialPageRoute(builder: (context) => const SignInScreen());
      case enterOtpScreen:
        return MaterialPageRoute(builder: (context) =>  const EnterOtpScreen());
        case getAllMenuItemScreen:
        return MaterialPageRoute(builder: (context) =>  const GetAllMenuItemScreen());
        case videoScreen:
          final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) =>   VideosScreen(postId:
        args?['postId'] ?? '',));
        case galleryScreen:
          final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) =>   GalleryScreen(postId:
                    args?['postId'] ?? '',));
        case magazineScreen:
          final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) =>   MyagazinesScreen(postId:
        args?['postId'] ?? '',));
        case devotionalScreen:
          final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) =>   DevotionalScreen(postId:
        args?['postId'] ?? '',));
        case podcastScreen:
          final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) =>   PodcostScreen(postId:
        args?['postId'] ?? '',));



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
