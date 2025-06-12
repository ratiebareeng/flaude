// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1A1917), // Dark background like Claude
      child: Column(
        children: [
          // Messages Area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          if (_messages.isNotEmpty)
            // Input Area
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Input field
                  Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: inputRow(),
                  ),

                  // Model selector
                  Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    margin: EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF2F2F2F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Claude Sonnet 4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
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
    _messageController.addListener(() {
      setState(() {}); // Rebuild to update send button state
    });
  }

  Widget inputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Attach button
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: IconButton(
            onPressed: () {
              // Handle attachment
            },
            icon: Icon(Icons.attach_file, color: Colors.grey[400]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Text input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF2F2F2F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted: (value) {
                if (!_isLoading) _sendMessage();
              },
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'How can I help you today?',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),

        // Send button
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8),
          child: IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: _messageController.text.trim().isEmpty || _isLoading
                  ? Colors.grey[600]
                  : Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  _messageController.text.trim().isEmpty || _isLoading
                      ? Colors.grey[800]
                      : Color(0xFFCD7F32), // Claude orange
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget largeInputWidget() {
    return Container(
      constraints: BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _messageController,
            focusNode: _messageFocusNode,
            maxLines: null,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onSubmitted: (value) {
              if (!_isLoading) _sendMessage();
            },
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              hoverColor: Colors.transparent,
              hintText: 'How can I help you today?',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              // contentPadding:
              //     EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          // Agent selector and send button row
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Agent selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF2F2F2F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Claude Sonnet 4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 24),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ],
                ),
              ),

              // Send button
              IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: _messageController.text.trim().isEmpty || _isLoading
                      ? Colors.grey[600]
                      : Colors.white,
                ),
                color: _messageController.text.trim().isEmpty || _isLoading
                    ? Theme.of(context).primaryColor //.withValues(alpha: 0.5)
                    : Theme.of(context).primaryColor,
                style: IconButton.styleFrom(
                  backgroundColor: _messageController.text.trim().isEmpty ||
                          _isLoading
                      ? Theme.of(context).primaryColor //.withValues(alpha: 0.5)
                      : Theme.of(context)
                          .primaryColor, //Color(0xFFCD7F32), // Claude orange
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactPreview(Map<String, dynamic> artifact) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.code, color: Colors.white, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    artifact['title'] ?? 'Artifact',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewArtifact(artifact),
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFFCD7F32),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              artifact['content']?.substring(0, 100) ?? 'No preview available',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontFamily: 'Consolas',
                height: 1.4,
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
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Greeting
            Row(
              children: [
                // Flaude logo/icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFCD7F32),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 32,
                    color: Colors.grey.shade300,
                  ),
                ),
                SizedBox(width: 24),
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
            ),

            SizedBox(height: 48),

            largeInputWidget(),

            SizedBox(height: 16),
            // Suggestion buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSuggestionChip('✏️ Write', 'Draft an email to my team',
                    // Icons.edit_outlined,
                    showSubtitle: false),
                _buildSuggestionChip('📚 Learn', 'Explain quantum computing',
                    //Icons.school_outlined,
                    showSubtitle: false),
                _buildSuggestionChip(
                    '💻 Code', 'Build a Flutter app', //Icons.code_outlined,
                    showSubtitle: false),
                _buildSuggestionChip('☕ Life stuff', 'Plan my weekend',
                    //  Icons.local_cafe_outlined,
                    showSubtitle: false),
                _buildSuggestionChip(
                  '🎲 Claude\'s choice',
                  'Surprise me',
                  // Icons.casino_outlined,
                  showSubtitle: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      constraints: BoxConstraints(maxWidth: 800),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Claude avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFCD7F32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          // Loading content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2F2F2F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFCD7F32)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Claude is thinking...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 800),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // Claude avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFCD7F32),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                        message.isUser ? Color(0xFF3A3A3A) : Color(0xFF2F2F2F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      if (message.hasArtifact && message.artifact != null)
                        _buildArtifactPreview(message.artifact!),
                    ],
                  ),
                ),
                SizedBox(height: 8),
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
            // User avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    String title,
    String subtitle, {
    bool? showSubtitle = true,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () {
        _messageController.text = subtitle;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          // color: Color(0xFF2F2F2F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (showSubtitle!) ...[
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
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
      return 'Flutter is Google\'s UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. What specific aspect of Flutter development would you like to explore?';
    } else if (userMessage.toLowerCase().contains('dart')) {
      return 'Dart is the programming language used by Flutter. It\'s object-oriented, supports both just-in-time and ahead-of-time compilation, and offers features like null safety and async programming.';
    } else if (userMessage.toLowerCase().contains('code') ||
        userMessage.toLowerCase().contains('build')) {
      return 'I\'d be happy to help you with coding! Here\'s a simple example to get you started:';
    } else {
      return 'I understand you\'re asking about: "$userMessage". I\'m here to help! Could you provide more specific details about what you\'re trying to achieve?';
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
    switch (chatId) {
      case '1':
        return [
          ChatMessage(
            id: '1',
            content:
                'How do I create a responsive navigation drawer in Flutter?',
            isUser: true,
            timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          ),
          ChatMessage(
            id: '2',
            content:
                'I\'ll help you create a responsive navigation drawer in Flutter. Here\'s a complete implementation that adapts to different screen sizes:',
            isUser: false,
            timestamp: DateTime.now().subtract(Duration(minutes: 29)),
            hasArtifact: true,
            artifact: {
              'id': 'responsive_nav_drawer',
              'title': 'Responsive Navigation Drawer',
              'type': 'code',
              'language': 'dart',
              'content': '''class ResponsiveDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return Row(
            children: [
              Container(
                width: 280,
                child: NavigationDrawer(),
              ),
              Expanded(child: MainContent()),
            ],
          );
        } else {
          return Scaffold(
            drawer: NavigationDrawer(),
            body: MainContent(),
          );
        }
      },
    );
  }
}''',
            },
          ),
        ];
      default:
        return [];
    }
  }

  void _loadChatMessages() {
    setState(() {
      if (widget.chatId == null) {
        _messages = [];
      } else {
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
    if (_messageController.text.trim().isEmpty || _isLoading) return;

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

    _simulateAIResponse(userMessage.content);
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _generateAIResponse(userMessage),
        isUser: false,
        timestamp: DateTime.now(),
        hasArtifact: userMessage.toLowerCase().contains('code') ||
            userMessage.toLowerCase().contains('create') ||
            userMessage.toLowerCase().contains('build') ||
            userMessage.toLowerCase().contains('example'),
        artifact: (userMessage.toLowerCase().contains('code') ||
                userMessage.toLowerCase().contains('build'))
            ? {
                'id': 'sample_code_${DateTime.now().millisecondsSinceEpoch}',
                'title': 'Code Example',
                'type': 'code',
                'language': 'dart',
                'content': '''void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have pushed the button this many times:'),
            Text('\$_counter', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}''',
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
