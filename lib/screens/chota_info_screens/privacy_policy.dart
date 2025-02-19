import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();


}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  Future<void> launchSingleEmail(email) async {
    await EasyLauncher.email(
        email: email,
        subject: "",
        body: "");
  }
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunch(phoneUri.toString())) {
        await launch(phoneUri.toString());
      } else {
        throw 'Could not launch phone: $phone';
      }
    } catch (e) {
      print('Error launching phone: $e');
    }
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
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Privacy Policy",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(height: 16),

              // Section 1: Introduction
              sectionTitle("Smart News, Tailored for You"),
              sectionContent(
                "Please read this Privacy Policy very carefully. This contains important information about Your rights and obligations. This Privacy Policy sets out the manner in which ChotaNews collects, uses, maintains and discloses information collected from the users of our mobile or desktop application (hereinafter referred to as 'You', 'Your', 'User'). This Privacy Policy applies to the ChotaNews mobile, technology (hereinafter referred as App) which is owned by ChotaNews Private Limited By downloading, installing or using this App, you are consenting to the use of your personal information in the manner set out in this Privacy policy. By downloading, installing or using this App or by registering your profile with ChotaNews you are consenting to the collection, transfer, storage, disclosure and other uses of Your information as set out in this Privacy Policy. This Privacy Policy does not apply to the practices of third parties that ChotaNews does not own, control, or manage including but not limited to any third-party websites, services, applications, or businesses (Third Party Services). ChotaNews does not take responsibility for the content or privacy policies of those Third-Party services.\n If you do not agree to any of the provisions of this Privacy Policy, you should not download, install and use the App. ChotaNews may revise, alter, add, amend or modify this Privacy Policy at any time by updating this page. By downloading, installing and/or using this App, you agree to be bound by any such alteration, amendment, addition or modification.",
              ),

              // Section 2: Data Collection
              sectionTitle("Information ChotaNews collects from you:"),
              sectionContent(
                "1. Personally Identifiable Information:\n\n Email: The data is solely for your authentication and identification.\n\n 2. Non-personally Identifiable Information \n\n• When you want to comment on a post, you have to share Email ID with consent. This is to moderate the comments section and ensure it is kept user-friendly. \n\n• Under ‘User Generated Content category’ you can submit news articles. Our team curates & publishes the articles post fact-checking. While submitting the article you have to share Email ID & Mobile No. This will help us identify the veracity of the posts and to establish contact. \n\n• We collect the information from you to verify and authenticate the device uniquely \n\n• The application needs access to device storage in order to save the pictures, videos & offline news you are interested in \n\n• The application serves news and content to the users based on their location and hence the permission"


              ),

              // Section 3: How We Use Your Data
              sectionTitle("How ChotaNews uses the collected Information?"),
              sectionContent(
                "ChotaNews may collect and use your personal information for the following purposes:\n\n"
                "• Your email address is used to identify You while logging into the App. ChotaNews may use this information to control your access to the App as well as use of the App, to communicate with you, customize your experience of using the App and/or the content of any email newsletter or other material that ChotaNews may send to the you from time to time and provide information that may be useful or interesting based on the content and personally identifiable information relating to you.\n\n"
                "• Your email address will be used to send user information, administrative information, changes in account settings and any changes to the App or updating you on new policies of ChotaNews. Apart from this you will receive periodic emails that may relate to company news, related product or service information, etc. Email address may also be used for responding to any of the inquiries, questions, and/or any other requests made by you. If at any time You want to unsubscribe from receiving future emails, ChotaNews has included detailed unsubscribe instructions at the bottom of each email.\n\n"
                "• ChotaNews may use the personal information provided by you to prevent or take action against activities that are, or may be, in breach of the ChotaNews User Agreement, Terms and Conditions and any applicable laws.\n\n"
              ),

              // Section 4: Data Sharing and Disclosure
              sectionTitle("Choices you have about the Use of your Information"),
              sectionContent(
                "In case, if you are receiving marketing or promotional emails from ChotaNews, you can opt out of such emails by following the instructions in those mails. If the you opt out, then you may still receive non-promotional emails from ChotaNews, such as emails about your account or any ongoing business relations entered into by ChotaNews."

              ),

              // Section 5: Data Security
              sectionTitle("Changes to this Privacy Policy"),
              sectionContent(
                "ChotaNews may update and revise this Privacy Policy from time to time. The revised Privacy Policy will be posted as notification here on this link http://ChotaNewsapp.com/privacy-policy.php. You are encouraged to periodically check this page to stay informed about changes to this Privacy Policy. You hereby acknowledge and agree that it is your responsibility to review this Privacy Policy periodically and become aware of the modifications. If You disagree to any of the changes to the Privacy Policy, you shall refrain from using or accessing the App. Your continued use of the App following the posting of the revised Policy shall indicate your acceptance and acknowledgement of the changes and you will be bound by it."
                ),

              // Section 6: Your Rights
              sectionTitle("Your Acceptance of this Privacy Policy"),
              sectionContent(
                "By using this App, you are signifying your acceptance of this Privacy Policy. If you do not agree to this Privacy Policy, you shall not access or use this App. Your continued access or use of the App following the posting of changes to this Privacy Policy will be deemed to be the acceptance of these changes by the user."

              ),

              height(height: 20),
              Text(
                "Contact Details",
                style: fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "For any support/feedback queries,please write to",
                email: " info@chotanews.com",
                onEmailTap: () => launchSingleEmail("info@chotanews.com"),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "For advertising/partnership enquiries, please write to",
                email: " advertising@chotanews.com",
                onEmailTap: () => launchSingleEmail("advertising@chotanews.com"),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "For any complaints,queries, or grievances, please write to",
                email: " grievance@chotanews.com",
                onEmailTap: () => launchSingleEmail("grievance@chotanews.com"),
              ),
              height(height: 20),
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 14),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "Phone: ",
                email: "+91 9440913555",
                onEmailTap: () => _launchPhone("+91 9440913555"),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
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
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: fontStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
