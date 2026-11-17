import 'dart:io';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashProvider extends ChangeNotifier {
  bool showGif = false;

  Future<void> checkLastShownDate(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastDate = prefs.getString('last_shown_date');
      String? locationNames = prefs.getString("locationNames");
      String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      if (lastDate == today) {
        showGif = false;
        notifyListeners();
      }
      await prefs.setString('last_shown_date', today);
      EventRepo().addEvent(
        {
          "createAt": DateTime.now().toString(),
          "platform": Platform.isIOS ? "iOS" : "android",
          "districtNames": locationNames ?? "",
        },
        "opened_app",
      );
    } catch (e) {
      debugPrint("Splash error: $e");
    }

    await Future.delayed(Duration(milliseconds: showGif ? 1500 : 1000));
    if (context.mounted) {
      try {
        context.read<HomeProvider>().getAppConfig();
        await context.read<HomeProvider>().loadLanguage();
        // While opening the app, hit the profile API, get the data and store locally
        context.read<ProfileProvider>().getProfile(showLoading: false);
        // Pre-fetch languages and locations/states in background so they are ready instantly
        final authProvider = context.read<AuthenticationProvider>();
        authProvider.getAllLanguages();
        authProvider.getAllLocations();
      } catch (e) {
        debugPrint("Error loading app config / profile: $e");
      }
      if (context.mounted) {
        context.read<AuthenticationProvider>().isPageNavigation(context);
      }
    }
  }
}
