
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/utils/app_colors.dart';

import '../../utils/app_buttons.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_textformfield.dart';
import 'auth_provider.dart';

class LoginCard extends StatelessWidget {
  final formKey;

  const LoginCard({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, authProvider, __) {
      return Card(
        color: Colors.white,
        // elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 30.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                AppStrings.signIn,
                style: fontStyle(
                    color: AppColors.headerTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              height(height: 2),
              Text(
                AppStrings.signInText,
                style: fontStyle(color:AppColors.headerTextColor, fontSize: 12),
              ),
              height(height: 10),
              AppTextFormField(
                  textEditingController: authProvider.userNameController,
                  isFormValid: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  label: AppStrings.email),
              height(height: 10),
              AppTextFormField(
                  textEditingController: authProvider.passwordController,
                  isFormValid: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  prefixIcon: Icons.password,
                  obscureText: true,
                  label: AppStrings.password),
              height(height: 10),
              InkWell(
                onTap: () {
                  authProvider.changeType(LoginType.sendOtp);
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    textAlign: TextAlign.end,
                    AppStrings.forgotPassword,
                    style: fontStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ),
              height(height: 10),
              if (authProvider.isLogin)
                const AppLoadingScreen()
              else
                AppButtons(
                    name: AppStrings.login,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        authProvider.login(context);
                      }
                    })
            ],
          ),
        ),
      );
    });
  }
}
