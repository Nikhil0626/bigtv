import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

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
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "Advertise with Us",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 18,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    height(height: 10),
                    InkWell(
                      onTap: () => launchSingleEmail('info@gmail.com'),
                      child: Text(
                        "info@chotanews.com",
                        style: fontStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              height(height: 16),

              Text(
                "Chota News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                style: fontStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
              height(height: 14),

              Text(
                "Get In Touch",
                style: fontStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              height(height: 20),

              ContactDetailTile(
                title: "For Advertising / partnership enquires,  please write to ",
                email: " advertising@chotanews.com",
                onEmailTap: () => launchSingleEmail("advertising@chotanews.com"),
              ),
              height(height: 20),

              // Address Section
              Text(
                "Address",
                style: fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 10),

              // Address Details
              Text(
                "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                style: fontStyle(fontSize: 14),
              ),
              height(height: 10),

              InkWell(
                onTap: () => _launchPhone('+91 9440913555'),
                child: Text(
                  "Phone: +91 9440913555",
                  style: fontStyle(fontSize: 14),
                ),
              ),

            ],
          ),
        ),
      ),
    );
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
  Future<void> launchSingleEmail(email) async {
    await EasyLauncher.email(
        email: email,
        subject: "",
        body: "");
  }
}
