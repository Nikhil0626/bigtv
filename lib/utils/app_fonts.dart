import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../globel_keys/globel_keys.dart';
import '../core/theme/theme_extensions.dart';

@Deprecated('Use context.typography from theme_extensions.dart instead.')
TextStyle homeScreenFontStyle(
    {Color? color,
      double? fontSize = 14,
      FontWeight? fontWeight = FontWeight.normal}) {
  
  final BuildContext? ctx = mainNavigatorKey.currentContext;
  final defaultColor = ctx?.textColor ?? Colors.black;

  return GoogleFonts.notoSansTelugu(
    textStyle: TextStyle(
      fontSize: fontSize,
      height: 1.4,
      wordSpacing: 2,
      fontWeight: fontWeight,
      color: color ?? defaultColor,
    )
  );
}

@Deprecated('Use context.typography from theme_extensions.dart instead.')
TextStyle fontStyle(
    {Color? color,
      double? fontSize = 14,
      FontWeight? fontWeight = FontWeight.normal}) {

  final BuildContext? ctx = mainNavigatorKey.currentContext;
  final defaultColor = ctx?.textColor ?? Colors.black;

  return GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? defaultColor,
    )
  );
}

@Deprecated('Use context.typography from theme_extensions.dart instead.')
TextStyle newAppFont(
    {Color? color,
      double? fontSize = 14,
      FontWeight? fontWeight = FontWeight.normal}) {

  final BuildContext? ctx = mainNavigatorKey.currentContext;
  final defaultColor = ctx?.textColor ?? Colors.black;

  return GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color ?? defaultColor,
    )
  );
}