import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'otp_verification_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  void _validatePhoneNumber(String value) {
    setState(() {
      _isButtonEnabled = value.length == 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height.h,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 13,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/logo_ChotaNews_black.svg',
                        height: 34.h,
                        width: 237.w,
                      ),
                      height(height: 24.h),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: ' Get hyperlocal news\n',
                              style: newAppFont(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: 'in your local language',
                              style: newAppFont(fontSize: 12.sp, color: Colors.white),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      height(height: 30.h),
                      Container(
                        height: 360.h,
                        width: 326.w,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                height: 36.h,
                                width: 280.w,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: SizedBox(
                                  width: 68,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 18.h,
                                        width: 24.w,
                                        child: SvgPicture.asset('assets/svg/indianFlag.svg', fit: BoxFit.cover),
                                      ),
                                      Icon(Icons.keyboard_arrow_down_outlined, size: 22.sp),
                                      Container(
                                        height: 32.h,
                                        width: 1.w,
                                        color: Colors.grey,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.number,
                                          style: newAppFont(fontSize: 16.sp, fontWeight: FontWeight.w400),
                                          decoration: const InputDecoration(
                                            hintText: "",
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(left: 8),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Please enter mobile number';
                                            } else if (value.length < 10) {
                                              return 'Enter exactly 10 digits';
                                            } else if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
                                              return '';
                                            }
                                            return null;
                                          },
                                          onChanged: _validatePhoneNumber,
                                        ),

                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              height(height: 10.h),
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text: 'By clicking on Login/Signup you consent to our\n',
                                  style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy.',
                                      style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              height(height: 34.h),
                              ElevatedButton(
                                onPressed: _isButtonEnabled
                                    ? () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => OtpVerificationView()),
                                    );
                                  }
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                child: Text('Log In / Signup', style: newAppFont(color: Colors.white)),
                              ),
                              height(height: 30.h),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('Or', style: newAppFont(color: Colors.black54)),
                                  ),
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                ],
                              ),
                              height(height: 30.h),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                child: Text('Continue as Guest', style: newAppFont(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
