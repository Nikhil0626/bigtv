import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../utils/app_fonts.dart';

class NewReferEarnScreen extends StatefulWidget {
  const NewReferEarnScreen({super.key});

  @override
  State<NewReferEarnScreen> createState() => _NewReferEarnScreenState();
}

class _NewReferEarnScreenState extends State<NewReferEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "Refer & Earn",
          style: fontStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
              child: Container(
                width: 211,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/QRcode.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    height(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          "XBYAHSN",
                          style: fontStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        width(width: 8),
                        Container(
                          width: 1,
                          height: 18,
                          color: Colors.black,
                        ),
                        width(width: 8),
                        const Icon(Icons.share, color: Colors.black),
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
              child: Image.asset(
                'assets/images/iphone_gift.png',
                height: 335,
                width: 335,
                fit: BoxFit.cover,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
