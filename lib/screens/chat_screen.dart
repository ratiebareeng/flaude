import 'package:claude_chat_clone/models/ai_models_list.dart';
import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/viewmodels/chat_viewmodel.dart';
import 'package:claude_chat_clone/widgets/ai_model_dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    : _buildEmptyState(viewModel),
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

  Widget _buildArtifactPreview(Map<String, dynamic> artifact) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.code, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    artifact['title'] ?? 'Artifact',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewArtifact(artifact),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFCD7F32),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              artifact['content']?.substring(0, 100) ?? 'No preview available',
              style: const TextStyle(
                color: Colors.grey,
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

  Widget _buildEmptyState(ChatViewModel viewModel) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGreeting(),
            const SizedBox(height: 48),
            _buildLargeInputWidget(viewModel),
            const SizedBox(height: 16),
            _buildSuggestionChips(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFCD7F32),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 32,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 24),
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
    );
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
              onSubmitted: (_) => _sendMessage(viewModel),
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
            onPressed: () => _sendMessage(viewModel),
            icon: Icon(
              Icons.arrow_upward_rounded,
              color:
                  _canSendMessage(viewModel) ? Colors.white : Colors.grey[600],
            ),
            style: IconButton.styleFrom(
              backgroundColor: _canSendMessage(viewModel)
                  ? const Color(0xFFCD7F32)
                  : Colors.grey[800],
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

  Widget _buildLargeInputWidget(ChatViewModel viewModel) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _messageController,
            focusNode: _messageFocusNode,
            maxLines: null,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onSubmitted: (_) => _sendMessage(viewModel),
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
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AIModelDropDownMenu(
                menuEntries: claudeModels,
                initialEntry: claudeModels.first,
                onSelected: (model) {
                  // Handle model selection
                },
              ),
              IconButton(
                onPressed: () => _sendMessage(viewModel),
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: _canSendMessage(viewModel)
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildMessageBubble(Message message, ChatViewModel viewModel) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
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
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFF2F2F2F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: const TextStyle(
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
                const SizedBox(height: 8),
                Text(
                  viewModel.formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
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

  Widget _buildMessagesList(ChatViewModel viewModel) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: viewModel.messages.length + (viewModel.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.messages.length) {
          return _buildLoadingIndicator();
        }
        return _buildMessageBubble(viewModel.messages[index], viewModel);
      },
    );
  }

  Widget _buildSuggestionChip(
      String title, String subtitle, ChatViewModel viewModel) {
    return InkWell(
      onTap: () => viewModel.sendSuggestion(subtitle),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(ChatViewModel viewModel) {
    final suggestions = [
      ('✏️ Write', 'Draft an email to my team'),
      ('📚 Learn', 'Explain quantum computing'),
      ('💻 Code', 'Build a Flutter app'),
      ('☕ Life stuff', 'Plan my weekend'),
      ('🎲 Claude\'s choice', 'Surprise me'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: suggestions
          .map((suggestion) => _buildSuggestionChip(
                suggestion.$1,
                suggestion.$2,
                viewModel,
              ))
          .toList(),
    );
  }

  // Helper methods
  bool _canSendMessage(ChatViewModel viewModel) {
    return _messageController.text.trim().isNotEmpty && !viewModel.isSending;
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize(widget.chatId);
    });
  }

  void _sendMessage(ChatViewModel viewModel) async {
    if (!_canSendMessage(viewModel)) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    await viewModel.sendMessage(message);
  }

  void _viewArtifact(Map<String, dynamic> artifact) {
    if (widget.onArtifactView != null) {
      widget.onArtifactView!(artifact);
    }
  }
}
