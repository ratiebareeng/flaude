import 'package:flutter/material.dart';

class ArtifactAddToProjectSection extends StatelessWidget {
  final VoidCallback onAddToProject;

  const ArtifactAddToProjectSection({
    super.key,
    required this.onAddToProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add to Project',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToProject,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add to Knowledge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffbd5d3a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArtifactContent extends StatelessWidget {
  final String content;

  const ArtifactContent({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF262624),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArtifactHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const ArtifactHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.code, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
          ),
        ],
      ),
    );
  }
}

class ArtifactPanel extends StatelessWidget {
  final Map<String, dynamic> artifact;
  final VoidCallback onClose;
  final bool showAddToProject;
  final VoidCallback? onAddToProject;

  const ArtifactPanel({
    super.key,
    required this.artifact,
    required this.onClose,
    this.showAddToProject = false,
    this.onAddToProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      color: const Color(0xFF30302E),
      child: Column(
        children: [
          ArtifactHeader(
            title: artifact['title'] ?? 'Artifact',
            onClose: onClose,
          ),
          Expanded(
            child: ArtifactContent(
              content: artifact['content'] ??
                  'Artifact content would be displayed here',
            ),
          ),
          if (showAddToProject && onAddToProject != null)
            ArtifactAddToProjectSection(
              onAddToProject: onAddToProject!,
            ),
        ],
      ),
    );
  }
}
