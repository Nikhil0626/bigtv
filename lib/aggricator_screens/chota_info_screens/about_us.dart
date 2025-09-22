import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'contact_us.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<AuthenticationProvider>().sendEvent("AdvertisePage");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
          style: fontStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: 16.0 + MediaQuery.of(context).padding.bottom,
          right: 16,
          top: 16,
          left: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
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
                      onTap: () => _launchEmail("info@chotanews.com"), // Updated
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
                "Chota News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                style: fontStyle(fontSize: 14),
                textAlign: TextAlign.justify,
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
                title: "For support/feedback queries",
                email: "info@chotanews.com",
                onEmailTap: () => _launchEmail("info@chotanews.com"), // Added tap behavior
              ),

              ContactDetailTile(
                title: "For advertising/partnership enquiries",
                email: "advertising@chotanews.com", 
                onEmailTap: () => _launchEmail("advertising@chotanews.com"),
              ),
              ContactDetailTile(
                title: "For complaints, queries, or grievances",
                email: "grievance@chotanews.com", 
                onEmailTap: () => _launchEmail("grievance@Chotanews.com"),
              ),
              height(height: 20),
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 14),
              ),
              height(height: 10),
              InkWell(
                onTap: () => _launchPhone("+918121031063"), // Updated
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Phone: ",
                        style: fontStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextSpan(
                        text: "+91 81210 31063",
                        style: fontStyle(fontSize: 16, color: Colors.lightBlue), // Light blue color for number
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Method to launch email
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  // Method to launch phone call
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }
}

