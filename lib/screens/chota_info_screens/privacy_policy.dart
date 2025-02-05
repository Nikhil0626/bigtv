import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'about_us.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title:  Text(
          "Privacy Policy",
          style: fontStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(height: 16),

              // Section 1: Introduction
              sectionTitle("Introduction"),
              sectionContent(
                "At Chote News Network, safeguarding your privacy is of utmost importance to us. "
                "This Privacy Policy explains how we collect, use, disclose, and protect your personal data when you interact with our platform. "
                "By accessing our services, you agree to the terms outlined in this policy. Please take a moment to review the details carefully.",
              ),

              // Section 2: Data Collection
              sectionTitle("Data Collection"),
              sectionContent(
                "We collect personal information, including but not limited to your name, email address, phone number, and location, to provide you with better service. "
                "Additional data may include usage statistics, device information, and cookies, which help us understand how you interact with our platform. "
                "Rest assured, we only collect information necessary for improving user experience and functionality.",
              ),

              // Section 3: How We Use Your Data
              sectionTitle("How We Use Your Data"),
              sectionContent(
                "Your data is utilized to enhance the services we provide, including:\n"
                "- Personalizing your experience on our platform.\n"
                "- Sending relevant updates, notifications, and promotional content.\n"
                "- Responding to your inquiries and providing customer support.\n"
                "- Monitoring and analyzing usage trends to improve functionality.",
              ),

              // Section 4: Data Sharing and Disclosure
              sectionTitle("Data Sharing and Disclosure"),
              sectionContent(
                "We do not sell, trade, or rent your personal information to third parties. "
                "However, we may share data with trusted service providers who assist us in delivering services, subject to strict confidentiality agreements. "
                "Data may also be disclosed when required by law or to protect our legal rights.",
              ),

              // Section 5: Data Security
              sectionTitle("Data Security"),
              sectionContent(
                "We implement industry-standard measures to protect your data, including encryption, secure servers, and regular system monitoring. "
                "While we strive to protect your personal information, no method of data transmission or storage is 100% secure. "
                "We encourage users to take precautions, such as using strong passwords and avoiding sharing sensitive information online.",
              ),

              // Section 6: Your Rights
              sectionTitle("Your Rights"),
              sectionContent(
                "As a user, you have the right to access, update, or delete your personal information at any time. "
                "You may also opt out of promotional communications or withdraw consent for specific data usage. "
                "For assistance, please contact our support team through the provided channels.",
              ),

              // Section 7: Updates to This Policy
              sectionTitle("Updates to This Policy"),
              sectionContent(
                "This Privacy Policy may be updated periodically to reflect changes in our practices, services, or regulatory requirements. "
                "We encourage you to review this policy regularly to stay informed. "
                "Your continued use of the platform indicates acceptance of any changes made to this policy.",
              ),

              // Section 8: Contact Us
              sectionTitle("Contact Us"),
              sectionContent(
                "If you have any questions or concerns about this Privacy Policy, please contact us at privacy@chotenewsnetwork.com. "
                "We value your trust and are committed to addressing your inquiries promptly and transparently.",
              ),

             height(height: 8),
              Text(
                "Contact Details",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
             height(height: 3),

              ContactDetailTile(
                title: "For support/feedback queries",
                email: "info@chotanews.com",
              ),
              ContactDetailTile(
                title: "For advertising/partnership enquiries",
                email: "advertising@chotanews.com",
              ),
              ContactDetailTile(
                title: "For complaints, queries, or grievances",
                email: "grievance@chotanews.com",
              ),

             height(height: 20),
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),

              // Address details
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Text(
        title,
        style: fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget sectionContent(String content) {
    return Padding(
      padding:  EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
