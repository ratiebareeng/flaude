import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/chat_repository.dart';
import 'package:claude_chat_clone/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double drawerWidth = 300; // Width of the left navigation drawer
  String _currentView = 'chat'; // 'chat', 'projects', 'new_chat'
  String? _selectedChatId;
  bool _showArtifactDetail = false;
  Map<String, dynamic>? _currentArtifact;
  final List<Chat> _recentChats = [];
  bool _isInitDone = false;

  final List<Chat> _starredChats = [];

  bool get drawerIsOpen => drawerWidth == 300;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load recent chats from firebase
      var result = await ChatRepository.instance.readRecentChats();
      if (result.$2 != null) {
        _recentChats.clear();
        _recentChats.addAll(result.$2!);
      }
      setState(() {
        _isInitDone = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitDone
          ? Row(
              children: [
                // Left Navigation Drawer
                NavigationDrawerWidget(
                  currentView: _currentView,
                  starredChats: _starredChats,
                  recentChats: _recentChats,
                  onMenuItemSelected: (view, {String? chatId}) {
                    setState(() {
                      _currentView = view;
                      if (chatId != null) {
                        _selectedChatId = chatId;
                        return;
                      }
                      if (view == 'new_chat') {
                        _selectedChatId = null;
                        _showArtifactDetail = false;
                        _currentArtifact = null;
                      }
                    });
                  },
                ),

                // Main Content Area
                Expanded(
                  child: _buildMainContent(),
                ),

                // Right Artifact Panel (conditional)
                _buildArtifactPanel(),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
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

  Widget _buildMainContent() {
    switch (_currentView) {
      case 'projects':
        return ProjectsScreen();
      case 'new_chat':
        return ChatScreen(
          key: ValueKey('new_chat'),
          chatId: null,
          onArtifactView: _handleArtifactView,
        );
      case 'chat':
        return ChatScreen(
          key: ValueKey(_selectedChatId ?? 'new_chat'),
          chatId: _selectedChatId,
          onArtifactView: _handleArtifactView,
        );
      case 'chats':
        return ChatsScreen(
          onChatSelected: (chatId) {
            setState(() {
              _currentView = 'chat';
              _selectedChatId = chatId;
            });
          },
          onNewChatPressed: () {
            setState(() {
              _currentView = 'new_chat';
              _selectedChatId = null;
            });
          },
        );
      default:
        return Center(
          child: Text('No implementation for view: $_currentView'),
        );
    }
  }

  void _handleArtifactView(Map<String, dynamic>? artifact) {
    setState(() {
      _currentArtifact = artifact;
      _showArtifactDetail = artifact != null;
    });
  }
}
