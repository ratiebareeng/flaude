// screens/chat_screen.dart
import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/services/services.dart';
import 'package:claude_chat_clone/viewmodel/app_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ClaudeApiService _apiService = ClaudeApiService();
  final List<String> _attachedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppState>(
          builder: (context, appState, child) {
            return Text(appState.currentChat?.title ?? 'New Chat');
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              context.read<AppState>().setSelectedModel(value);
            },
            itemBuilder: (BuildContext context) {
              return context
                  .read<AppState>()
                  .availableModels
                  .map((String model) {
                return PopupMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList();
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      return Text(
                        appState.selectedModel,
                        style: TextStyle(fontSize: 14),
                      );
                    },
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                final messages = appState.currentChat?.messages ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2d2d2d),
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Column(
        children: [
          if (_attachedFiles.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                children: _attachedFiles.map((file) {
                  return Chip(
                    label: Text(file.split('/').last),
                    onDeleted: () {
                      setState(() {
                        _attachedFiles.remove(file);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: _pickFiles,
                icon: Icon(Icons.attach_file),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: message.isUser ? Colors.blue : Colors.grey,
            child: Icon(
              message.isUser ? Icons.person : Icons.smart_toy,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? 'You' : 'Claude',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF2d2d2d),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message.content),
                ),
                if (message.attachments != null &&
                    message.attachments!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: message.attachments!.map((file) {
                        return Chip(
                          label: Text(file.split('/').last),
                          backgroundColor: Colors.blue.shade100,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _attachedFiles
            .addAll(result.paths.where((path) => path != null).cast<String>());
      });
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final appState = context.read<AppState>();

    // Create a new chat if none exists
    if (appState.currentChat == null) {
      appState.createChat(
          title:
              message.length > 30 ? '${message.substring(0, 30)}...' : message);
    }

    // Add user message
    appState.addMessage(message, true,
        attachments:
            _attachedFiles.isNotEmpty ? List.from(_attachedFiles) : null);

    _messageController.clear();
    _attachedFiles.clear();
    setState(() {});

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Send to Claude API
    try {
      final response = await _apiService.sendMessage(
        message: message,
        model: appState.selectedModel,
        apiKey: appState.apiKey,
        conversationHistory: appState.currentChat!.messages,
      );

      appState.addMessage(response, false);
    } catch (e) {
      appState.addMessage('Error: ${e.toString()}', false);
    }

    // Scroll to bottom again
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
}
