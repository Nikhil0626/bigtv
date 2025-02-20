import 'dart:developer';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../utils/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _mobileNumberError;

  String mobileNumber = "Fetching...";
  List simCards = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPhoneNumber();
  }

  Future<void> getPhoneNumber() async {
    try {
      if (await Permission.location.request().isGranted) {
      } else {
        Permission.location;
        Permission.locationAlways;
      }
      if (await Permission.phone.request().isGranted) {
        bool hasPermission = await MobileNumber.hasPhonePermission ?? false;
        if (!hasPermission) {
          await MobileNumber.requestPhonePermission;
        }

        // Fetch SIM details
        mobileNumber = await MobileNumber.mobileNumber ?? "";
        // if (cards!.isNotEmpty) {
        //   setState(() {
        //     // simCards = cards.toString();
        //     mobileNumber =  "No Number Found";
        //   });
        // } else {
        //   setState(() {
        //     mobileNumber = "No SIM Card Detected";
        //   });
        // }
      } else {
        setState(() {
          mobileNumber = "Permission Denied";
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        mobileNumber = "Error: ${e.toString()}";
      });
    }
  }

  String? phoneNumber;

  @override
  void dispose() {
    // context.read<AuthProvider>().mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Consumer<AuthProvider>(
            builder: (context, authProvider,__) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child:authProvider.isLoading?const AppLoadingScreen(): Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 50),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height(height: 100),

                        SvgPicture.asset(
                          'assets/svg/Chota_news_logo.svg',
                          height: 24,
                          width: 166,
                        ),
                        height(height: 44),
                        Text(
                          "Sign in",
                          textAlign: TextAlign.center,
                          style: fontStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600),
                        ),
                        height(height: 8),
                        Text(
                          "Start using with your mobile number",
                          textAlign: TextAlign.center,
                          style: fontStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.normal),
                        ),
                        height(height: 35),
                        Text(
                          "Mobile Number",
                          style: fontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        height(height: 10),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                  const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft:
                                      Radius.circular(8)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 14),
                                child: Text(
                                  "+91",
                                  style: fontStyle(
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
                                  controller: authProvider.mobileNumberController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    hintText: "Enter Mobile",
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onChanged: (value) {
                                    if (value.length > 9) {
                                      _mobileNumberError = null;
                                    }
                                    setState(() {});
                                  },
                                    validator: (value) {
                                      // Regular expression for Indian mobile numbers
                                      final RegExp mobileRegex = RegExp(r'^[6789]\d{9}$');

                                      if (value == null || value.isEmpty) {
                                        setState(() {
                                          _mobileNumberError = "Please enter your mobile number";
                                        });
                                        return "";
                                      } else if (value.length != 10) {
                                        setState(() {
                                          _mobileNumberError = "Please enter a valid 10-digit mobile number";
                                        });
                                        return "";
                                      } else if (!mobileRegex.hasMatch(value)) {
                                        setState(() {
                                          _mobileNumberError = "Please enter a valid mobile number";
                                        });
                                        return "";
                                      }

                                      setState(() {
                                        _mobileNumberError = null;
                                      });
                                      return null;
                                    }

                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_mobileNumberError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 10.0),
                            child: Text(
                              _mobileNumberError!,
                              style: fontStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        height(height: 20),
                        InkWell(
                          onTap: (){
                            if (authProvider.mobileNumberController.text.length < 9) {
                            } else {
                              if (_formKey.currentState!
                                  .validate()) {
                                log("phone number   ${authProvider.mobileNumberController.text.toString()}");
                                context.read<AuthProvider>().sendOtp(authProvider.mobileNumberController.text, context);
                              }
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration:  BoxDecoration(
                                color:authProvider.mobileNumberController.text.length > 9
                                    ? AppColors.appButtonColor
                                    : Colors.grey ,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Send OTP",
                              style: fontStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        height(height: 20),
                        TextButton(
                            onPressed: () {

                              context.read<AuthProvider>().loginStatus(LoginStatus.location,context,page: "Skip");
                            },
                            child: Center(
                              child: Text(
                                "Skip and login as guest",
                                style: fontStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ));
        }),
      ),
    );
  }
}
