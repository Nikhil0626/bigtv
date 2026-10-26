import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final _malayalamFallback = [
    if (GoogleFonts.notoSerifMalayalam().fontFamily != null)
      GoogleFonts.notoSerifMalayalam().fontFamily!,
  ];

  static TextTheme get textTheme {
    return GoogleFonts.notoSerifTeluguTextTheme().copyWith(
      displayLarge: GoogleFonts.notoSerifTelugu(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displayMedium: GoogleFonts.notoSerifTelugu(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.notoSerifTelugu(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.notoSerifTelugu(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.notoSerifTelugu(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.notoSerifTelugu(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.notoSerifTelugu(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.notoSerifTelugu(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: GoogleFonts.notoSerifTelugu(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.notoSerifTelugu(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.notoSerifTelugu(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
      bodySmall: GoogleFonts.notoSerifTelugu(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
      labelLarge: GoogleFonts.notoSerifTelugu(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: GoogleFonts.notoSerifTelugu(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: GoogleFonts.notoSerifTelugu(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    ).apply(fontFamilyFallback: _malayalamFallback);
  }

  static TextTheme get teluguTextTheme {
    return textTheme;
  }

  static TextTheme get malayalamTextTheme {
    return GoogleFonts.notoSerifMalayalamTextTheme();
  }
}
