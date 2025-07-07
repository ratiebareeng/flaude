// main.dart
import 'package:claude_chat_clone/firebase_options.dart';
import 'package:claude_chat_clone/screens/screens.dart';
import 'package:claude_chat_clone/services/global_keys.dart';
import 'package:claude_chat_clone/style/app_theme.dart';
import 'package:claude_chat_clone/viewmodels/app_state.dart';
import 'package:claude_chat_clone/viewmodels/chat_viewmodel.dart';
import 'package:claude_chat_clone/viewmodels/chats_viewmodel.dart';
import 'package:claude_chat_clone/viewmodels/home_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatsViewModel(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Claude Clone',
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      theme: lightTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
