import 'package:claude_chat_clone/plugins/error_manager/error_manager.dart';
import 'package:claude_chat_clone/viewmodels/home_viewmodel.dart';
import 'package:claude_chat_clone/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..initialize(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (viewModel.error != null) {
          return SimpleErrorPage(
            errorMessage: viewModel.error!,
            stackTrace: null, // You can pass the stack trace if available
          );
        }

        return Scaffold(
          body: Row(
            children: [
              // Left Navigation Drawer
              NavigationDrawerWidget(
                currentView: viewModel.currentView,
                starredChats: viewModel.starredChats,
                recentChats: viewModel.recentChats,
                onMenuItemSelected: viewModel.changeView,
              ),

              // Main Content Area
              Expanded(
                child: _buildMainContent(context, viewModel),
              ),

              // Right Artifact Panel (conditional)
              _buildArtifactPanel(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtifactPanel(BuildContext context, HomeViewModel viewModel) {
    if (!viewModel.showArtifactDetail || viewModel.currentArtifact == null) {
      return const SizedBox.shrink();
    }

    return ArtifactPanel(
      artifact: viewModel.currentArtifact!,
      onClose: () => viewModel.handleArtifactView(null),
      showAddToProject: viewModel.currentView == 'chat',
      onAddToProject: () async {
        await viewModel.addArtifactToProject();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artifact added to project knowledge'),
              backgroundColor: Color(0xffbd5d3a),
            ),
          );
        }
      },
    );
  }

  Widget _buildMainContent(BuildContext context, HomeViewModel viewModel) {
    switch (viewModel.currentView) {
      case 'projects':
        return const ProjectsScreen();
      case 'new_chat':
        return ChatScreen(
          key: const ValueKey('new_chat'),
          chatId: null,
          onArtifactView: viewModel.handleArtifactView,
        );
      case 'chat':
        return ChatScreen(
          key: ValueKey(viewModel.selectedChatId ?? 'new_chat'),
          chatId: viewModel.selectedChatId,
          onArtifactView: viewModel.handleArtifactView,
        );
      case 'chats':
        return ChatsScreen(
          onChatSelected: viewModel.selectChat,
          onNewChatPressed: viewModel.createNewChat,
        );
      default:
        return Center(
          child: Text('No implementation for view: ${viewModel.currentView}'),
        );
    }
  }
}
