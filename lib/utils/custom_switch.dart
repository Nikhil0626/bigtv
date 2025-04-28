import 'dart:developer';

import 'package:chotanews/utils/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../aggricator_screens/home_screen/home_provider.dart';
import 'app_colors.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({super.key,});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return GestureDetector(
            onTap: () {
              homeProvider.switchChange(true);
              // Locale currentLocale = context.locale;
              // log("Current Locale: ${currentLocale.languageCode}");
              //
              // if (currentLocale.languageCode == 'en') {
              //   context.setLocale(Locale('te')); // Switch to Telugu
              // } else if (currentLocale.languageCode == 'te') {
              //   context.setLocale(Locale('hi')); // Switch to Hindi
              // } else {
              //   context.setLocale(Locale('en')); // Switch to English
              // }
              //
              // log("New Locale: ${context.locale.languageCode}");
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64, // Increased width for text
              height: 24, // Slightly larger height
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:AppColors.cardBackgroundColor,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Text inside the switch
                  Align(
                    alignment: !homeProvider.isSwitched ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left:  2, right:2),
                      child: Text(
                        !homeProvider.isSwitched ? "Swipe" : "Scroll",
                        style: fontStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: homeProvider.isSwitched ? 40 : 2, // Adjusted positions
                    top: 5,
                    child: Container(
                      width: 14, // Reduced size
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    );

  }
}
