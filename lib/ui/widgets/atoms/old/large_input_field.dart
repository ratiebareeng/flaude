import 'package:claude_chat_clone/domain/models/ai_models_list.dart';
import 'package:claude_chat_clone/ui/viewmodels/chat_viewmodel.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/old/ai_model_dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LargeInputField extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final Function sendMessage;

  const LargeInputField({
    super.key,
    required this.messageController,
    required this.messageFocusNode,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: messageController,
            focusNode: messageFocusNode,
            maxLines: null,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onSubmitted: (_) => sendMessage,
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
                onPressed: () => sendMessage,
                icon: Consumer<ChatViewModel>(builder: (_, viewModel, __) {
                  return Icon(
                    Icons.arrow_upward_rounded,
                    color: (messageController.text.trim().isNotEmpty &&
                            !viewModel.isSending)
                        ? Colors.white
                        : Colors.grey[600],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
