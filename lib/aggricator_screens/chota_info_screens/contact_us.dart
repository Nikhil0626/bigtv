import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../events_data/event_repo.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  // Function to launch email
  // Future<void> _launchEmail(String email) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email,
  //   );
  //   print("emailUri");
  //   try {
  //     if (await canLaunch(emailUri.toString())) {
  //       await launch(emailUri.toString());
  //     } else {
  //       throw 'Could not launch email: $email';
  //     }
  //   } catch (e) {
  //     print('Error launching email: $e');
  //   }
  // }
  // Future<void> launchSingleEmail() async {
  //   final Email email = Email(
  //     to: ['siva143145@gmail.com'], // Change this to the recipient email
  //     subject: 'Hello from Flutter!',
  //     body: 'This is a test email sent from my Flutter app.',
  //   );
  //
  //   await EmailLauncher.launch(email);
  // }
  Future<void> launchSingleEmail(email) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("loginId")??"";

    contactViaMail();
    await EasyLauncher.email(
        email: email,
        subject: "",
        body: "");
  }

  Future<void> _launchPhone(String phone) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("loginId")??"";

    contactViaCall();
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
  void initState() {
  context.read<AuthenticationProvider>().sendEvent("ContactPage");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Contact Us",
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
              Center(
                child: Column(
                  children: <Widget>[
                    height(height: 10),
                    Text(
                      "Chota News",
                      style: fontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    height(height: 10),
                    InkWell(
                      onTap: () => launchSingleEmail('info@chotanews.com'),
                      child: Text(
                        "info@chotanews.com",
                        style: fontStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
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
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: fontStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          const WidgetSpan(
            child: SizedBox(height: 5),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: onEmailTap,
              child: Text(
                textAlign: TextAlign.center,
                email,
                style: fontStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ),
          const WidgetSpan(
            child: SizedBox(height: 10),
          ),
        ],
      ),
    );

  }
}
