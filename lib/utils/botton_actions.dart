import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BottomActions extends StatelessWidget {
  final String icon;
  final String label;
  final iconColor;
  final String postType;
  final bool isLike;
  final onTap;
  final Widget? iconWidget;

  const BottomActions({super.key, required this.icon, required this.label, required this.postType, this.isLike = false, this.iconColor = Colors.grey, this.iconWidget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      return InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          child: label == "లైక్"
              ? SvgPicture.asset(icon, height: 20, width: 20, color: isLike ? Colors.lightBlue : iconColor)
              : label != "లైక్"
                  ? SvgPicture.asset(icon, height: 20, width: 20, color: iconColor)
                  : SizedBox.shrink(),
        ),
      );
    });
  }
}
