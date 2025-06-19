import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/screens/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  final Function(String chatId)? onChatSelected;
  final VoidCallback? onNewChatPressed;

  const ChatsScreen({
    super.key,
    this.onChatSelected,
    this.onNewChatPressed,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<Chat> _allChats = [];
  List<Chat> _filteredChats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chats = await ChatService.instance.getAllChats();
      setState(() {
        _allChats = chats;
        _filteredChats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load chats: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChats = _allChats;
      } else {
        _filteredChats = _allChats.where((chat) {
          final titleMatch = chat.title.toLowerCase().contains(query);
          final lastMessageMatch =
              chat.lastMessage?.content.toLowerCase().contains(query) ?? false;
          return titleMatch || lastMessageMatch;
        }).toList();
      }
    });
  }

  void _onChatTap(Chat chat) {
    widget.onChatSelected?.call(chat.id);
  }

  void _onNewChatTap() {
    widget.onNewChatPressed?.call();
  }

  String _formatLastMessageTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and New Chat Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your chat history',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _onNewChatTap,
                        icon: Icon(Icons.add, size: 18),
                        label: Text('New chat'),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: Color(0xFF3A3A3A),
                          // foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus
                            ? Color(0xFFBD5D3A)
                            : Color(0xFF3A3A3A),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search your chats...',
                        hintStyle: TextStyle(
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Chat Count
                  if (!_isLoading && _error == null)
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'You have '),
                          TextSpan(
                            text: '${_allChats.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: ' previous chats with Claude. '),
                          TextSpan(
                            text: 'Select',
                            style: TextStyle(
                              color: Color(0xFFBD5D3A),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Chat List
            Expanded(
              child: _buildChatList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFFBD5D3A),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey[400],
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChats,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBD5D3A),
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.chat_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No chats found matching "$_searchQuery"'
                  : 'No chats yet',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onNewChatTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBD5D3A),
                  foregroundColor: Colors.white,
                ),
                child: Text('Start your first chat'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(Chat chat) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onChatTap(chat),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Chat Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),

              SizedBox(width: 12),

              // Chat Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat Title
                    Text(
                      chat.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Last Message Time
                    Text(
                      'Last message ${_formatLastMessageTime(chat.updatedAt)}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Options Menu
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.grey,
                  )),
              // PopupMenuButton<String>(
              //   icon: Icon(
              //     Icons.more_vert,
              //     color: Colors.grey[400],
              //     size: 20,
              //   ),
              //   color: Color(0xFF3A3A3A),
              //   onSelected: (value) => _handleChatAction(value, chat),
              //   itemBuilder: (context) => [
              //     PopupMenuItem(
              //       value: 'rename',
              //       child: Row(
              //         children: [
              //           Icon(Icons.edit, color: Colors.white, size: 16),
              //           SizedBox(width: 8),
              //           Text('Rename', style: TextStyle(color: Colors.white)),
              //         ],
              //       ),
              //     ),
              //     PopupMenuItem(
              //       value: 'delete',
              //       child: Row(
              //         children: [
              //           Icon(Icons.delete, color: Colors.red, size: 16),
              //           SizedBox(width: 8),
              //           Text('Delete', style: TextStyle(color: Colors.red)),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChatAction(String action, Chat chat) {
    switch (action) {
      case 'rename':
        _showRenameDialog(chat);
        break;
      case 'delete':
        _showDeleteDialog(chat);
        break;
    }
  }

  void _showRenameDialog(Chat chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Rename Chat'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBD5D3A)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ChatService.instance
                    .renameChat(chat.id, controller.text.trim());
                Navigator.pop(context);
                _loadChats(); // Refresh the list
              }
            },
            child: Text('Rename', style: TextStyle(color: Color(0xFFBD5D3A))),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Delete Chat'),
        content: Text(
          'Are you sure you want to delete "${chat.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ChatService.instance.deleteChat(chat.id);
              Navigator.pop(context);
              _loadChats(); // Refresh the list
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
