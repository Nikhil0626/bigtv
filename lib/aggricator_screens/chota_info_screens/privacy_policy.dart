import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../globel_keys/global_variables_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../events_data/event_repo.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  @override
  void initState() {
    context.read<AuthenticationProvider>().sendEvent("PrivacyPage");
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
              Icons.arrow_back_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
             width(width: 1),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Privacy Policy",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionContent("Please carefully read our privacy policies. This provides important details on Your rights and obligations. The data collection, use, storage, and disclosure procedures for the desktop and mobile apps of ChotaNews are described in this privacy statement (hereafter referred to as You, Your, or User). This privacy statement applies to the ChotaNews mobile application (hereinafter referred to as (App), which is owned by ChotaNews Private Limited. By downloading, installing, or using this App, you consent to the use of Your personal information as stated in this privacy notice. By downloading, installing, using, or creating a ChotaNews profile, you consent to the collection, transfer, storage, disclosure, and other uses of Your information as outlined in this Privacy Policy.\n "),
              height(height: 10),
               Text(
                  "This privacy notice does not cover any websites, services, applications, or businesses provided by "
                  "third parties that ChotaNews does not own, control, or have any influence over Third Party Services."
                  " ChotaNews explicitly disclaims liability for any privacy policies or data collection procedures used by"
                  " third-party services",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "If you don't agree with any of the terms and conditions of the App, you shouldn't download, install, or use it. "
                  "ChotaNews has the right to make changes at any moment and without prior notice. By downloading, installing, and/or using this programme, "
                  "you consent to be governed by any such revisions, additions, amendments, or modifications.",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text("Information the user provides to ChotaNews:",style: fontStyle(fontSize: 14),),
              height(height: 5),
               Text("Information That Identifies Any Individual ",style: fontStyle(fontSize: 14),),
              height(height: 10),
              Text(
                  "Email: Only user identification and authentication are done using the information. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "Information that is not specific to any one individual ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "We collect data about the user in order to uniquely validate and authenticate the device. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
              Text(
                  "To keep the user's selected images, videos, and offline news, the software needs access to the device's storage. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "The programme delivers news and content to users in accordance with their consent and in accordance with their location. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text("What makes use of the data that ChotaNews gathers? ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "ChotaNews may collect and use your personal information for the following purposes:",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "When you login to the App, we recognise you using your email address. Based on the content and personally identifiable information pertaining to You, ChotaNews may be able to control Your access to and use of the App, communicate with the User, customise Your experience using the "
                  "App, and/or the content of any email newsletter or other components that ChotaNews may occasionally send to You. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "Your email address will be used to send you user information, administrative updates, changes to your account setup, and other App-related information, as well as to keep you informed of any changes to ChotaNews policies. "
                  "In addition to this, you will occasionally receive emails with information about the firm, relevant products or services, etc. Additionally, email addresses could be utilised to react to any requests you make via queries or other forms of communication. ChotaNews has given comprehensive unsubscribe instructions at the bottom of each email in case You ever wish to stop receiving future newsletters.  To prevent or stop acts that are against the ChotaNews "
                  "User Agreement, Terms and Conditions, and other relevant laws, ChotaNews may utilise the personal information given by the User. How ChotaNews protects user data ",style: fontStyle(fontSize: 14),),
              height(height: 10),
               Text(
                  "ChotaNews adheres to the necessary data collection, storage, and processing policies and security measures to guard against unauthorised access, alteration, disclosure, or destruction of Your personal information, login, password, and data stored on the App. ChotaNews is "
                  "unable to guarantee the security of any information obtained by unauthorised access, use,"
                  " hardware or software failures, or other situations that might, at any time, damage the privacy of "
                  "users' personal information. In order to prevent unauthorised access to his or her account and personal"
                  " information, the User must set access restrictions on his or her device. ",style: fontStyle(fontSize: 14),),

              // Section 2: Data Collection
              sectionTitle("Sharing identity and security details ",),
              sectionContent(
                  "Except as indicated in this Policy, ChotaNews does not transfer, sell, or rent Your personally identifiable "
                  "information to outsiders. "
                  "For the aforementioned reasons, ChotaNews may divulge generic aggregated demographic data about its users"
                  " and visitors to its business partners, "
                  "dependable affiliates, and advertisers. This data will not include any personally identifying information."
                  ),
              height(height: 10),
              Text(
                  "ChotaNews sometimes could be required by law or litigation to divulge personal information about users. ChotaNews may also "
                      "provide information on the user if it determines that doing so is necessary for reasons of law enforcement,"
                      " national security, or other causes of public importance.",style: fontStyle(fontSize: 14),),
              height(height: 10),
              Text(
                  "ChotaNews retains the right to transfer users' personal information to a third party in the case of a merger, "
                  "acquisition, or sale of all or a portion of the company's assets. ",style: fontStyle(fontSize: 14),),
              height(height: 10),
              Text(
                  "Users Have Options Regarding How Their Information Is Used If you are a user who occasionally receives such emails, you have the option to quitof receiving marketing or promotional emails from ChotaNews by following the instructions in such emails. ChotaNews may nevertheless send the user emails pertaining to his or her"
                  " account or any continuing business connections even if they are not promotional emails. ",style: fontStyle(fontSize: 14),),

              // Section 3: How We Use Your Data
              sectionTitle("Modifications to this Terms Of service ",),
              sectionContent(
                  "This Privacy Policy could be revised and updated from time to time by ChotaNews. The updated Privacy Policy will be made available here, at "
                  "https://www.chotanews.com/privacy-policy.php, as a notification. It is advised that you often visit this page to learn about updates to the Privacy Policy. "
                  "You acknowledge and agree that it is Your responsibility to frequently review this Privacy Policy and keep up with any updates. "
                  "If you object to any updates to the Privacy Policy, you must not use or access the App. If you use the App following the posting of the modified Policy, "
                  "you will be assumed to have accepted and acknowledged the changes."),

              // Section 4: Data Sharing and Disclosure
              sectionTitle("Your Assent to These Privacy Terms "),
              sectionContent(
                  "You confirm that you have read and agree to the Privacy Policy by using this App. "
                  "You are not allowed to use or access this application if you disagree with our privacy policy. "
                  "If this Privacy Policy is revised and you continue to use the App, it will be considered that you agree to the revised policy."),


              height(height: 20),
              Text(
                "Contact Details",
                style: fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "For any support/feedback queries,please write to",
                email: " info@chotanews.com",
                onEmailTap: () => _launchEmail("info@chotanews.com"),
              ),
              height(height: 10),
              ContactDetailTile(
                title: "For advertising/partnership enquiries, please write to",
                email: " advertising@chotanews.com",
                onEmailTap: () =>
                    _launchEmail("advertising@chotanews.com"),
              ),
              height(height: 10),
              ContactDetailTile(
                title:
                    "For any complaints,queries, or grievances, please write to",
                email: " grievance@chotanews.com",
                onEmailTap: () => _launchEmail("grievance@chotanews.com"),
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
          fontSize: 16,
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

class ContactDetailTile extends StatelessWidget {
  final String title;
  final String email;
  final VoidCallback onEmailTap;

  const ContactDetailTile({
    Key? key,
    required this.title,
    required this.email,
    required this.onEmailTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: fontStyle(fontSize: 14)),
        InkWell(
          onTap: onEmailTap,
          child: Text(
            email,
            style: fontStyle(fontSize: 14, color: Colors.blue),
          ),
        ),
        height(height: 10),
      ],
    );

  }
}