import 'dart:io';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';


import 'package:chotanews/aggricator_screens/splash_screen/splash_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initATTAndProceed();
  }

  Future<void> _initATTAndProceed() async {
    if (Platform.isIOS) {
      // Small delay to ensure the splash screen UI is rendered before the iOS prompt appears
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } catch (e) {
        debugPrint("Error requesting ATT: $e");
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      context.read<SplashProvider>().checkLastShownDate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SplashProvider>(
        builder: (context, provider, child) {
          return Center(
            child: provider.showGif
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Lottie.asset(
                      "assets/svg/spinner.json",
                      fit: BoxFit.contain,
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Image.asset(
                        "assets/BIGTV-APP ICON.png",
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}



