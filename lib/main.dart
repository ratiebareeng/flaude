// main.dart
import 'package:claude_chat_clone/firebase_options.dart';
import 'package:claude_chat_clone/screens/screens.dart';
import 'package:claude_chat_clone/services/global_keys.dart';
import 'package:claude_chat_clone/viewmodel/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//? Primary color:
//? Artefact bg color: #30302E
//? Chat page bg color: #262624
//? User chat card bg color: #141413
//? Chat history drawer bg color: #1F1E1D

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Claude Clone',
        scaffoldMessengerKey: scaffoldMessengerKey,
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Color(0xFFCD7F32), //0xFFCD7F32 // 0xffda7756 // 0xffbd5d3a
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
            Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
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
        ),
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Color(0xFFCD7F32), //0xFFCD7F32 // 0xffda7756 // 0xffbd5d3a
              primary: Color(0xFFCD7F32),
              surface: Color(0xFF262624),
              onSurface: Color(0xFFFAF9F5)),
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
            Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
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
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
