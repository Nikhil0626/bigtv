import 'package:flutter/material.dart';

const String poppins = "Roboto";

TextStyle fontStyle(
    {Color? color = Colors.black,
    double? fontSize = 14,
    FontWeight? fontWeight = FontWeight.w400}) {
  return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: poppins);
}
