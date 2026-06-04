import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static TextTheme get teluguTextTheme {
    return GoogleFonts.notoSansTeluguTextTheme(textTheme).copyWith(
      // Can override specific weights/sizes if Telugu needs different handling
    );
  }
}
