import 'dart:io';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/about_us.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/theme_provider.dart';

import '../../../services/webengage_notification.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/app_fonts.dart';
import '../../chota_info_screens/advertise_with_us.dart';
import '../../chota_info_screens/privacy_policy.dart';
import '../../chota_info_screens/terms_conditions.dart';
import '../../events_data/event_repo.dart';
import 'filters_screen/filter_view.dart';
import 'profile_view.dart';
import 'feedback_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  String? _fcmToken;
  String? _apnsToken;
  bool _isLoadingTokens = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().getLoginDetails();
      _fetchTokens();
    });
    context.read<AuthenticationProvider>().sendEvent("SettingsView");
  }

  Future<void> _fetchTokens() async {
    try {
      final fcm = await getAppFcmToken();
      String? apns;
      if (Platform.isIOS) {
        try {
          apns = await FirebaseMessaging.instance.getAPNSToken();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _fcmToken = fcm;
          _apnsToken = apns;
          _isLoadingTokens = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTokens = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSettingsRow(context, "profile.png", "Edit Profile", () {
                        EventRepo().addEvent({
                          "visitPageName":"Edit Profile",
                          "createAt": DateTime.now().toString(),
                        }, "compliance_section");
                        if (settingsProvider.isNotificationsEnabled == false) {
                          context.read<AuthenticationProvider>().newAppLoginStatus = NewAppLoginStatus.login;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginBackgroundView()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileView()),
                          );
                        }
                      }),
                      SizedBox.shrink(),

                  _buildThemeToggle(context),

                  _buildSettingsRow(context, "Filter.svg", "Filter", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FilterView()));
                  }),

                  _buildSettingsRow(context, "Help_support.svg", "Help & Support", () {
                    EventRepo().addEvent({
                      "visitPageName": "Help & Support",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutUs(),
                      ),
                    );
                  }),

                  _buildSettingsRow(context, "Advertise_icon.svg", "Advertise With Us", () {
                    EventRepo().addEvent({
                      "visitPageName": "Advertise With Us",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvertiseWithUs(),
                      ),
                    );
                  }),

                  _buildSettingsRow(context, "Terms_icon.svg", "Terms & Conditions", () {
                    EventRepo().addEvent({
                      "visitPageName": "Terms & Conditions",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsConditions(),
                      ),
                    );
                  }),

                  _buildSettingsRow(context, "Private_icon.svg", "Privacy Policy", () {
                    EventRepo().addEvent({
                      "visitPageName": "Privacy Policy",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicy(),
                      ),
                    );
                  }),
                  if (Platform.isIOS)
                    _buildTokenCard(
                      context,
                      title: "Apple APNs Token",
                      token: _apnsToken,
                      copyLabel: "APNs Token",
                      icon: Icons.apple,
                    ),

                  _buildTokenCard(
                    context,
                    title: "Firebase FCM Token",
                    token: _fcmToken,
                    copyLabel: "FCM Token",
                    icon: Icons.notifications_active_outlined,
                  ),

                  _buildSettingsRow(context, "Feedback.svg", "Feedback", () {
                    EventRepo().addEvent({
                      "visitPageName": "Feedback",
                      "createAt": DateTime.now().toString(),
                    }, "compliance_section");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
                  }),

                  _buildSettingsRow(context, "Signout.svg", !settingsProvider.isNotificationsEnabled ? "Login" : "Logout", () async {
                    closeSubscribe();
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    String? deviceId = preferences.getString("deviceId");
                    String? userId = preferences.getString("userId");

                    WebEngagePlugin.trackEvent('logout_user', {
                      "device_id": "$deviceId",
                      "date_time": DateTime.now().toString(),
                      "user_id": userId ?? "",
                    });
                    WebEngagePlugin.userLogout();
                    context.read<AuthenticationProvider>().setLogOutStatus(context, false);
                    EventRepo().addEvent({
                      "loginType": "logout",
                      "mobileNumber": "",
                      "createAt": DateTime.now().toString(),
                    }, "login_event");
                  }),
                  height(height: 10),
                ],
              ),
            ),),

            Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Text(
                "V${settingsProvider.appVersion}",
                style: fontStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }


  Widget _buildSettingsRow(BuildContext context, String iconName, String title, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                iconName =="profile.png"?Image.asset('assets/svg/$iconName',height: 24.w, width: 24.w, color: context.iconTheme.color): SvgPicture.asset('assets/svg/$iconName', height: 24.w, width: 24.w, colorFilter: ColorFilter.mode(context.iconTheme.color ?? Colors.grey, BlendMode.srcIn)),
                width(width: 16.w),
                Text(title, style: context.typography.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: context.subtitleColor),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: context.borderColor.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildTokenCard(
    BuildContext context, {
    required String title,
    required String? token,
    required String copyLabel,
    required IconData icon,
  }) {
    final displayText = token != null && token.isNotEmpty
        ? token
        : (_isLoadingTokens ? "Loading token..." : "Not available");
    final bool canCopy = token != null && token.isNotEmpty;

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 24.w, color: context.iconTheme.color),
              width(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.typography.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      displayText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.bodySmall?.copyWith(
                        color: context.subtitleColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (canCopy) ...[
                width(width: 8.w),
                IconButton(
                  icon: Icon(Icons.copy, size: 20, color: context.primaryColor),
                  tooltip: "Copy $copyLabel",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    CustomToast.showSuccessToast(msg: "$copyLabel copied to clipboard");
                  },
                ),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: context.borderColor.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      children: [
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.dark_mode, size: 24, color: context.iconTheme.color),
              width(width: 16.w),
              Text("Dark Mode", style: context.typography.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Spacer(),
              Switch(
                value: themeProvider.isDarkMode,
                activeThumbColor: context.primaryColor,
                onChanged: (val) {
                  themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.borderColor.withValues(alpha: 0.3)),
      ],
    );
  }
}
