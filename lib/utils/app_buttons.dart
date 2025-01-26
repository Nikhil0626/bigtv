
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? shape;
  final double? elevation;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const CommonButton({
    Key? key,
    required this.text,
    this.textStyle,
    this.onPressed,
    this.backgroundColor,
    this.disabledColor,
    this.textColor,
    this.padding,
    this.shape,
    this.elevation,
    this.leadingIcon,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,

      child: Container(
        width: MediaQuery.of(context).size.width-50,
        height: 40,
        decoration: shape,

        child: Center(
          child: Text(text,style: fontStyle(color: textColor,fontSize: 16,fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}
