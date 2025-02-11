
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final FontStyle? fontStyle;
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
    this.fontStyle,
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
          child: Text(text,),
        ),
      ),
    );
  }
}
