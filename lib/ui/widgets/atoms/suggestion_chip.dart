import 'package:flutter/material.dart';

class SuggestionChip {
  final String emoji;
  final String title;
  final String prompt;

  const SuggestionChip({
    required this.emoji,
    required this.title,
    required this.prompt,
  });
}

class SuggestionChipWidget extends StatelessWidget {
  final SuggestionChip suggestion;
  final VoidCallback? onTap;

  const SuggestionChipWidget({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${suggestion.emoji} ${suggestion.title}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.prompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
