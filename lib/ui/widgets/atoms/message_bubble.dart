import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final VoidCallback? onArtifactTap;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.onArtifactTap,
    this.onCopy,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser && showAvatar) ...[
            _buildAvatar(context, isUser: false),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageContainer(context),
                const SizedBox(height: 8),
                _buildTimestamp(context),
              ],
            ),
          ),
          if (message.isUser && showAvatar) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          iconSize: 16,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        if (onRegenerate != null)
          IconButton(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh, size: 16),
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  Widget _buildArtifactPreview(Artifact artifact) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getArtifactIcon(artifact.artifactType),
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    artifact.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onArtifactTap,
                  child: const Text('View'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              artifact.content.length > 100
                  ? '${artifact.content.substring(0, 100)}...'
                  : artifact.content,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        color: isUser
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onPrimary,
        size: 18,
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: message.isUser
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isStreaming) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                const TypingIndicator(size: 4),
              ],
            ),
          ] else ...[
            SelectableText(
              message.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
          if (message.hasArtifacts) ...[
            const SizedBox(height: 12),
            ...message.artifacts!.map(_buildArtifactPreview),
          ],
          if (!message.isUser && !message.isStreaming) ...[
            const SizedBox(height: 8),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Text(
      _formatTimestamp(message.timestamp),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getArtifactIcon(ArtifactType type) {
    switch (type) {
      case ArtifactType.code:
        return Icons.code;
      case ArtifactType.html:
        return Icons.web;
      case ArtifactType.markdown:
        return Icons.description;
      case ArtifactType.react:
        return Icons.widgets;
      case ArtifactType.svg:
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
