import 'package:claude_chat_clone/ui/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';

class SuggestionChips extends StatelessWidget {
  final ChatViewModel viewModel;
  const SuggestionChips({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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

  Widget _buildSuggestionChip(
      String title, String subtitle, ChatViewModel viewModel) {
    return InkWell(
      onTap: () async => await viewModel.sendSuggestion(subtitle),
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
}
