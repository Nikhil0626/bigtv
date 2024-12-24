
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/auth/password_card.dart';
import 'package:tweetai/screens/auth/send_otp_card.dart';
import 'package:tweetai/utils/app_colors.dart';

import '../../utils/app_enums.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_strings.dart';
import 'auth_provider.dart';
import 'login_card.dart';
import 'otp_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<AuthProvider>().loginType = LoginType.login;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xffe1effe),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child:
                  Consumer<AuthProvider>(builder: (context, authProvider, child) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/tweet_ai.svg",height: 56,width: 278,),
                      height(height: 24),
                      Text(
                        AppStrings.loginPageText,
                        textAlign: TextAlign.center,
                        style: fontStyle(color: AppColors.headerTextColor, fontSize: 24,fontWeight: FontWeight.bold),
                      ),
                      height(height: 16),
                      if (authProvider.loginType == LoginType.login)
                        LoginCard(
                          formKey: _formKey,
                        )
                      else if (authProvider.loginType == LoginType.sendOtp)
                        SendOtpCard(formKey: _formKey)
                      else if (authProvider.loginType == LoginType.changePassword)
                        PasswordCard(formKey: _formKey)
                        else if (authProvider.loginType == LoginType.otp)
                        const OtpCard(),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    ));
  }
}
