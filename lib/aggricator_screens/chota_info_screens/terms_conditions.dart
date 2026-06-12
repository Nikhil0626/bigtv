import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 1),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
             width(width: 2),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Terms and conditions",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.only(bottom: 16.0+ MediaQuery.of(context).padding.bottom,right: 16,top: 16,left: 16),
        child: ListView(
          children: [
             Text(style: fontStyle(fontSize: 14,fontWeight: FontWeight.normal),
              "Bigtv News Network is a perfect platform for citizens"
               " to report news and make your content reach millions"
               " of users every day. The whole idea is to empower the"
               " audience with vivid categories and local happenings"
               " before any other medium, making them stay ahead of the"
               " rest"
            ),
            height(height: 5),
            headlineWithContent(
                "1. What is Bigtv News Network",
                    "Bigtv News Network is the easiest way to publish"
                    " articles on Bigtv News app if you have a zeal to"
                    " write and make some earnings additionally. Network"
                    " by Bigtv News is an easy citizen powered, content"
                " publishing option to reach millions of readers and "
                "monetize content."


                ),
            headlineWithContent(
                "2. Why contribute to us?",
                "Bigtv News assures your content reaches to the right audience. "
                    "A very unique and classy reading experience has enabled us to engage millions of active readers who are constantly consuming interesting content just like yours. "
                    "Various categories and proper localization helped us to connect vernacular readers with diverse tastes and preferences. "
                    "We want you to have a great experience when using Bigtv News. "
                    "We are a small team working extremely hard on a mission to build great vernacular content for India and also power every "
                    "locality, "
                    "by building a 'civic Reporting' community. "

                   ),
            headlineWithContent(
                "3. Registration",

                    "You need to register as a contributor on Bigtv News Network to publish your articles and videos so that the content can reach millions of readers on the Bigtv News App. "
                    "We are open to common people, writers, and bloggers who want to write, gain weight, and make some earnings. "
                  ),
            headlineWithContent(
                "4. Note",

                    "Name should be as per your photo ID. Do not use fake, alias, celebrity, or corporate names of any person or entity."),
            headlineWithContent(
                "5. Content Policy",

                    "Bigtv News Network provides a platform for people to put their views as well as news for the audience. "
                    "In order to ensure a good experience for both contributors and writers, read our content policy carefully."),
            headlineWithContent(
                "6. Title",

                    "No wrong usage of punctuation. "
                    "The title should be related to the story and informative. "
                    "It should not be less than 20 characters."),

            headlineWithContent(
                "7. Content",
                    "Minimum 200 characters and a maximum of 400. "
                    "Only relevant content/news needs to be submitted. Outdated and fake news will lead to escalations on the contributor. "
                    "Content that is obscene in any form (text, image, or video) will not be accepted. "
                    "No sensitive content or content that creates visual discomfort will be published. "
                    "Religiously provoking, criminal, and sensitive content is strictly prohibited. "
                    "Content should be original and should not be the property of any person or entity."),
        headlineWithContent(
            "8. Quality of the article",
                 "Articles should be complete and should have the elements of What, Why, Where, Who, When, and How. "
                "The image should be clear and of decent visual quality. "
                 "The story should be understandable and error-free with no biased or plagiarized content."
        ),

        headlineWithContent(
            "9. Copy Rights",
            "Images play a vital role in enhancing your articles. Ensure all images are relevant, high-quality, and appropriately credited. "
                "Avoid using copyrighted material without permission. "
                "With strong checks in place, there is no scope for plagiarized content. Contributors will face escalations if observed doing any practices of this sort. "
                "Unauthorized use of images, videos, or articles is prohibited. "
                "Unauthorized use of corporate names, logos, or titles should be strictly avoided. "
                "Unauthorized use of personal fame, image, or privacy will lead to legal escalations."
        ),


        headlineWithContent(
                "10. Image",
                "Image should be relevant to content only. Multiple images cannot be sent. No sensitive or sexually explicit images . "
                    ),
            headlineWithContent(
                "11. Video",
                "Video should be relevant to content only. Shaky and amateur videos will not be accepted. "
                    "No sensitive or sexually explicit videos. "

                    ""),
            headlineWithContent(
                "12. Advertising & promotion",
                "No links or landing pages will be accepted. "
                    "Ads and promotional posts will not be accepted. "
                    "No content will be promoted on our app. "
                    "Content on how to buy/sell products or make easy money is prohibited. "
                    "Content containing any kind of job offers or self-promotions is restricted."),
            headlineWithContent(
                "13. Terms",
                "Bigtv News reserves the right to remove any content that it feels is not relevant on the platform without any prior notice. "
                    "Please go through the revenue model carefully to understand all financial terms. "
                    "Signing up on Bigtv News Network allows Bigtv News to use your content on its app. "
                    "Our app may transmit your personal information to our internal servers, which may be situated outside India. "
                    "This personal information is deleted from our servers 180 days after you delete the app or cancel/terminate your user account on the app, "
                    "except to the extent storage of such data, including your personal information, is necessary for our purposes and/or required under applicable laws."),
          ],
        ),
      ),
    );
  }

  Widget headlineWithContent(String headline, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        height(height: 8),
        Text(
          content,
          style: fontStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        height(height: 16),
      ],
    );
  }
}
