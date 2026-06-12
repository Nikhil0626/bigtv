import 'dart:io';

import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/services/deviice_details.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/privacy_policy.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (_, provider, __) {
        bool isOtpState = provider.newAppLoginStatus == NewAppLoginStatus.otp;
        bool isDark = context.theme.brightness == Brightness.dark;
        final colorScheme = context.colors;
        final typography = context.typography;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 23.w),
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildUnifiedForm(provider, isOtpState, isDark, colorScheme, typography),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedForm(AuthenticationProvider provider, bool isOtpState, bool isDark, ColorScheme colorScheme, TextTheme typography) {
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
                color: isDark ? AppColorTokens.darkSurface : Colors.white,
                border: Border.all(color: colorScheme.outline, width: 1.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Text(
                    "+91",
                    style: typography.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: isDark ? AppColorTokens.darkIcon : AppColorTokens.lightIcon, size: 20.sp),
                  SizedBox(width: 8.w),
                  Container(
                    width: 1.w,
                    height: 24.h,
                    color: colorScheme.outline,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: provider.phoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: typography.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        hintStyle: typography.bodySmall?.copyWith(
                          fontSize: 14.sp,
                          color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        fillColor: Colors.transparent,
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
                  style: typography.bodySmall?.copyWith(
                    color: AppColorTokens.error,
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
                    provider.updateLoginStatus(NewAppLoginStatus.login);
                  },
                  child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                ),
                Text(
                  "OTP Verification",
                  style: typography.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 24), // Spacer to center title
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "Please enter the 4-digit code sent to\n+91 ${provider.phoneController.text}",
              textAlign: TextAlign.center,
              style: typography.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: provider.otpController,
                keyboardType: TextInputType.number,
                onChanged: (value) => provider.checkOtpFilled(value),
                cursorColor: colorScheme.primary,
                enablePinAutofill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10.r),
                  fieldHeight: 56.w,
                  fieldWidth: 56.w,
                  activeFillColor: isDark ? AppColorTokens.darkSurface : Colors.white,
                  activeColor: colorScheme.outline,
                  selectedColor: colorScheme.primary,
                  selectedFillColor: isDark ? AppColorTokens.darkSurface : Colors.white,
                  inactiveColor: colorScheme.outline,
                  inactiveFillColor: isDark ? AppColorTokens.darkSurface : Colors.white,
                  borderWidth: 1,
                ),
                autoDisposeControllers: false,
                autoDismissKeyboard: false,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ),
          ],
          const SizedBox(height: 10,),
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
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOtpState ? 'Verify' : 'Continue',
                      style: typography.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
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
            SizedBox(height: 24.h),
            RichText(
              text: TextSpan(
                text: "Didn't receive any OTP? ",
                style: typography.bodyMedium?.copyWith(
                  color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                  fontSize: 14.sp,
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = provider.canResend
                          ? () {
                              provider.sendOtp(context);
                            }
                          : null,
                    text: "Resend",
                    style: typography.bodyMedium?.copyWith(
                      color: provider.canResend ? colorScheme.primary : (isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            if (!provider.canResend)
              Text(
                "Request new OTP in ${provider.formatTime(provider.remainingTime)}",
                style: typography.bodySmall?.copyWith(
                  color: isDark ? AppColorTokens.darkTextSecondary.withValues(alpha: 0.7) : AppColorTokens.lightTextSecondary.withValues(alpha: 0.7),
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
                    style: typography.bodySmall?.copyWith(fontSize: 12.sp, color: AppColorTokens.error),
                    children: [
                      TextSpan(
                        text: '+919440913555',
                        style: typography.bodySmall?.copyWith(fontSize: 12.sp, color: AppColorTokens.info, fontWeight: FontWeight.w700),
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
            SizedBox(height: 12.h),
            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: typography.labelSmall?.copyWith(color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
                Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
              ],
            ),
            SizedBox(height: 12.h),
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
                        style: typography.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: colorScheme.primary,
                          decorationThickness: 2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: colorScheme.primary, size: 20.sp),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Terms and Privacy
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By continuing you agree to our\n',
                style: typography.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Use',
                    style: typography.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsConditions(),
                          ),
                        );
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: typography.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: typography.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicy(),
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
