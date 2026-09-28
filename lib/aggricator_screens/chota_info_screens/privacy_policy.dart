import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_spaces.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().sendEvent("PrivacyPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: TopRightWavePainter(isDark: isDark),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  buildSettingsPageHeader(context, "Privacy Policy"),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E4EA),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionContent(
                              "Please carefully read our privacy policies. This provides important details on Your rights and obligations. The data collection, use, storage, and disclosure procedures for the desktop and mobile apps of Bigtv News are described in this privacy statement (hereafter referred to as You, Your, or User). This privacy statement applies to the Bigtv News mobile application (hereinafter referred to as App), which is owned by Bigtv News Private Limited. By downloading, installing, or using this App, you consent to the use of Your personal information as stated in this privacy notice. By downloading, installing, using, or creating a Bigtv News profile, you consent to the collection, transfer, storage, disclosure, and other uses of Your information as outlined in this Privacy Policy.",
                              isDark: isDark,
                            ),
                            height(height: 12),
                            sectionContent(
                              "This privacy notice does not cover any websites, services, applications, or businesses provided by third parties that Bigtv News does not own, control, or have any influence over Third Party Services. Bigtv News explicitly disclaims liability for any privacy policies or data collection procedures used by third-party services.",
                              isDark: isDark,
                            ),
                            height(height: 12),
                            sectionContent(
                              "If you don't agree with any of the terms and conditions of the App, you shouldn't download, install, or use it. Bigtv News has the right to make changes at any moment and without prior notice. By downloading, installing, and/or using this programme, you consent to be governed by any such revisions, additions, amendments, or modifications.",
                              isDark: isDark,
                            ),
                            height(height: 20),
                            sectionTitle("Information the user provides to Bigtv News:", isDark: isDark),
                            height(height: 8),
                            bulletText("Information That Identifies Any Individual: Email is used solely for user identification and authentication.", isDark: isDark),
                            height(height: 6),
                            bulletText("Device Data: We collect data about the user in order to uniquely validate and authenticate the device.", isDark: isDark),
                            height(height: 6),
                            bulletText("Storage Access: To keep the user's selected images, videos, and offline news, the software needs access to the device's storage.", isDark: isDark),
                            height(height: 6),
                            bulletText("Location: The programme delivers news and content to users in accordance with their consent and in accordance with their location.", isDark: isDark),
                            height(height: 20),
                            sectionTitle("What makes use of the data that Bigtv News gathers?", isDark: isDark),
                            height(height: 8),
                            sectionContent(
                              "We make use of the information to make sure the app functions properly, fix technical issues, customize content, and show relevant updates.",
                              isDark: isDark,
                            ),
                            height(height: 20),
                            sectionTitle("Children's Privacy Protection:", isDark: isDark),
                            height(height: 8),
                            sectionContent(
                              "Our services do not target anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13.",
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, {bool isDark = false}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
    );
  }

  Widget sectionContent(String content, {bool isDark = false}) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF334155),
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget bulletText(String text, {bool isDark = false}) {
    return Text(
      "• $text",
      style: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF475569),
      ),
    );
  }
}
