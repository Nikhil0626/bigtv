import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import '../../event_repo.dart';
import '../../in_app_web_view.dart';
import '../../../services/base_urls.dart';
import '../../../services/deviice_details.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthenticationProvider? authenticationProvider;

  @override
  void initState() {
    authenticationProvider = Provider.of<AuthenticationProvider>(listen: false, context);
    authenticationProvider!.phoneController.text = "";
    authenticationProvider!.isButtonEnabled = false;
    getMobileNumber();
    getData();

    // context.read<AuthProvider>().sendEvent("WellComePage");
    super.initState();
  }

  getMobileNumber() async {
    WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log('APNS Token: $apnsToken');
      getUniqueDeviceId(apnsToken ?? "");
    } else if (Platform.isAndroid) {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        getUniqueDeviceId(
          token,
        );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: context.watch<AuthenticationProvider>().isBlockedUser == false ? MediaQuery.of(context).size.height * .75 : MediaQuery.of(context).size.height * .5,
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
            children: [Text(
              'Get Code $siva',
              style: newAppFont(
                fontSize: 11.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
              height(height: 10.h),
              Container(
                height: 40.h,
                width: 280.w,
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColors.loginNumberBg,
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 18.h,
                        width: 24.w,
                        child: SvgPicture.asset('assets/svg/indianFlag.svg', fit: BoxFit.cover),
                      ),
                      Text(
                        " +91",
                        style: newAppFont(color: AppColors.textColor, fontWeight: FontWeight.w600),
                      ),
                      width(width: 10),
                      Container(
                        width: 1.w,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(8.r), topRight: Radius.circular(8.r)),
                          ),
                          child: TextFormField(
                            controller: authenticationProvider!.phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            style: newAppFont(fontSize: 16.sp, fontWeight: FontWeight.w400),
                            decoration: const InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              counterText: "",
                              contentPadding: EdgeInsets.only(left: 8),
                            ),
                            // inputFormatters: [
                            //   FilteringTextInputFormatter.digitsOnly,
                            //   LengthLimitingTextInputFormatter(10),
                            // ],

                              onChanged: (value) => authenticationProvider!.validationErrors(value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (authenticationProvider!.errorMessage != null && !authenticationProvider!.isButtonEnabled)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, right: 8.w),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        textAlign: TextAlign.right,
                        authenticationProvider!.errorMessage!,
                        style: fontStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                height(height: 10.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: 'By clicking on Login/Signup you consent to our ',
                      style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InAppWebViewScreen(
                                    webUrl: BaseUrls.termsPage,
                                    title: "Terms & Conditions",
                                  ),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: ' and ',
                          style: newAppFont(fontSize: 12.sp, color: Colors.black54),
                        ),
                        TextSpan(
                          text: 'Privacy Policy.',
                          style: newAppFont(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InAppWebViewScreen(
                                    webUrl: BaseUrls.privacyPage,
                                    title: "Privacy policy",
                                  ),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                height(height: 24.h),
                InkWell(
                  onTap: authenticationProvider!.isButtonEnabled
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            authenticationProvider!.sendOtp(context);
                            authenticationProvider!.updateNumber();
                          }
                        }
                      : null,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 36.h,
                      decoration: BoxDecoration(
                          color: !authenticationProvider!.isButtonEnabled ? AppColors.bodyTextColor.withOpacity(.2) : AppColors.loginBgColor, borderRadius: BorderRadius.all(Radius.circular(8.r))),
                      child: Center(
                          child: authenticationProvider!.isLoginLoading
                              ? AppLoadingScreen(
                                  loadingColor: Colors.white,
                                )
                              : Text('Log In / Signup', style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500)))),
                ),
                if (context.watch<AuthenticationProvider>().isBlockedUser == false)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: 'Your account is inactive. Please contact the administrator to activate your account ',
                        style: newAppFont(fontSize: 12, color: Colors.red),
                        children: [
                          TextSpan(
                            text: '+919440913555',
                            style: newAppFont(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w700),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri phoneUri = Uri(scheme: 'tel', path: "+919440913555");
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  throw 'Could not call +919440913555';
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                height(height: 10.h),
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

                height(height: 20.h),
                InkWell(
                  onTap: () async {
                    context.read<AuthenticationProvider>().continueAsGuest(context);
                    authenticationProvider!.updateNumber();
                    EventRepo().addEvent({
                      "loginType": "skip",
                      "mobileNumber": "",
                      "createAt": DateTime.now().toString(),
                    }, "login_event");
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 36.h,
                      decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(8.r))),
                      child: Center(child: Text('Continue as Guest', style: newAppFont(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)))),
                ),
              ],
            ),
          ),
        ),
      );
  }

  String? siva;
  void getData() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    siva = sharedPreferences.getString("Nikil")??"hello raja";
    setState(() {

    });
  }
}
