import 'package:flutter/material.dart';

class ArtifactPreview extends StatelessWidget {
  final Map<String, dynamic> artifact;
  final Function(Map<String, dynamic>?)? viewArtifact;
  const ArtifactPreview(
      {super.key, required this.artifact, required this.viewArtifact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.code, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    artifact['title'] ?? 'Artifact',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => viewArtifact,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFCD7F32),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              artifact['content']?.substring(0, 100) ?? 'No preview available',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Consolas',
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
