// screens/chat_screen.dart
import 'package:flutter/material.dart';

// Message model
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool hasArtifact;
  final Map<String, dynamic>? artifact;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.hasArtifact = false,
    this.artifact,
  });
}

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final Function(Map<String, dynamic>?)? onArtifactView;

  const ChatScreen({
    super.key,
    this.chatId,
    this.onArtifactView,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // Sample messages - replace with your actual message management
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF262624),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1a1a1a),
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.chatId == null
                        ? 'New Chat'
                        : _getChatTitle(widget.chatId!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.chatId != null) ...[
                  IconButton(
                    onPressed: () {
                      // Handle chat settings
                    },
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),

          // Messages Area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1a1a1a),
              border: Border(
                top: BorderSide(color: Colors.grey[700]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message Claude...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xffbd5d3a)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Color(0xFF2d2d2d),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffbd5d3a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _loadChatMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  Widget _buildArtifactPreview(Map<String, dynamic> artifact) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF30302E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[600]!),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    artifact['title'] ?? 'Artifact',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewArtifact(artifact),
                  icon: Icon(Icons.open_in_new, size: 14),
                  label: Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xffbd5d3a),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            child: Text(
              artifact['content']?.substring(0, 100) ?? 'No preview available',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            widget.chatId == null
                ? 'Start a new conversation'
                : 'No messages yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Type a message below to begin',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xffbd5d3a),
            child: Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xffbd5d3a)),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Claude is thinking...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xffbd5d3a),
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        message.isUser ? Color(0xFF141413) : Color(0xFF2d2d2d),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (message.hasArtifact && message.artifact != null) ...[
                        SizedBox(height: 12),
                        _buildArtifactPreview(message.artifact!),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[600],
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _generateAIResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('flutter')) {
      return 'Flutter is Google\'s UI toolkit for building natively compiled applications. What specific aspect would you like to learn about?';
    } else if (userMessage.toLowerCase().contains('dart')) {
      return 'Dart is the programming language used by Flutter. It\'s object-oriented and supports both just-in-time and ahead-of-time compilation.';
    } else {
      return 'I understand you\'re asking about: "$userMessage". Let me help you with that. Could you provide more specific details about what you\'re trying to achieve?';
    }
  }

  String _getChatTitle(String chatId) {
    switch (chatId) {
      case '1':
        return 'Flutter Development Help';
      case '2':
        return 'Dart Programming Questions';
      case '3':
        return 'UI Design Discussion';
      case '4':
        return 'Important Code Review';
      case '5':
        return 'Architecture Planning';
      default:
        return 'Chat';
    }
  }

  List<ChatMessage> _getSampleMessages(String chatId) {
    // Sample messages - replace with actual data loading
    switch (chatId) {
      case '1':
        return [
          ChatMessage(
            id: '1',
            content: 'How do I create a navigation drawer in Flutter?',
            isUser: true,
            timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          ),
          ChatMessage(
            id: '2',
            content:
                'I\'ll help you create a navigation drawer in Flutter. Here\'s a complete example with a three-panel layout:',
            isUser: false,
            timestamp: DateTime.now().subtract(Duration(minutes: 29)),
            hasArtifact: true,
            artifact: {
              'id': 'nav_drawer_example',
              'title': 'Flutter Navigation Drawer',
              'type': 'code',
              'language': 'dart',
              'content': '''class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentView = 'chat';
  
  Widget _buildNavigationDrawer() {
    return Container(
      width: 280,
      color: Color(0xFF1F1E1D),
      child: Column(
        children: [
          // Navigation items
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationDrawer(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }
}''',
            },
          ),
        ];
      case '2':
        return [
          ChatMessage(
            id: '3',
            content: 'Can you explain async programming in Dart?',
            isUser: true,
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
          ChatMessage(
            id: '4',
            content:
                'Async programming in Dart allows you to write non-blocking code using Future and async/await patterns.',
            isUser: false,
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
        ];
      default:
        return [];
    }
  }

  void _loadChatMessages() {
    // Load messages based on chatId
    setState(() {
      if (widget.chatId == null) {
        // New chat
        _messages = [];
      } else {
        // Load existing chat messages
        _messages = _getSampleMessages(widget.chatId!);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    _simulateAIResponse(userMessage.content);
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(Duration(seconds: 2), () {
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _generateAIResponse(userMessage),
        isUser: false,
        timestamp: DateTime.now(),
        hasArtifact: userMessage.toLowerCase().contains('code') ||
            userMessage.toLowerCase().contains('create') ||
            userMessage.toLowerCase().contains('example'),
        artifact: userMessage.toLowerCase().contains('code')
            ? {
                'id': 'sample_artifact',
                'title': 'Code Example',
                'type': 'code',
                'language': 'dart',
                'content': 'void main() {\n  print("Hello, World!");\n}',
              }
            : null,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  void _viewArtifact(Map<String, dynamic> artifact) {
    if (widget.onArtifactView != null) {
      widget.onArtifactView!(artifact);
    }
  }
}
