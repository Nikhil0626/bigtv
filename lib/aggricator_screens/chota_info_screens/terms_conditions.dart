import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_spaces.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().sendEvent("TermsAndConditionsPage");
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
                  buildSettingsPageHeader(context, "Terms & Conditions"),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      children: [
                        Container(
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
                              Text(
                                "Bigtv News Network is a perfect platform for citizens to report news and make your content reach millions of users every day. The whole idea is to empower the audience with vivid categories and local happenings before any other medium, making them stay ahead of the rest.",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.5,
                                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF334155),
                                ),
                              ),
                              height(height: 20),
                              headlineWithContent(
                                "1. What is Bigtv News Network",
                                "Bigtv News Network is the easiest way to publish articles on Bigtv News app if you have a zeal to write and make some earnings additionally. Network by Bigtv News is an easy citizen powered, content publishing option to reach millions of readers and monetize content.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "2. Why contribute to us?",
                                "Bigtv News assures your content reaches to the right audience. A very unique and classy reading experience has enabled us to engage millions of active readers who are constantly consuming interesting content just like yours. Various categories and proper localization helped us to connect vernacular readers with diverse tastes and preferences. We want you to have a great experience when using Bigtv News. We are a small team working extremely hard on a mission to build great vernacular content for India and also power every locality, by building a 'civic Reporting' community.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "3. Registration",
                                "You need to register as a contributor on Bigtv News Network to publish your articles and videos so that the content can reach millions of readers on the Bigtv News App. We are open to common people, writers, and bloggers who want to write, gain weight, and make some earnings.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "4. Note",
                                "Name should be as per your photo ID. Do not use fake, alias, celebrity, or corporate names of any person or entity.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "5. Content Policy",
                                "Bigtv News Network provides a platform for people to put their views as well as news for the audience. In order to ensure a good experience for both contributors and writers, read our content policy carefully.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "6. Title",
                                "No wrong usage of punctuation. The title should be related to the story and informative. It should not be less than 20 characters.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "7. Content",
                                "Minimum 200 characters and a maximum of 400. Only relevant content/news needs to be submitted. Outdated and fake news will lead to escalations on the contributor. Content that is obscene in any form (text, image, or video) will not be accepted. No sensitive content or content that creates visual discomfort will be published. Religiously provoking, criminal, and sensitive content is strictly prohibited. Content should be original and should not be the property of any person or entity.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "8. Images",
                                "The image should be landscape and clear. Irrelevant images will be rejected. Watermarked, copyright, and promotional images will not be published.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "9. Payment Policy",
                                "Payments are done on a monthly basis. Payouts are made directly to the bank accounts after PAN card verification.",
                                isDark: isDark,
                              ),
                              headlineWithContent(
                                "10. Termination",
                                "We can terminate user registration at any time if they violate any of our policies. Further legal action will be taken based on the severity.",
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget headlineWithContent(String headline, String content, {bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        height(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
            color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF64748B),
          ),
        ),
        height(height: 16),
      ],
    );
  }
}
