import 'package:app_links/app_links.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../services/webengage_notification.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showGif = false;
  StreamSubscription<Uri>? linkSubscription;
  WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
  @override
  void initState() {
    super.initState();
    initDeepLinks(context);

  }

  Future<void> initDeepLinks(BuildContext context) async {
    bool didReceiveLink = false;

    linkSubscription = AppLinks().uriLinkStream.listen(
          (uri) {
        debugPrint('onAppLink: $uri');
        didReceiveLink = true;
        openAppLink(uri);
      },
      onError: (error) {
        debugPrint('Deep link error: $error');
        checkLastShownDate(context);
      },
    );

    // Wait for a short time to check if a deep link was received
    await Future.delayed(Duration(seconds: 2));

    // If no link was received, navigate to the home screen
    if (!didReceiveLink) {
      checkLastShownDate(context);
    }
  }


  void openAppLink(Uri uri) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeView(),)
    );
  }



  Future<void> checkLastShownDate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('last_shown_date');
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

    if (lastDate != today) {
      setState(() {
        showGif = true;
      });
      await prefs.setString('last_shown_date', today);
    }
    Future.delayed( Duration(seconds:showGif? 5:2),() {
      context.read<AuthenticationProvider>().isPageNavigation(context);
    },);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: showGif
            ?  Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Image.asset(
                        "assets/svg/splash_video.gif",
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
            )// Show GIF
            :  SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
              child: Center(
                child: Image.asset(
                      "assets/playstore.png",
                      height: 100,
                      width: 100,
                    ),
              ),
            ), // Show Image
      ),
    );
  }
}
