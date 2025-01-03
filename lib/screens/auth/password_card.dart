
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_buttons.dart';
import '../../utils/app_enums.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_textformfield.dart';
import 'auth_provider.dart';

class PasswordCard extends StatefulWidget {
  final formKey;
  const PasswordCard({super.key, required this.formKey});

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, authProvider, __) {
      return Card(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 30.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  authProvider.changeType(LoginType.login);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_sharp,
                      size: 20.sp,
                    ),
                    width(width: 15),
                    Text(
                      AppStrings.backToSign,
                      style: fontStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              height(height: 10),
              Padding(
                padding:  EdgeInsets.only(left: 10.0.sp),
                child: Image.asset("assets/signup.png",height: 40.h,width: 30.w,),
              ),
              height(height: 10),
              Text(
                "Forgot password",
                style: fontStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              height(height: 2),
              Text(
                AppStrings.getOtp,
                style: fontStyle(color: Colors.black, fontSize: 12),
              ),
              height(height: 15),
              AppTextFormField(
                  textEditingController: authProvider.updatePassword,
                  isFormValid: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  onChange: authProvider.checkPasswordStrength,
                  prefixIcon: Icons.password,
                  obscureText: true,
                  label: AppStrings.password),
              height(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: index < authProvider.strengthLevel
                          ? authProvider.getSegmentColor(index)
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              height(height: 10),
              AppTextFormField(
                  textEditingController: authProvider.confirmPassword,
                  isFormValid: true,
                  onChange: authProvider.checkPasswordStrength,
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
                  label: AppStrings.confirmPassword),
              height(height: 15),
              if (authProvider.isLogin)
                const AppLoadingScreen()
              else
                AppButtons(
                    name: AppStrings.changePassword,
                    onTap: () {
                      setState(() {

                      });
                      if (widget.formKey.currentState!.validate()) {
                        authProvider.changePassword(context);
                      }

                    })
            ],
          ),
        ),
      );
    });
  }

}




