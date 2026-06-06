import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/services/deviice_details.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

class UnifiedAuthView extends StatefulWidget {
  const UnifiedAuthView({super.key});

  @override
  State<UnifiedAuthView> createState() => _UnifiedAuthViewState();
}

class _UnifiedAuthViewState extends State<UnifiedAuthView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthenticationProvider? authenticationProvider;

  // OTP Timer Variables
  int _remainingTime = 60;
  Timer? _timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    authenticationProvider = Provider.of<AuthenticationProvider>(listen: false, context);
    authenticationProvider!.phoneController.text = "";
    authenticationProvider!.isButtonEnabled = false;
    getMobileNumber();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  getMobileNumber() async {
    WebEngagePlugin webEngagePlugin = WebEngagePlugin();
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      getUniqueDeviceId(apnsToken ?? "");
    } else if (Platform.isAndroid) {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        getUniqueDeviceId(token);
        webEngagePlugin.tokenInvalidatedCallback(_onTokenInvalidated);
        WebEngagePlugin.setPushToken(token);
      }
    }
  }

  void _onTokenInvalidated(Map<String, dynamic>? message) {
    WebEngagePlugin.setSecureToken("siva kumar", message.toString());
  }

  void startCountdown() {
    setState(() {
      _remainingTime = 60;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (_, provider, __) {
        // Automatically start timer when switching to OTP state if not already running
        if (provider.newAppLoginStatus == NewAppLoginStatus.otp && _timer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            startCountdown();
          });
        } else if (provider.newAppLoginStatus != NewAppLoginStatus.otp) {
          _timer?.cancel();
          _timer = null;
        }

        bool isOtpState = provider.newAppLoginStatus == NewAppLoginStatus.otp;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 23.w),
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildUnifiedForm(provider, isOtpState),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedForm(AuthenticationProvider provider, bool isOtpState) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mobile Number Input
          if (!isOtpState)
            Container(
              height: 48.h,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.white,
                border: Border.all(color: Colors.grey.shade500, width: 1.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Text(
                    "+91",
                    style: newAppFont(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20.sp),
                  width(width: 8.w),
                  Container(
                    width: 1.w,
                    height: 24.h,
                    color: Colors.grey.shade500,
                  ),
                  width(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: provider.phoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: newAppFont(
                        fontSize: 16.sp,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        hintStyle: newAppFont(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                      ),
                      onChanged: (value) => provider.validationErrors(value),
                    ),
                  ),
                ],
              ),
            ),

          if (!isOtpState && provider.errorMessage != null && !provider.isButtonEnabled)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  provider.errorMessage!,
                  style: newAppFont(
                    color: Colors.red,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),

          if (isOtpState) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    provider.newAppLoginStatus = NewAppLoginStatus.login;
                    provider.notifyListeners();
                  },
                  child: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                Text(
                  "OTP Verification",
                  style: newAppFont(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 24), // Spacer to center title
              ],
            ),
            height(height: 16.h),
            Text(
              "Please enter the 4-digit code sent to\n+91 ${provider.phoneController.text}",
              textAlign: TextAlign.center,
              style: newAppFont(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            height(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: provider.otpController,
                keyboardType: TextInputType.number,
                onChanged: (value) => provider.checkOtpFilled(value),
                cursorColor: const Color(0xFFE50914),
                enablePinAutofill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10.r),
                  fieldHeight: 56.w,
                  fieldWidth: 56.w,
                  activeFillColor: Colors.white,
                  activeColor: Colors.grey.shade300,
                  selectedColor: const Color(0xFFE50914),
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade300,
                  inactiveFillColor: Colors.white,
                  borderWidth: 1,
                ),
                autoDisposeControllers: false,
                autoDismissKeyboard: false,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ),
          ],
          SizedBox(height: 10,),
          // Continue / Verify Button
          InkWell(
            onTap: isOtpState
                ? (provider.isOtpButtonEnabled
                    ? () {
                        provider.verifyOtp(context);
                      }
                    : null)
                : (provider.isButtonEnabled
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          provider.sendOtp(context);
                          provider.updateNumber();
                        }
                      }
                    : null),
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: (isOtpState ? provider.isOtpButtonEnabled : provider.isButtonEnabled)
                    ? const Color(0xFFE50914)
                    : Colors.red.shade300, // Premium Red or light red
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOtpState ? 'Verify' : 'Continue',
                      style: newAppFont(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    width(width: 8.w),
                    (isOtpState ? provider.isVerifyLoading : provider.isLoginLoading)
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(isOtpState ? Icons.check_circle_outline : Icons.arrow_forward, color: Colors.white, size: 20.sp),
                  ],
                ),
              ),
            ),
          ),

          if (isOtpState) ...[
            height(height: 24.h),
            RichText(
              text: TextSpan(
                text: "Didn't receive any OTP? ",
                style: newAppFont(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = canResend
                          ? () {
                              startCountdown();
                              provider.sendOtp(context);
                            }
                          : null,
                    text: "Resend",
                    style: newAppFont(
                      color: canResend ? const Color(0xFFE50914) : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            height(height: 8.h),
            if (!canResend)
              Text(
                "Request new OTP in ${formatTime(_remainingTime)}",
                style: newAppFont(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                ),
              ),
          ],

          if (!isOtpState) ...[
            if (context.watch<AuthenticationProvider>().isBlockedUser == false)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
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
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            height(height: 12.h),
            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: newAppFont(color: Colors.grey.shade500, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
              ],
            ),
            height(height: 12.h),
            // Continue as Guest
            InkWell(
              onTap: () async {
                context.read<AuthenticationProvider>().continueAsGuest(context);
                provider.updateNumber();
                EventRepo().addEvent({
                  "loginType": "skip",
                  "mobileNumber": "",
                  "createAt": DateTime.now().toString(),
                }, "login_event");
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue as Guest',
                        style: newAppFont(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFE50914), // Red underline (optional)
                          decorationThickness: 2,
                        ),
                      ),
                      width(width: 8.w),
                      Icon(Icons.arrow_forward, color: const Color(0xFFE50914), size: 20.sp),
                    ],
                  ),
                ],
              ),
            ),
            height(height: 8.h),
            // Terms and Privacy
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By continuing you agree to our\n',
                style: newAppFont(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Use',
                    style: newAppFont(
                      fontSize: 12.sp,
                      color: const Color(0xFFE50914),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InAppWebViewScreen(
                              webUrl: BaseUrls.termsPage,
                              title: "Terms & Conditions",
                            ),
                          ),
                        );
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: newAppFont(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: newAppFont(
                      fontSize: 12.sp,
                      color: const Color(0xFFE50914),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InAppWebViewScreen(
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
          ],
        ],
      ),
    );
  }
}
