import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
import 'package:chotanews/screens/Auth_module/auth_event.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:chotanews/screens/Auth_module/sign_in_screen.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigator.pop(context, LoginScreen());
          },
        ),
      ),
      body: BlocConsumer<AuthBloc,AuthState>(
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
                const Text(
                  "Welcome",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                 height(height: 8),
                const Text(
                  "The big app for hyperlocal short news",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    child: const Text(
                      "Sign in with mobile number",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                 height(height: 20),
                InkWell(
                  onTap: (){
                    log("Goto Home Screen");
                    context.read<AuthBloc>().add(SkipLogin());
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
    );
  }
}
