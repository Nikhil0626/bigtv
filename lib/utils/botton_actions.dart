import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BottomActions extends StatelessWidget {
  final String icon;
  final String label;
  final dynamic iconColor;
  final String postType;
  final bool isLike;
  final dynamic onTap;
  final Widget? iconWidget;
  final double iconSize;

  const BottomActions({
    super.key,
    required this.icon,
    required this.label,
    required this.postType,
    this.isLike = false,
    this.iconColor = AppColorTokens.primaryRed,
    this.iconWidget,
    this.iconSize = 20,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      final Color colorToUse = iconColor is Color ? iconColor : AppColorTokens.primaryRed;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: iconWidget ??
              SvgPicture.asset(
                icon,
                height: iconSize,
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  isLike ? AppColorTokens.primaryRed : colorToUse,
                  BlendMode.srcIn,
                ),
              ),
        ),
      );
    });
  }
}
