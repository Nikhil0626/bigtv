import 'package:flutter/material.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'chota_info.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context,);
          },
        ),
        title: Text("Terms and Conditions", style: fontStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            headlineWithContent(
                "1. What is Chote News Network Program",
                "The Chote News Network Program is a platform dedicated to providing users with reliable, well-curated news and updates. It aims to empower contributors by allowing them to share verified and impactful stories that resonate with the audience."
            ),
            headlineWithContent(
                "2. Why contribute to us?",
                "By contributing to the Chote News Network, you become part of a community focused on spreading accurate, meaningful, and diverse perspectives. Your contributions can help inform and inspire millions while offering a platform to showcase your expertise."
            ),
            headlineWithContent(
                "3. Registration",
                "Becoming a contributor is simple. Sign up by providing your details, agree to the terms, and start submitting content. Once registered, you gain access to tools and resources to enhance the quality of your submissions."
            ),
            headlineWithContent(
                "4. Note",
                "Contributions must comply with platform guidelines. Ensure that your submissions are original, factual, and relevant to the target audience. The Chote News Network values authenticity above all else."
            ),
            headlineWithContent(
                "5. Content Policy",
                "All content submitted to the platform must adhere to our content policy. It should be free from plagiarism, biased opinions, and any material that could mislead or harm the community."
            ),
            headlineWithContent(
                "6. Title",
                "The title of your article must be clear, concise, and engaging. It serves as the gateway to attract readers' attention and should summarize the article effectively."
            ),
            headlineWithContent(
                "7. Content",
                "The content of your submission should be well-researched, informative, and written in a way that captivates readers. Quality is the cornerstone of our platform's credibility."
            ),
            headlineWithContent(
                "8. Quality of the article",
                "Articles should maintain high standards of writing, including proper grammar, structure, and factual accuracy. Submissions undergo a review process to ensure quality before publication."
            ),
            headlineWithContent(
                "9. Image",
                "Images play a vital role in enhancing your articles. Ensure all images are relevant, high-quality, and appropriately credited. Avoid using copyrighted material without permission."
            ),
            headlineWithContent(
                "10. Video",
                "Video content should complement your articles, providing additional depth and engagement. Like images, videos must be of high quality and free from copyright violations."
            ),
            headlineWithContent(
                "11. Advertising & Promotions",
                "Advertising and promotional content should align with the platform's values and policies. Ensure that such material does not overshadow the core message of your article."
            ),
            headlineWithContent(
                "12. Terms",
                "By using the Chote News Network, you agree to adhere to the terms and conditions. These guidelines ensure a safe, productive, and reliable platform for all users."
            ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
