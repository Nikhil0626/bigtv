

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweets_provider.dart';

import '../screens/articles_view/article_provider.dart';
import '../screens/auth/auth_provider.dart';
import '../screens/dashboard_view/home_swipe_card_provider.dart';
import '../screens/home_screen/home_provider.dart';
import '../screens/settings_view/setting_provider.dart';
import '../screens/x_handles_view/x_handle_provider.dart';

class RegisterProviders {
  static List<SingleChildWidget> providers(BuildContext context) {
    return [
      ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
      ChangeNotifierProvider<HomeProvider>(create: (context) => HomeProvider()),
      ChangeNotifierProvider<HomeSwipeCardProvider>(create: (context) => HomeSwipeCardProvider()),
      ChangeNotifierProvider<ArticleProvider>(create: (context) => ArticleProvider()),
      ChangeNotifierProvider<SettingProvider>(create: (context) => SettingProvider()),
      ChangeNotifierProvider<XHandleProvider>(create: (context) => XHandleProvider()),
      ChangeNotifierProvider<XTweetsProvider>(create: (context) => XTweetsProvider()),
    ];
  }
}
