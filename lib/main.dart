// main.dart
import 'package:claude_chat_clone/screens/screens.dart';
import 'package:claude_chat_clone/viewmodel/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//? Primary color:
//? Artefact bg color: #30302E
//? Chat page bg color: #262624
//? User chat card bg color: #141413
//? Chat history drawer bg color: #1F1E1D
void main() {
  runApp(MyApp());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    ProjectsScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: Color(0xFF2d2d2d),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Claude Clone',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xffda7756), primary: Color(0xffbd5d3a)),
          scaffoldBackgroundColor: Color(0xFF1a1a1a),
          cardColor: Color(0xFF2d2d2d),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1a1a1a),
            elevation: 0,
          ),
        ),
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
