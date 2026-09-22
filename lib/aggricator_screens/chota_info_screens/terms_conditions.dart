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
                  buildSettingsPageHeader(context, "Terms & Conditions"),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      children: [
                        Container(
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
                              Text(
                                "Bigtv News Network is a perfect platform for citizens to report news and make your content reach millions of users every day. The whole idea is to empower the audience with vivid categories and local happenings before any other medium, making them stay ahead of the rest.",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.5,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              height(height: 20),
                              headlineWithContent(
                                "1. What is Bigtv News Network",
                                "Bigtv News Network is the easiest way to publish articles on Bigtv News app if you have a zeal to write and make some earnings additionally. Network by Bigtv News is an easy citizen powered, content publishing option to reach millions of readers and monetize content.",
                              ),
                              headlineWithContent(
                                "2. Why contribute to us?",
                                "Bigtv News assures your content reaches to the right audience. A very unique and classy reading experience has enabled us to engage millions of active readers who are constantly consuming interesting content just like yours. Various categories and proper localization helped us to connect vernacular readers with diverse tastes and preferences. We want you to have a great experience when using Bigtv News. We are a small team working extremely hard on a mission to build great vernacular content for India and also power every locality, by building a 'civic Reporting' community.",
                              ),
                              headlineWithContent(
                                "3. Registration",
                                "You need to register as a contributor on Bigtv News Network to publish your articles and videos so that the content can reach millions of readers on the Bigtv News App. We are open to common people, writers, and bloggers who want to write, gain weight, and make some earnings.",
                              ),
                              headlineWithContent(
                                "4. Note",
                                "Name should be as per your photo ID. Do not use fake, alias, celebrity, or corporate names of any person or entity.",
                              ),
                              headlineWithContent(
                                "5. Content Policy",
                                "Bigtv News Network provides a platform for people to put their views as well as news for the audience. In order to ensure a good experience for both contributors and writers, read our content policy carefully.",
                              ),
                              headlineWithContent(
                                "6. Title",
                                "No wrong usage of punctuation. The title should be related to the story and informative. It should not be less than 20 characters.",
                              ),
                              headlineWithContent(
                                "7. Content",
                                "Minimum 200 characters and a maximum of 400. Only relevant content/news needs to be submitted. Outdated and fake news will lead to escalations on the contributor. Content that is obscene in any form (text, image, or video) will not be accepted. No sensitive content or content that creates visual discomfort will be published. Religiously provoking, criminal, and sensitive content is strictly prohibited. Content should be original and should not be the property of any person or entity.",
                              ),
                              headlineWithContent(
                                "8. Quality of the article",
                                "Articles should be complete and should have the elements of What, Why, Where, Who, When, and How. The image should be clear and of decent visual quality. The story should be understandable and error-free with no biased or plagiarized content.",
                              ),
                              headlineWithContent(
                                "9. Copy Rights",
                                "Images play a vital role in enhancing your articles. Ensure all images are relevant, high-quality, and appropriately credited. Avoid using copyrighted material without permission. With strong checks in place, there is no scope for plagiarized content. Contributors will face escalations if observed doing any practices of this sort. Unauthorized use of images, videos, or articles is prohibited. Unauthorized use of corporate names, logos, or titles should be strictly avoided. Unauthorized use of personal fame, image, or privacy will lead to legal escalations.",
                              ),
                              headlineWithContent(
                                "10. Image",
                                "Image should be relevant to content only. Multiple images cannot be sent. No sensitive or sexually explicit images.",
                              ),
                              headlineWithContent(
                                "11. Video",
                                "Video should be relevant to content only. Shaky and amateur videos will not be accepted. No sensitive or sexually explicit videos.",
                              ),
                              headlineWithContent(
                                "12. Advertising & promotion",
                                "No links or landing pages will be accepted. Ads and promotional posts will not be accepted. No content will be promoted on our app. Content on how to buy/sell products or make easy money is prohibited. Content containing any kind of job offers or self-promotions is restricted.",
                              ),
                              headlineWithContent(
                                "13. Terms",
                                "Bigtv News reserves the right to remove any content that it feels is not relevant on the platform without any prior notice. Please go through the revenue model carefully to understand all financial terms. Signing up on Bigtv News Network allows Bigtv News to use your content on its app. Our app may transmit your personal information to our internal servers, which may be situated outside India. This personal information is deleted from our servers 180 days after you delete the app or cancel/terminate your user account on the app, except to the extent storage of such data, including your personal information, is necessary for our purposes and/or required under applicable laws.",
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

  Widget headlineWithContent(String headline, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
