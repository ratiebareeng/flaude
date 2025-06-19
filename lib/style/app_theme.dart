import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get darkTheme {
  return ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFCD7F32), //0xFFCD7F32 // 0xffda7756 // 0xffbd5d3a
        primary: Color(0xFFCD7F32),
        surface: Color(0xFF262624),
        onSurface: Colors.white),
    scaffoldBackgroundColor: Color(0xFF262624),
    cardTheme: CardTheme(
      color: Color(0xFF262624),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade800, width: 0.5),
      ),
    ),
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
    textTheme: GoogleFonts.latoTextTheme(
        // Theme.of(context).textTheme.apply(
        //       bodyColor: Colors.white,
        //       displayColor: Colors.white,
        //     ),
        ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade600),
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
    iconTheme: IconThemeData(color: Colors.blue),
  );
}

ThemeData get lightTheme {
  return ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFCD7F32), //0xFFCD7F32 // 0xffda7756 // 0xffbd5d3a
        primary: Color(0xFFCD7F32),
        surface: Color(0xFFFAF9F5),
        onSurface: Color(0xFF262624)),
    scaffoldBackgroundColor: Color(0xFFFAF9F5),
    cardTheme: CardTheme(
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
    textTheme: GoogleFonts.latoTextTheme(
        // Theme.of(context).textTheme.apply(
        //       bodyColor: Color(0xFF262624),
        //       displayColor: Color(0xFF262624),
        //     ),
        ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: Color(0xFFCD7F32),
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
      color: Color(0xFFCD7F32),
    ),
  );
}
