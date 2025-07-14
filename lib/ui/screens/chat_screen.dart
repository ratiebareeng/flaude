import 'package:claude_chat_clone/domain/models/ai_models_list.dart';
import 'package:claude_chat_clone/ui/viewmodels/chat_viewmodel.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/ai_model_dropdown_menu.dart';
import 'package:claude_chat_clone/ui/widgets/molecules/message_bubble.dart';
import 'package:claude_chat_clone/ui/widgets/molecules/new_chat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  late ChatViewModel _viewModel;

  // Helper methods
  bool get _canSendMessage {
    return _messageController.text.trim().isNotEmpty && !_viewModel.isSending;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    viewModel.clearError();
                    _viewModel.initialize(widget.chatId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Container(
          color: const Color(0xFF1A1917),
          child: Column(
            children: [
              // Messages Area
              Expanded(
                child: viewModel.hasMessages
                    ? _buildMessagesList(viewModel)
                    : NewChatCard(
                        messageController: _messageController,
                        messageFocusNode: _messageFocusNode,
                        chatViewModel: viewModel,
                        sendMessage: _sendMessage,
                      ),
              ),
              // Input Area
              if (viewModel.hasMessages) _buildInputArea(viewModel),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _viewModel.initialize(widget.chatId);
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
    _viewModel = Provider.of<ChatViewModel>(context, listen: false);
    _initializeChat();
  }

  Widget _buildInputArea(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildInputRow(viewModel),
          ),
          AIModelDropDownMenu(
            menuEntries: claudeModels,
            initialEntry: claudeModels.first,
            onSelected: (model) {
              // Handle model selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(ChatViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Attach button
        Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
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
              color: const Color(0xFF2F2F2F),
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
              onSubmitted: (_) => _sendMessage,
              style: const TextStyle(
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        // Send button
        Container(
          margin: const EdgeInsets.only(left: 8, bottom: 8),
          child: IconButton(
            onPressed: () => _sendMessage,
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: _canSendMessage ? Colors.white : Colors.grey[600],
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  _canSendMessage ? const Color(0xFFCD7F32) : Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFCD7F32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
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
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2F2F2F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
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
                      color: Colors.grey,
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

  Widget _buildMessagesList(ChatViewModel viewModel) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: viewModel.messages.length + (viewModel.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.messages.length) {
          return _buildLoadingIndicator();
        }
        return MessageBubble(
          message: viewModel.messages[index],
          viewArtifact: widget.onArtifactView,
        );
      },
    );
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize(widget.chatId);
    });
  }

  void _sendMessage() async {
    if (!_canSendMessage) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    await _viewModel.sendMessage(message);
  }
}
