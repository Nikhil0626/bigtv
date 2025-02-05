import 'package:flutter/material.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'about_us.dart';
import 'chota_info.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contact Us",
          style: fontStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context, );
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    height(height: 10),
                    Text(
                      "info@chotanews.com",
                      style: fontStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              height(height: 20),
              Text(
                "Contact Details",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),
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
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 16),
              ),
              height(height: 10),
              Text(
                "Phone: +91 81210 31063",
                style: fontStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
