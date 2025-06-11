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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  double drawerWidth = 300; // Width of the left navigation drawer
  String _currentView = 'chat'; // 'chat', 'projects', 'new_chat'
  String? _selectedChatId;
  bool _showArtifactDetail = false;
  Map<String, dynamic>? _currentArtifact;

  // Sample data - replace with your actual data management
  final List<Map<String, String>> _recentChats = [
    {
      'id': '1',
      'title': 'Flutter Development Help',
      'preview': 'How to create a navigation drawer...'
    },
    {
      'id': '2',
      'title': 'Dart Programming Questions',
      'preview': 'Understanding async programming...'
    },
    {
      'id': '3',
      'title': 'UI Design Discussion',
      'preview': 'Best practices for mobile UI...'
    },
  ];

  final List<Map<String, String>> _starredChats = [
    {
      'id': '4',
      'title': 'Important Code Review',
      'preview': 'Critical bug fixes discussed...'
    },
    {
      'id': '5',
      'title': 'Architecture Planning',
      'preview': 'App structure and patterns...'
    },
  ];

  bool get drawerIsOpen => drawerWidth == 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Drawer
          _buildNavigationDrawer(),

          // Main Content Area
          Expanded(
            child: _buildMainContent(),
          ),

          // Right Artifact Panel (conditional)
          _buildArtifactPanel(),
        ],
      ),
    );
  }

  Widget _buildArtifactPanel() {
    if (!_showArtifactDetail || _currentArtifact == null) {
      return SizedBox.shrink();
    }

    return Container(
      width: 400,
      color: Color(0xFF30302E),
      child: Column(
        children: [
          // Artifact Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentArtifact!['title'] ?? 'Artifact',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _handleArtifactView(null),
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                ),
              ],
            ),
          ),

          // Artifact Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artifact preview/content would go here
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF262624),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentArtifact!['content'] ??
                          'Artifact content would be displayed here',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Project Section
          if (_currentView == 'chat')
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[700]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle add to project
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Artifact added to project knowledge'),
                            backgroundColor: Color(0xffbd5d3a),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, size: 16),
                      label: Text('Add to Knowledge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffbd5d3a),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required Map<String, String> chat,
    bool isStarred = false,
  }) {
    final isSelected = _selectedChatId == chat['id'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        title: Text(
          chat['title'] ?? '',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat['preview'] ?? '',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        selectedTileColor: Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        onTap: () => _handleNavigation('chat', chatId: chat['id']),
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case 'projects':
        return ProjectsScreen();
      case 'new_chat':
      case 'chat':
        return ChatScreen(
          chatId: _selectedChatId,
          onArtifactView: _handleArtifactView,
        );
      default:
        return ChatScreen(
          chatId: _selectedChatId,
          onArtifactView: _handleArtifactView,
        );
    }
  }

  Widget _buildNavigationDrawer() {
    return Container(
      width: drawerWidth.toDouble(),
      color: Color(0xFF1F1E1D),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
                top: 16,
                bottom: 32,
                right: drawerIsOpen ? 16 : 8,
                left: drawerIsOpen ? 8 : 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      drawerWidth = drawerWidth == 300 ? 60 : 300;
                    });
                  },
                  icon: Icon(
                      drawerIsOpen
                          ? Icons.menu_open_outlined
                          : Icons.menu_outlined,
                      color: Colors.white,
                      size: 24),
                ),
                if (drawerIsOpen) ...[
                  SizedBox(width: 12),
                  Text(
                    'Flaude',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // New Chat Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: drawerIsOpen
                ? GestureDetector(
                    onTap: () => _handleNavigation('new_chat'),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'New Chat',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleNavigation('new_chat'),
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Icon(
                            Icons.add_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  icon: Icons.chat_outlined,
                  title: 'Chats',
                  isSelected: _currentView == 'chat',
                  onTap: () => _handleNavigation('chat'),
                ),
                _buildNavItem(
                  icon: Icons.folder_outlined,
                  title: 'Projects',
                  isSelected: _currentView == 'projects',
                  onTap: () => _handleNavigation('projects'),
                ),
                if (drawerIsOpen) ...[
                  // Starred Chats Section
                  if (_starredChats.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Starred',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ..._starredChats.map((chat) => _buildChatItem(
                          chat: chat,
                          isStarred: true,
                        )),
                  ],

                  // Recent Chats Section
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Recent Chats',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ..._recentChats.map((chat) => _buildChatItem(chat: chat)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: drawerIsOpen
          ? ListTile(
              leading: Icon(
                icon,
                color: isSelected ? Color(0xffbd5d3a) : Colors.grey[400],
                size: 20,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedTileColor: Color(0xFF2d2d2d),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: onTap,
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            )
          : Container(
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF2d2d2d) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? Color(0xffbd5d3a) : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _handleArtifactView(Map<String, dynamic>? artifact) {
    setState(() {
      _currentArtifact = artifact;
      _showArtifactDetail = artifact != null;
    });
  }

  void _handleNavigation(String view, {String? chatId}) {
    setState(() {
      _currentView = view;
      if (chatId != null) {
        _selectedChatId = chatId;
      }
      if (view == 'new_chat') {
        _selectedChatId = null;
        _showArtifactDetail = false;
        _currentArtifact = null;
      }
    });
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
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xffda7756), primary: Color(0xffbd5d3a)),
          scaffoldBackgroundColor: Color(0xFF262624),
          cardTheme: CardTheme(
            color: Color(0xFF262624),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade800, width: 0.5),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1a1a1a),
            elevation: 0,
          ),
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
          ),
        ),
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
