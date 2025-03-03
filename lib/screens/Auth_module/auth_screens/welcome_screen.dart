import 'dart:developer';
import 'dart:io';

import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/Auth_module/auth_screens/sign_in_screen.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../../services/deviice_details.dart';
import '../../../services/permission_handler_services.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
 @override
  void initState() {
   getMobileNumber();
    super.initState();
  }
 getMobileNumber()async{
   SharedPreferences sp = await SharedPreferences.getInstance();
   WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
   if (Platform.isIOS) {
     String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
     log('APNS Token: $apnsToken');
     getUniqueDeviceId(apnsToken??"",sp);
   }else if (Platform.isAndroid) {
     var token = await FirebaseMessaging.instance.getToken();
     if (token != null) {
       getUniqueDeviceId(token,sp);
       log('FCM Token: $token');
       _webEngagePlugin.tokenInvalidatedCallback(_onTokenInvalidated);
       WebEngagePlugin.setPushToken(token);
     }
   }
 }

 void _onTokenInvalidated(Map<String, dynamic>? message) {
   print("tokenInvalidated callback received $message");
   WebEngagePlugin.setSecureToken("siva kumar", message.toString());
 }
  @override
  Widget build(BuildContext context) {
    requestLocationPermission();

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                height(height: 50),
                Center(
                  child: SvgPicture.asset(
                    'assets/svg/Chota_news_logo.svg',
                    height: 40,
                    width: 240,
                  ),
                ),
                height(height:60),
                Text(
                  "Welcome",
                  style: fontStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                height(height: 8),
                Text(
                  "The big app for hyperlocal short news",
                  textAlign: TextAlign.center,
                  style: fontStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal),
                ),
                height(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:  Text(
                      "Sign in with mobile number",
                      style: fontStyle(fontSize: 16, color: Colors.white, ),
                    ),
                  ),
                ),
                height(height: 24),
                InkWell(
                  onTap: (){
                    log("Goto Home Screen");
                    context.read<AuthProvider>().className = "Skip";
                    context.read<AuthProvider>().loginStatus(LoginStatus.location,context);
                  },
                  child: Center(
                    child:  Text(
                      "Skip and login as guest",
                      style: fontStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
