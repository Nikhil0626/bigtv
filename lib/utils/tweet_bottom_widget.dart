import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_spaces.dart';

class TweetBottomWidget extends StatelessWidget {
  final icon;
  final String count;

  const TweetBottomWidget(
      {super.key, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon,height: 14,width: 14,color: const Color(0xff6b7280),),
        width(width: 5),
        Text(
          count,
          textAlign: TextAlign.center,
          style: fontStyle(fontSize: 12, color: AppColors.headerTextColor,fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}