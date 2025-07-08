import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:claude_chat_clone/ui/viewmodels/chats_viewmodel.dart';
import 'package:claude_chat_clone/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {
  final Function(String chatId)? onChatSelected;
  final VoidCallback? onNewChatPressed;

  const ChatsScreen({
    super.key,
    this.onChatSelected,
    this.onNewChatPressed,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late ChatsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ChatsViewModel>(context, listen: false);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  Widget _buildChatCount(int count) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        children: [
          TextSpan(text: 'You have '),
          TextSpan(
            text: '$count',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(text: ' previous chats with Claude. '),
          TextSpan(
            text: 'Select',
            style: TextStyle(
              color: Color(0xFFBD5D3A),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFBD5D3A),
            ),
          );
        }

        if (viewModel.error != null) {
          return _buildErrorState(viewModel.error!, viewModel);
        }

        if (!viewModel.hasFilteredChats) {
          return _buildEmptyState(viewModel);
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: viewModel.filteredChats.length,
          itemBuilder: (context, index) {
            final chat = viewModel.filteredChats[index];
            return ChatItem(
              // TODO: Implement ChatItem widget
              chat: chat,
              //onTap: () => widget.onChatSelected?.call(chat.id),
              //onAction: (action) => _handleChatAction(action, chat),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ChatsViewModel viewModel) {
    final hasSearchQuery = viewModel.searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.chat_outlined,
            color: Colors.grey[400],
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'No chats found matching "${viewModel.searchQuery}"'
                : 'No chats yet',
            style: TextStyle(fontSize: 16),
          ),
          if (!hasSearchQuery) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onNewChatTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBD5D3A),
                foregroundColor: Colors.white,
              ),
              child: Text('Start your first chat'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ChatsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey[400],
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.refreshChats(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFBD5D3A),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ChatsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and New Chat Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your chat history',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          wordSpacing: 3,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _onNewChatTap,
                    icon: Icon(Icons.add, size: 18),
                    label: Text('New chat'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(),

              SizedBox(height: 16),

              // Chat Count
              if (!viewModel.isLoading && viewModel.error == null)
                _buildChatCount(viewModel.allChats.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _searchFocusNode.hasFocus ? Color(0xFFBD5D3A) : Color(0xFF3A3A3A),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search your chats...',
          hintStyle: TextStyle(fontSize: 16),
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _handleChatAction(String action, Chat chat) {
    switch (action) {
      case 'rename':
        _showRenameDialog(chat);
        break;
      case 'delete':
        _showDeleteDialog(chat);
        break;
    }
  }

  void _onNewChatTap() {
    widget.onNewChatPressed?.call();
  }

  void _onSearchChanged() {
    _viewModel.searchChats(_searchController.text);
  }

  void _showDeleteDialog(Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Delete Chat'),
        content: Text(
          'Are you sure you want to delete "${chat.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await _viewModel.deleteChat(chat.id);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(Chat chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Rename Chat'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBD5D3A)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final success = await _viewModel.renameChat(chat.id, newTitle);
                if (success && mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Rename', style: TextStyle(color: Color(0xFFBD5D3A))),
          ),
        ],
      ),
    );
  }
}
