import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
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
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 2),
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
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Advertise with Us",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
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
              height(height: 16),

              Text(
                "Chota News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                style: fontStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              height(height: 16),

              Text(
                "Get In Touch",
                style: fontStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              height(height: 10),

              // Support/Feedback Text
              Text(
                "For support/feedback queries, please write to ",
                style: fontStyle(fontSize: 15),
              ),
              Text(
                "info@chotanews.com",
                style: fontStyle(color: Colors.lightBlue),
              ),
              height(height: 20),

              // Address Section
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),

              // Address Details
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 16),
              ),
              height(height: 10),

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
