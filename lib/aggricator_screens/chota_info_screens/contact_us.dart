import 'dart:developer';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Future<void> launchSingleEmail(String email) async {
    contactViaMail();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      log('Error launching email: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    contactViaCall();
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        log('Could not launch phone: $phone');
      }
    } catch (e) {
      log('Error launching phone: $e');
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
            width(width: 4),
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
        padding: EdgeInsets.only(bottom: 16.0 + MediaQuery.of(context).padding.bottom, right: 16, top: 16, left: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    height(height: 10),
                    Text(
                      "Bigtv News",
                      style: fontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                email: "+91 81210 31061",
                onEmailTap: () => _launchPhone("+91 81210 31061"),
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
    super.key,
    required this.title,
    required this.email,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: fontStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          WidgetSpan(
            child: height(height: 5),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: onEmailTap,
              child: Text(
                email,
                textAlign: TextAlign.center,
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
