import 'package:claude_chat_clone/ui/viewmodels/chat_viewmodel.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/old/greeting_widget.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/old/large_input_field.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/old/suggestion_chips.dart';
import 'package:flutter/material.dart';

class NewChatCard extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final ChatViewModel chatViewModel;
  final Function sendMessage;
  const NewChatCard(
      {super.key,
      required this.messageController,
      required this.messageFocusNode,
      required this.chatViewModel,
      required this.sendMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GreetingWidget(),
            const SizedBox(height: 48),
            LargeInputField(
              messageController: messageController,
              messageFocusNode: messageFocusNode,
              sendMessage: sendMessage,
            ),
            const SizedBox(height: 16),
            SuggestionChips(viewModel: chatViewModel),
          ],
        ),
      ),
    );
  }
}
