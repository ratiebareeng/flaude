import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor =
    Color(0xFFCD7F32); //0xFFCD7F32 // 0xffda7756 // 0xffbd5d3a
const Color onDarkPrimaryColor = Color(0xFFFAF9F5);

ThemeData get darkTheme {
  return ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      surface: Color(0xFF262624),
      onSurface: Colors.white,
      primaryContainer: Color(0xFF262624),
      onPrimaryContainer: onDarkPrimaryColor,
    ),
    scaffoldBackgroundColor: Color(0xFF262624),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xFF262624),
      elevation: 0,
      titleTextStyle: GoogleFonts.gideonRoman(
        color: Colors.grey.shade400,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF262624),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade800, width: 0.5),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: onDarkPrimaryColor),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFF262624)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: false,
        fillColor: Colors.transparent,
        labelStyle: TextStyle(color: onDarkPrimaryColor),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Color(0xFF262624),
    ),
    iconTheme: IconThemeData(color: primaryColor),
  );
}

ThemeData get lightTheme {
  return ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: Color(0xFFFAF9F5),
        onSurface: Color(0xFF262624)),
    scaffoldBackgroundColor: Color(0xFFFAF9F5),
    cardTheme: CardThemeData(
      color: Color(0xFFFAF9F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade800, width: 0.5),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xFFFAF9F5),
      elevation: 0,
      titleTextStyle: GoogleFonts.gideonRoman(
        color: Colors.grey.shade400,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: primaryColor,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue),
      ),
      filled: true,
      fillColor: Color(0xFF262624),
    ),
    iconTheme: IconThemeData(
      color: primaryColor,
    ),
  );
}
