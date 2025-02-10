import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class BottomActions extends StatelessWidget {
  final String icon;
  final String label;
  final bool isLike;
  final onTap;

  const BottomActions(
      {super.key,
      required this.icon,
      required this.label,
       this.isLike=false,
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
            height(height: 5),
            if(label == "లైక్")
              SvgPicture.asset(icon,
                  height: 20,
                  width: 20,
                  color: isLike ?Colors.green:Colors.grey[600]
              ),

            if(label != "లైక్")
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
