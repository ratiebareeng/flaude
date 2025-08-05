import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/animated_button.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onStar;
  final bool showActions;

  const ChatListTile({
    super.key,
    required this.chat,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.onRename,
    this.onStar,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final isStarred = chat.metadata?['starred'] == true;

    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isStarred)
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                  if (lastMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      lastMessage.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(chat.updatedAt ?? chat.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.5),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            if (showActions)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename?.call();
                      break;
                    case 'star':
                      onStar?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        const Text('Rename'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'star',
                    child: Row(
                      children: [
                        Icon(
                          isStarred ? Icons.star : Icons.star_border,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(isStarred ? 'Unstar' : 'Star'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
