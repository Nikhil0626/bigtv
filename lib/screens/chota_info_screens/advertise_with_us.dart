import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import 'about_us.dart';
import 'chota_info.dart';

class AdvertiseWithUs extends StatefulWidget {
  const AdvertiseWithUs({super.key});

  @override
  State<AdvertiseWithUs> createState() => _AdvertiseWithUsState();
}

class _AdvertiseWithUsState extends State<AdvertiseWithUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Advertise with Us",
          style: fontStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context, ChotaInfo);
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
              SizedBox(height: 16),

              Text(
                "Chota News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                style: fontStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16),

              Text(
                "Get In Touch",
                style: fontStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              SizedBox(height: 10),

              // Support/Feedback Text
              Text(
                "For support/feedback queries, please write to ",
                style: fontStyle(fontSize: 15),
              ),
              Text(
                "info@chotanews.com",
                style: fontStyle(color: Colors.lightBlue),
              ),
              SizedBox(height: 20),

              // Address Section
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Address Details
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 16),
              ),
              SizedBox(height: 10),

              // Phone Number
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
