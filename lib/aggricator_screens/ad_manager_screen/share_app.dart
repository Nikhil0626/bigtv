

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class ShareYourApp extends StatelessWidget {
  const ShareYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Card(
        color: AppColors.adsBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Are you liking our app?',
                    textAlign: TextAlign.center,
                    style: newAppFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                height(height: 4),
                Text(
                  "Share the ChotaNewsApp_\nStay updated,with your \n friends & family!",
                  style: newAppFont(fontSize: 14, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                height(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Share.share("Check out this app: https://play.google.com/store/apps/details?id=com.chotanews");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Share App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}