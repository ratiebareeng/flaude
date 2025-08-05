import 'package:flutter/material.dart';

class AdaptiveDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;

  const AdaptiveDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return AlertDialog(
            title: title != null ? Text(title!) : null,
            content:
                scrollable ? SingleChildScrollView(child: content) : content,
            actions: actions,
          );
        } else {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
              ),
              body:
                  scrollable ? SingleChildScrollView(child: content) : content,
            ),
          );
        }
      },
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool scrollable = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        actions: actions,
        scrollable: scrollable,
      ),
    );
  }
}
