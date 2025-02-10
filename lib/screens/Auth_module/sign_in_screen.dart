import 'dart:developer';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'dart:async';
import '../../utils/app_colors.dart';
import 'auth_event.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _mobileController = TextEditingController();

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
      // Request Permission
      if (await Permission.location.request().isGranted) {
        
      }else{
        Permission.location;
        Permission.locationAlways;
      }
      if (await Permission.phone.request().isGranted) {
        bool hasPermission = await MobileNumber.hasPhonePermission ?? false;
        if (!hasPermission) {
          await MobileNumber.requestPhonePermission;
        }

        // Fetch SIM details
        mobileNumber = await MobileNumber.mobileNumber??"";
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
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state is SuccessScreen) {
            if (state.message == "true") {
              Navigator.pushNamed(context, RoutesManager.enterOtpScreen,
                  arguments: {
                    "mobileNumber": _mobileController.text.toString(),
                    "otp": state.otp
                  });
            }
          }
        }, builder: (context, state) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: state is LoadingScreen
                  ? const Center(
                      child: AppLoadingScreen(),
                    )
                  : state is InitialScreen?
              Padding(
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
                                    fontSize: 24, fontWeight: FontWeight.w600),
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
                                    fontSize: 14, fontWeight: FontWeight.w600),
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
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
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
                                        controller: _mobileController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        decoration: const InputDecoration(
                                          counterText: "",
                                          hintText: "Enter Mobile",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                        onChanged: (value) {
                                          if (value.length > 9) {
                                            _mobileNumberError = null;
                                          }
                                          setState(() {});
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            setState(() {
                                              _mobileNumberError =
                                                  "Please enter your mobile number";
                                            });
                                            return "";
                                          } else if (value.length != 10) {
                                            setState(() {
                                              _mobileNumberError =
                                                  "Please enter a valid 10-digit mobile number";
                                            });
                                            return "";
                                          }
                                          setState(() {
                                            _mobileNumberError = null;
                                          });
                                          return null;
                                          // context.watch<AuthBloc>().add(MobileNumberChanged(value!));
                                        },
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
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              height(height: 40),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_mobileController.text.length < 9) {
                                    } else {
                                      if (_formKey.currentState!.validate()) {
                                        log("phone number   ${_mobileController.text.toString()}");
                                        context.read<AuthBloc>().add(SendOtp(
                                            phoneNumber: _mobileController.text
                                                .toString()));
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _mobileController.text.length > 9
                                            ? Colors.lightBlue
                                            : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Send OTP",
                                    style: fontStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              height(height: 22),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        RoutesManager.districtSelectionScreen);
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Skip and login as guest",
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
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
                              height(height: 30),
                              Text(
                                "Sign In",
                                textAlign: TextAlign.center,
                                style: fontStyle(
                                    fontSize: 24, fontWeight: FontWeight.w600),
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
                              height(height: 30),
                              Text(
                                "${mobileNumber}",
                                style: fontStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              height(height: 16),
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
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            bottomLeft: Radius.circular(4)),
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
                                        controller: _mobileController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        decoration: const InputDecoration(
                                          counterText: "",
                                          hintText: "Enter Mobile",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                        onChanged: (value) {
                                          if (value.length > 9) {
                                            _mobileNumberError = null;
                                          }
                                          setState(() {});
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            setState(() {
                                              _mobileNumberError =
                                                  "Please enter your mobile number";
                                            });
                                            return "";
                                          } else if (value.length != 10) {
                                            setState(() {
                                              _mobileNumberError =
                                                  "Please enter a valid 10-digit mobile number";
                                            });
                                            return "";
                                          }
                                          setState(() {
                                            _mobileNumberError = null;
                                          });
                                          return null;
                                          // context.watch<AuthBloc>().add(MobileNumberChanged(value!));
                                        },
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
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              height(height: 20),

                              InkWell(
                                onTap: (){
                                  if (_mobileController.text.length < 9) {
                                  } else {
                                    if (_formKey.currentState!.validate()) {
                                      log("phone number   ${_mobileController.text.toString()}");
                                      context.read<AuthBloc>().add(SendOtp(
                                          phoneNumber: _mobileController.text
                                              .toString()));
                                    }
                                  }
                                },

                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: _mobileController.text.length < 3
                                          ? Colors.grey
                                          : AppColors.appButtonColor,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Send OTP",
                                    style: fontStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),

                              height(height: 20),
                              ...simCards.map((sim) => Text("SIM: ${sim.carrierName}, ${sim.number ?? 'Unknown'}")).toList(),

                              height(height: 20),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        RoutesManager.districtSelectionScreen);
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Skip and login as guest",
                                      style: TextStyle(
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
