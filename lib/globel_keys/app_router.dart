

import 'package:flutter/material.dart';

import '../aggricator_screens/chota_info_screens/about_us.dart';
import '../aggricator_screens/chota_info_screens/advertise_with_us.dart';
import '../aggricator_screens/chota_info_screens/contact_us.dart';
import '../aggricator_screens/chota_info_screens/privacy_policy.dart';
import '../aggricator_screens/chota_info_screens/terms_conditions.dart';
import '../aggricator_screens/splash_screen/splash_screen_view.dart';




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
  static const settingsScreen = '/settingsScreen';
  static const newReferEarnScreen = '/newReferEarnScreen';
  static const referralCode = '/referralCode';

  static Route<dynamic>? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) =>   SplashScreen());
      // case login:
      //   return MaterialPageRoute(builder: (context) => const LoginScreen(),);
      // case homeScreen:
      //   final args = setting.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(builder: (context) =>  HomeTopTabs(postId:args?['postId'] ?? '',tab:args?['tab'] ?? '',),);
      // case newReferEarnScreen:
      //   return MaterialPageRoute(builder: (context) =>  const NewReferEarnScreen());


      // case districtSelectionScreen:
      //   final args = setting.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(builder: (context) =>   DistrictsSelectionScreen(className:
      //   args?['className'] ?? '',)) ;
      // case chotaInfo:
      //   return MaterialPageRoute(builder: (context) => const SettingsScreen());
      // case settingsScreen:
      //   return MaterialPageRoute(builder: (context) => const SettingsScreen());
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
      // case profileScreen:
      //   return MaterialPageRoute(builder: (context) =>  ProfileScreen());

      // case referralCode:
      //   final args = setting.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(builder: (context) => ReferralCode(mobileNumber:args?['mobileNumber'] ?? '',));


        // case videoScreen:
        //   final args = setting.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (context) =>   VideosScreen(postId:
        // args?['postId'] ?? '',));
        // case galleryScreen:
        //   final args = setting.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (context) =>   GalleryScreen(postId:
        //             args?['postId'] ?? '',));
        // case magazineScreen:
        //   final args = setting.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (context) =>   MyagazinesScreen(postId:
        // args?['postId'] ?? '',));
        // case devotionalScreen:
        //   final args = setting.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (context) =>   DevotionalScreen(postId:
        // args?['postId'] ?? '',));
        // case podcastScreen:
        //   final args = setting.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (context) =>   PodcostScreen(postId:
        // args?['postId'] ?? '',));


        /// newAggregator appRouter screens

    











      default:
        // return null;
        return MaterialPageRoute(builder: (context) =>   SplashScreen());
    }
  }
}
