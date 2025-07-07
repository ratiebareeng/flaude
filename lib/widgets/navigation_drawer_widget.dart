import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/widgets/navigation_item.dart';
import 'package:flutter/material.dart';

class NavigationDrawerWidget extends StatefulWidget {
  final String currentView; // Default view
  final List<Chat> starredChats;
  final List<Chat> recentChats;
  final Function(String view, {String? chatId})? onMenuItemSelected;
  const NavigationDrawerWidget({
    super.key,
    required this.currentView,
    required this.starredChats,
    required this.recentChats,
    this.onMenuItemSelected,
  });

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  double drawerWidth = 300; // Width of the left navigation drawer
  String? _selectedChatId;
  final bool _showArtifactDetail = false;
  Map<String, dynamic>? _currentArtifact;
  bool get drawerIsOpen => drawerWidth == 300;

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => widget.onMenuItemSelected
                        ?.call('new_chat', chatId: null),
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
                        onTap: () => widget.onMenuItemSelected
                            ?.call('new_chat', chatId: null),
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
                NavigationItem(
                  drawerIsOpen: drawerIsOpen,
                  icon: Icons.chat_outlined,
                  title: 'Chats',
                  isSelected: widget.currentView == 'chats',
                  onTap: () => widget.onMenuItemSelected?.call('chats'),
                ),
                NavigationItem(
                  drawerIsOpen: drawerIsOpen,
                  icon: Icons.folder_outlined,
                  title: 'Projects',
                  isSelected: widget.currentView == 'projects',
                  onTap: () => widget.onMenuItemSelected?.call('projects'),
                ),
                if (drawerIsOpen) ...[
                  // Starred Chats Section
                  if (widget.starredChats.isNotEmpty) ...[
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
                    ...widget.starredChats.map((chat) => _buildChatItem(
                          chat: chat,
                          isStarred: true,
                        )),
                  ],

                  // Recent Chats Section
                  if (widget.recentChats.isNotEmpty) ...[
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
                    ...widget.recentChats
                        .map((chat) => _buildChatItem(chat: chat)),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required Chat chat,
    bool isStarred = false,
  }) {
    final isSelected = _selectedChatId == chat.id;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        title: Text(
          chat.title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: chat.messages.isNotEmpty
            ? Text(
                chat.messages.first.content,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        selected: isSelected,
        selectedTileColor: Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        onTap: () => widget.onMenuItemSelected?.call('chat', chatId: chat.id),
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
