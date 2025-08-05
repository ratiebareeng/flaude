import 'package:claude_chat_clone/ui/blocs/blocs.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/ai_model_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String>? onSendMessage;
  final bool enabled;
  final String? hintText;

  const ChatInput({
    super.key,
    this.onSendMessage,
    this.enabled = true,
    this.hintText,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(),
          _buildToolbar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_handleTextChanged);
  }

  Widget _buildInputField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      maxLines: null,
      minLines: 1,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onSubmitted: (_) => _handleSend(),
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'How can I help you today?',
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        const SizedBox(width: 8),
        BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppReady) {
              return AIModelDropdown(
                selectedModel: state.selectedModel,
                enabled: widget.enabled,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const Spacer(),
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final isLoading =
                state is ChatSendingMessage || state is ChatAIResponding;

            return IconButton(
              onPressed: isLoading ? null : _handleSend,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.arrow_upward,
                      color: _isComposing && widget.enabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    ),
            );
          },
        ),
      ],
    );
  }

  void _handleSend() {
    if (_isComposing && widget.enabled) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        widget.onSendMessage?.call(text);
        _controller.clear();
        setState(() {
          _isComposing = false;
        });
      }
    }
  }

  void _handleTextChanged() {
    setState(() {
      _isComposing = _controller.text.trim().isNotEmpty;
    });
  }
}
