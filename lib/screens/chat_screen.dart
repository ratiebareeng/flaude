// screens/chat_screen.dart
import 'package:claude_chat_clone/models/ai_models_list.dart';
import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/chat_repository.dart';
import 'package:claude_chat_clone/screens/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late Chat chat;
  bool _initDone = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return !_initDone
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<(bool, List<Message>?)>(
            stream: ChatRepository.instance.listenToChatMessages(chat.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFCD7F32)),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading messages',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              final List<Message> messages = snapshot.data?.$2 ?? [];

              if (messages.isEmpty) {
                return _buildEmptyState();
              }
              return Container(
                color: Color(0xFF1A1917), // Dark background like Claude
                child: Column(
                  children: [
                    // Messages Area
                    Expanded(
                      child: messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              itemCount: messages.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return _buildLoadingIndicator();
                                }
                                return _buildMessageBubble(messages[index]);
                              },
                            ),
                    ),

                    if (messages.isNotEmpty)
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
                            DropdownMenu<AIModel>(
                              initialSelection: claudeModels.first,
                              dropdownMenuEntries: claudeModels
                                  .map((model) => DropdownMenuEntry<AIModel>(
                                        value: model,
                                        label: model.name,
                                      ))
                                  .toList(),
                              onSelected: (model) {},
                            ),

                            // Model selector
                            // Container(
                            //   constraints: BoxConstraints(maxWidth: 800),
                            //   margin: EdgeInsets.only(top: 12),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //       horizontal: 12, vertical: 6),
                            //   decoration: BoxDecoration(
                            //     color: Color(0xFF2F2F2F),
                            //     borderRadius: BorderRadius.circular(12),
                            //     // border:
                            //     //     Border.all(color: Colors.grey[700]!),
                            //   ),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       Text(
                            //         'Claude Sonnet 4',
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 14,
                            //           fontWeight: FontWeight.w500,
                            //         ),
                            //       ),
                            //       SizedBox(width: 4),
                            //       Icon(
                            //         Icons.keyboard_arrow_down,
                            //         color: Colors.grey[400],
                            //         size: 18,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
//!      _loadChatMessages();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });

      var result = await ChatService.instance.initialize(widget.chatId);

      if (result != null) {
        chat = result;
      }

      setState(() {
        _initDone = true;
        _isLoading = false;
      });
    });
    //_loadChatMessages();
    // _messageController.addListener(() {
    //   setState(() {}); // Rebuild to update send button state
    // });
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
              onSubmitted: (value) async {
                if (_messageController.text.trim().isEmpty || _isLoading) {
                  return;
                }
                await ChatService.instance.sendMessage(
                  chatId: chat.id,
                  content: _messageController.text.trim(),
                );
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
            onPressed: () async {
              if (_messageController.text.trim().isEmpty || _isLoading) {
                return;
              }
              await ChatService.instance.sendMessage(
                chatId: chat.id,
                content: _messageController.text.trim(),
              );
            },
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
        //  color: Color(0xFF2F2F2F),
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
            onSubmitted: (value) async {
              if (_messageController.text.trim().isEmpty || _isLoading) {
                return;
              }

              // Create chat if it doesnt have an id
              if (chat.id.isEmpty) {
                final newChat = await ChatService.instance.saveChat(chat);

                if (newChat == null || newChat.id.isEmpty) {
                  return;
                }

                setState(() {
                  chat = newChat;
                });
              }
              await ChatService.instance.sendMessage(
                chatId: chat.id,
                content: _messageController.text.trim(),
              );
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
                  // color: Color(0xFF2F2F2F),
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
                onPressed: () async {
                  // Create chat if it doesnt have an id
                  if (chat.id.isEmpty) {
                    final newChat = await ChatService.instance.saveChat(chat);

                    if (newChat == null || newChat.id.isEmpty) {
                      return;
                    }

                    setState(() {
                      chat = newChat;
                    });
                  }
                  await ChatService.instance.sendMessage(
                    chatId: chat.id,
                    content: _messageController.text.trim(),
                  );
                },
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

  Widget _buildMessageBubble(Message message) {
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
                      if (message.hasArtifact! && message.artifact != null)
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
      onTap: () async {
        _messageController.text = subtitle;
        if (_messageController.text.trim().isEmpty || _isLoading) {
          return;
        }
        await ChatService.instance.sendMessage(
          chatId: chat.id,
          content: _messageController.text.trim(),
        );
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

  // void _sendMessage() async {
  //   if (_messageController.text.trim().isEmpty || _isLoading) return;

  //   // Create chat if not already created
  //   if (chat.id.isEmpty) {
  //     await ChatService.instance.createChat();
  //   }

  //   final userMessage = Message(
  //     chatId: chat.id,
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     content: _messageController.text.trim(),
  //     isUser: true,
  //     timestamp: DateTime.now(),
  //   );

  //   setState(() {
  //     //! _messages.add(userMessage);
  //     _isLoading = true;
  //   });

  //   // add message to chat
  //   //? await ChatService.instance.addMessageToChat(chat.id, userMessage);

  //   _messageController.clear();
  //   _scrollToBottom();

  //   //_simulateAIResponse(userMessage.content);
  // }

  void _viewArtifact(Map<String, dynamic> artifact) {
    if (widget.onArtifactView != null) {
      widget.onArtifactView!(artifact);
    }
  }
}
