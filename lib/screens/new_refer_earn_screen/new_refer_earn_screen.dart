import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_fonts.dart';
import 'package:fl_qr_generation/src/fl_qr_generation.dart';

class NewReferEarnScreen extends StatefulWidget {
  final String shortLink;
  final String getCode;
  const NewReferEarnScreen({super.key, required this.shortLink, required this.getCode});

  @override
  State<NewReferEarnScreen> createState() => _NewReferEarnScreenState();
}

class _NewReferEarnScreenState extends State<NewReferEarnScreen> {
  // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // String code = await sharedPreferences.getString("sharedReferralCode")??"";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            width(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Refer & Earn",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Referral Code",
                style: fontStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(10),
              padding: EdgeInsets.all(12),
              color: Colors.lightBlue,
              strokeWidth: 1,
              dashPattern: [10, 6],
              child: SizedBox(
                width: 200,
                child: Column(
                  children: [
                QRGenerator.generate(
                link:widget.shortLink,
                  foregroundColor: Colors.black,

                  backgroundColor: Colors.white,
                ),
                    height(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                           widget.getCode,
                          style: fontStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        width(width: 8),
                        Container(
                          width: 1,
                          height: 18,
                          color: Colors.black,
                        ),
                        width(width: 8),
                        InkWell(
                            onTap: (){
                              Share.share('${widget.shortLink}');
                            },
                            child: const Icon(Icons.share, color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            height(height: 20),
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Refer Friends and win an iphone",
                style: fontStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            height(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:  Image.asset(
                "assets/svg/apple_banner.gif",
                height: 335,
                width: 335,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
