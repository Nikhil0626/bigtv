import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class BottomActions extends StatelessWidget {
  final String icon;
  final String label;
  final onTap;

  const BottomActions(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(icon,
                height: 20,
                width: 20,
                color: Colors.grey[600]
            ),
            height(height: 4),
            Text(
              label,
              style: fontStyle(fontSize: 14,
                  color: Colors.grey[600]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
