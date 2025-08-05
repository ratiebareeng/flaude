import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFCD7F32),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 32,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          'Evening, naledi',
          style: TextStyle(
            fontFamily: GoogleFonts.gideonRoman().fontFamily,
            color: Colors.grey,
            fontSize: 48,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
