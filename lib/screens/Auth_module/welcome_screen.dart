import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
import 'package:chotanews/screens/Auth_module/auth_event.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:chotanews/screens/Auth_module/sign_in_screen.dart';
import 'package:chotanews/screens/districts_selection/districts_selection_screen.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      body:
      Padding(
        padding: const EdgeInsets.only(top: 30),
        child: BlocConsumer<AuthBloc,AuthState>(
          listener: (context, state) {
            if(state is SuccessScreen){
              Navigator.pushNamedAndRemoveUntil(context, RoutesManager.homeScreen, (route) => false,);
            }
          },
          builder: (context,state) {
            return Padding(
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
                    style: fontStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DistrictsSelectionScreen(className: "")),
                      );
                      
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
            );
          }
        ),
      ),
    );
  }
}
