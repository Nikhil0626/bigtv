import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


TextStyle homeScreenFontStyle(
    {Color? color = Colors.black,
      double? fontSize = 14,
      FontWeight? fontWeight = FontWeight.normal}) {
  return
    GoogleFonts.notoSansTelugu(
  textStyle: TextStyle(
  fontSize: fontSize ,
  height: 1.5,
  wordSpacing: 2,
  fontWeight: fontWeight,
  color: color,)
  );
}
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