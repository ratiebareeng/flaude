import 'package:claude_chat_clone/ui/widgets/organisms/organisms.dart' as org;
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final ValueChanged<String>? onRouteChanged;
  final ValueChanged<String>? onChatSelected;
  final bool showDrawer;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    this.onRouteChanged,
    this.onChatSelected,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (showDrawer)
            org.NavigationDrawer(
              currentRoute: currentRoute,
              onRouteChanged: onRouteChanged,
              onChatSelected: onChatSelected,
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
