import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../aggricator_screens/individual_post_details/individual_post_view.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showGif = false;
  StreamSubscription? pushSub;
  StreamSubscription? pushActionSub;
  Map<String, dynamic>? _initialPushPayload;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 300), () {
      checkLastShownDate();
    });
  }


  Future<void> checkLastShownDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('last_shown_date');
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    if (lastDate != today) {
      setState(() {
        showGif = true;
      });
      await prefs.setString('last_shown_date', today);
    }

    await Future.delayed(Duration(seconds: showGif ? 5 : 2));

    if (_initialPushPayload != null &&
        _initialPushPayload!['postId'] != null &&
        (_initialPushPayload!['postId'] as String).isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              IndividualPostView(postId: _initialPushPayload!['postId']),
        ),
      );
      return;
    }else{
      context.read<AuthenticationProvider>().isPageNavigation(context);

    }

    // 🚪 Default navigation
  }

  @override
  void dispose() {
    pushSub?.cancel();
    pushActionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: showGif
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Image.asset(
            "assets/svg/splash_video.gif",
            fit: BoxFit.cover,
          ),
        )
            : SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Image.asset(
              "assets/playstore.png",
              height: 100,
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}
