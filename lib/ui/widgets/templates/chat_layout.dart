import 'package:flutter/material.dart';

class ChatLayout extends StatelessWidget {
  final Widget chatView;
  final Widget? artifactPanel;
  final bool showArtifactPanel;

  const ChatLayout({
    super.key,
    required this.chatView,
    this.artifactPanel,
    this.showArtifactPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: showArtifactPanel ? 3 : 1,
          child: chatView,
        ),
        if (showArtifactPanel && artifactPanel != null)
          Expanded(
            flex: 2,
            child: artifactPanel!,
          ),
      ],
    );
  }
}
