import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle fontStyle(
    {Color? color = Colors.black,
    double? fontSize = 14,
    FontWeight? fontWeight = FontWeight.normal}) {
  return GoogleFonts.mandali(
      textStyle: TextStyle(
    height: 1.6,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  ));
}
