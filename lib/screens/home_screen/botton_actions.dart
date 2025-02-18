import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';

class BottomActions extends StatelessWidget {
  final String icon;
  final String label;
  final  iconColor;
  final String postType;
  final bool isLike;
  final onTap;
  final Widget? iconWidget;

  const BottomActions(
      {super.key,
      required this.icon,
      required this.label,
      required this.postType,
       this.isLike=false,
       this.iconColor=Colors.grey,
        this.iconWidget = null,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlipProvider>(
      builder: (_,flipProvider,__) {
        return InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                height(height: 2),
                if(label == "లైక్")
                  SvgPicture.asset(icon,
                      height: 20,
                      width: 20,
                      color: isLike ?Colors.green:postType=="BigBlackStandard"?Colors.white:iconColor
                  ),

                if(label != "లైక్")
                SvgPicture.asset(icon,
                    height: 20,
                    width: 20,
                    color: postType=="BigBlackStandard"?Colors.white:iconColor
                ),
                height(height: 4),
                Text(
                  label,
                  style: fontStyle(fontSize: 14,
                      color: postType=="BigBlackStandard"?Colors.white:iconColor
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
