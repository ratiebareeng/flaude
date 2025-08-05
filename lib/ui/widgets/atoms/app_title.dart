import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppTitle({
    super.key,
    required this.title,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.gideonRoman(
        fontSize: fontSize ?? 24,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }
}
