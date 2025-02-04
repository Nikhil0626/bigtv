import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
import 'package:flutter/material.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
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
                  children: [
                    SizedBox(height: 10),
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
                "Chota News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                style: fontStyle(fontSize: 16),
                textAlign: TextAlign.justify,
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

class ContactDetailTile extends StatelessWidget {
  final String title;
  final String email;

  ContactDetailTile({required this.title, required this.email});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: fontStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        email,
        style: fontStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: AboutUs(),
      theme: ThemeData(primarySwatch: Colors.blue),
    ));
