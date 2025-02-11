import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


TextStyle fontStyle(
    {Color? color = Colors.black,
      double? fontSize = 14,
      FontWeight? fontWeight = FontWeight.normal}) {
  return
    GoogleFonts.poppins(
  textStyle: TextStyle(
  fontSize: fontSize ,
  fontWeight: fontWeight,
  color: color,)
  );
}