import 'package:claude_chat_clone/ui/blocs/blocs.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/atoms.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/chat_item.dart';
import 'package:claude_chat_clone/ui/widgets/atoms/navigation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationDrawer extends StatefulWidget {
  final String currentRoute;
  final ValueChanged<String>? onRouteChanged;
  final ValueChanged<String>? onChatSelected;

  const NavigationDrawer({
    super.key,
    required this.currentRoute,
    this.onRouteChanged,
    this.onChatSelected,
  });

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExpanded ? 300 : 80,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(),
          _buildNewChatButton(),
          const Divider(),
          _buildNavigationItems(),
          const Divider(),
          Expanded(child: _buildChatsList()),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        if (state is ChatsLoaded) {
          return ListView(
            children: [
              if (_isExpanded && state.pinnedChats.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Pinned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ),
                ...state.pinnedChats.map((chat) => ChatItem(
                      chat: chat,
                      onTap: () => widget.onChatSelected?.call(chat.id),
                    )),
              ],
              if (_isExpanded && state.recentChats.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Recent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ),
                ...state.recentChats.take(10).map((chat) => ChatItem(
                      chat: chat,
                      onTap: () => widget.onChatSelected?.call(chat.id),
                    )),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu),
          ),
          if (_isExpanded) ...[
            const SizedBox(width: 12),
            const AppTitle(title: 'Claude Clone'),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems() {
    final items = [
      NavigationItem(
        icon: Icons.chat_outlined,
        title: 'Chats',
        route: '/chats',
      ),
      NavigationItem(
        icon: Icons.folder_outlined,
        title: 'Projects',
        route: '/projects',
      ),
    ];

    return Column(
      children: items.map((item) {
        final isSelected = widget.currentRoute == item.route;
        return ListTile(
          leading: Icon(
            item.icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          title: _isExpanded ? Text(item.title) : null,
          selected: isSelected,
          onTap: () => widget.onRouteChanged?.call(item.route),
        );
      }).toList(),
    );
  }

  Widget _buildNewChatButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => widget.onRouteChanged?.call('/new-chat'),
          icon: const Icon(Icons.add),
          label: _isExpanded ? const Text('New Chat') : Text('Chat'),
          style: ElevatedButton.styleFrom(
            alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
          ),
        ),
      ),
    );
  }
}
