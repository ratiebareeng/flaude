import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Theme Colors
class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFFCD7F32);
  static const Color onDarkPrimaryColor = Color(0xFFFAF9F5);
  
  // Dark theme colors
  static const Color darkSurface = Color(0xFF262624);
  static const Color darkOnSurface = Color(0xFFFAF9F5);
  static const Color darkPrimaryContainer = Color(0xFF262624);
  static const Color darkOnPrimaryContainer = Color(0xFFFAF9F5);
  static const Color darkScaffoldBackground = Color(0xFF262624);
  
  // Light theme colors
  static const Color lightSurface = Color(0xFFFAF9F5);
  static const Color lightOnSurface = Color(0xFF262624);
  static const Color lightScaffoldBackground = Color(0xFFFAF9F5);
  static const Color lightInputFill = Color(0xFF262624);
}

// Text Styles
class AppTextStyles {
  static TextStyle get titleLarge => GoogleFonts.gideonRoman(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle get labelLarge => GoogleFonts.gideonRoman(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle get appBarTitle => GoogleFonts.gideonRoman(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  
  static TextTheme get latoTextTheme => GoogleFonts.latoTextTheme();
  
  static TextStyle get inputLabel => GoogleFonts.lato();
  
  static TextStyle get hintText => const TextStyle(color: Colors.grey);
}

// Common Theme Configuration
class AppThemeConfig {
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;
  static const double cardBorderWidth = 0.5;
  
  // Elevation
  static const double appBarElevation = 0.0;
  
  // Common shapes
  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      );
  
  static RoundedRectangleBorder get inputShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
      );
  
  static RoundedRectangleBorder get buttonShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
      );
}