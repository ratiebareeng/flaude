import 'package:claude_chat_clone/ui/widgets/atoms/suggestion_chip.dart';
import 'package:flutter/material.dart';

class SuggestionChips extends StatelessWidget {
  static List<SuggestionChip> get defaultSuggestions => [
        const SuggestionChip(
          emoji: '✏️',
          title: 'Write',
          prompt: 'Draft an email to my team',
        ),
        const SuggestionChip(
          emoji: '📚',
          title: 'Learn',
          prompt: 'Explain quantum computing',
        ),
        const SuggestionChip(
          emoji: '💻',
          title: 'Code',
          prompt: 'Build a Flutter app',
        ),
        const SuggestionChip(
          emoji: '☕',
          title: 'Life stuff',
          prompt: 'Plan my weekend',
        ),
        const SuggestionChip(
          emoji: '🎲',
          title: 'Claude\'s choice',
          prompt: 'Surprise me',
        ),
      ];
  final List<SuggestionChip> suggestions;

  final ValueChanged<String>? onSuggestionTapped;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: suggestions.map((suggestion) {
        return SuggestionChipWidget(
          suggestion: suggestion,
          onTap: () => onSuggestionTapped?.call(suggestion.prompt),
        );
      }).toList(),
    );
  }
}
