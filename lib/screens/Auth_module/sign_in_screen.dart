import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
import 'package:chotanews/screens/Auth_module/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'auth_event.dart';
import 'enter_otp_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _mobileController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _mobileNumberError;

  void _validateAndSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnterOtpScreen()),
      );
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, const WelcomeScreen());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SvgPicture.asset(
                   'assets/svg/Chota_news_logo.svg',
                   height: 24,
                   width: 166,
                ),
                const SizedBox(height: 45),

                const Text(
                  "Sign In",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Start using with your mobile number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Mobile Number*",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children:[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4),bottomLeft: Radius.circular(4)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                        child: const Text(
                          "+91",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "Enter Mobile",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),

                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   setState(() {
                            //     _mobileNumberError = "Please enter your mobile number";
                            //   });
                            //   return '';
                            // } else if (value.length != 10) {
                            //   setState(() {
                            //     _mobileNumberError = "Please enter a valid 10-digit mobile number";
                            //   });
                            //   return '';
                            // }
                            // setState(() {
                            //   _mobileNumberError = null;
                            // });
                            // return null;
                            context.watch<AuthBloc>().add(MobileNumberChanged(value!));
                          },
                        ),
                      ),
                    ],
                  ),
                ),


                if (_mobileNumberError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                    child: Text(
                      _mobileNumberError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _validateAndSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Send OTP",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
