import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtifactPanel extends StatelessWidget {
  final Artifact artifact;
  final VoidCallback? onClose;
  final VoidCallback? onAddToProject;
  final bool showAddToProject;

  const ArtifactPanel({
    super.key,
    required this.artifact,
    this.onClose,
    this.onAddToProject,
    this.showAddToProject = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent(context)),
          if (showAddToProject) _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add to Project',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onAddToProject,
            icon: const Icon(Icons.add),
            label: const Text('Add to Knowledge'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        artifact.content,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getArtifactIcon(artifact.artifactType),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              artifact.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: artifact.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
        ],
      ),
    );
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
