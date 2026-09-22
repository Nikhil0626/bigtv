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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: TopRightWavePainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  buildSettingsPageHeader(context, "Privacy Policy"),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                            ),
                            height(height: 12),
                            sectionContent(
                              "This privacy notice does not cover any websites, services, applications, or businesses provided by third parties that Bigtv News does not own, control, or have any influence over Third Party Services. Bigtv News explicitly disclaims liability for any privacy policies or data collection procedures used by third-party services.",
                            ),
                            height(height: 12),
                            sectionContent(
                              "If you don't agree with any of the terms and conditions of the App, you shouldn't download, install, or use it. Bigtv News has the right to make changes at any moment and without prior notice. By downloading, installing, and/or using this programme, you consent to be governed by any such revisions, additions, amendments, or modifications.",
                            ),
                            height(height: 20),
                            sectionTitle("Information the user provides to Bigtv News:"),
                            height(height: 8),
                            Text(
                              "• Information That Identifies Any Individual: Email is used solely for user identification and authentication.",
                              style: TextStyle(fontSize: 14.sp, height: 1.5, color: const Color(0xFF475569)),
                            ),
                            height(height: 6),
                            Text(
                              "• Device Data: We collect data about the user in order to uniquely validate and authenticate the device.",
                              style: TextStyle(fontSize: 14.sp, height: 1.5, color: const Color(0xFF475569)),
                            ),
                            height(height: 6),
                            Text(
                              "• Storage Access: To keep the user's selected images, videos, and offline news, the software needs access to the device's storage.",
                              style: TextStyle(fontSize: 14.sp, height: 1.5, color: const Color(0xFF475569)),
                            ),
                            height(height: 6),
                            Text(
                              "• Location: The programme delivers news and content to users in accordance with their consent and in accordance with their location.",
                              style: TextStyle(fontSize: 14.sp, height: 1.5, color: const Color(0xFF475569)),
                            ),
                            height(height: 20),
                            sectionTitle("What makes use of the data that Bigtv News gathers?"),
                            height(height: 8),
                            sectionContent(
                              "When you login to the App, we recognise you using your email address or mobile number. Based on the content and personally identifiable information pertaining to You, Bigtv News may be able to control Your access to and use of the App, communicate with the User, customise Your experience using the App, and send relevant updates.",
                            ),
                            height(height: 8),
                            sectionContent(
                              "Bigtv News adheres to the necessary data collection, storage, and processing policies and security measures to guard against unauthorised access, alteration, disclosure, or destruction of Your personal information.",
                            ),
                            height(height: 20),
                            sectionTitle("Sharing identity and security details"),
                            height(height: 8),
                            sectionContent(
                              "Except as indicated in this Policy, Bigtv News does not transfer, sell, or rent Your personally identifiable information to outsiders. For the aforementioned reasons, Bigtv News may divulge generic aggregated demographic data about its users and visitors to its business partners and dependable affiliates.",
                            ),
                            height(height: 20),
                            sectionTitle("Modifications to this Terms Of service"),
                            height(height: 8),
                            sectionContent(
                              "This Privacy Policy could be revised and updated from time to time by Bigtv News. The updated Privacy Policy will be made available here. It is advised that you often visit this page to learn about updates to the Privacy Policy.",
                            ),
                            height(height: 20),
                            sectionTitle("Your Assent to These Privacy Terms"),
                            height(height: 8),
                            sectionContent(
                              "You confirm that you have read and agree to the Privacy Policy by using this App. If you disagree with our privacy policy, you are not allowed to use or access this application.",
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

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget sectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: const Color(0xFF475569),
      ),
    );
  }
}
