import 'dart:async';

import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chats_event.dart';
import 'chats_state.dart';

/// BLoC for managing chats list state
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetChats _getChats;
  final CreateChat _createChat;
  final UpdateChat _updateChat;
  final DeleteChat _deleteChat;
  final SearchChats _searchChats;
  final WatchChats _watchChats;

  StreamSubscription? _chatsSubscription;

  ChatsBloc({
    required GetChats getChats,
    required CreateChat createChat,
    required UpdateChat updateChat,
    required DeleteChat deleteChat,
    required SearchChats searchChats,
    required WatchChats watchChats,
  })  : _getChats = getChats,
        _createChat = createChat,
        _updateChat = updateChat,
        _deleteChat = deleteChat,
        _searchChats = searchChats,
        _watchChats = watchChats,
        super(const ChatsInitial()) {
    on<ChatsInitialized>(_onChatsInitialized);
    on<ChatsLoadedEvent>(_onChatsLoaded);
    on<ChatsRecentLoaded>(_onRecentChatsLoaded);
    on<ChatsProjectLoaded>(_onProjectChatsLoaded);
    on<ChatsSearched>(_onChatsSearched);
    on<ChatsSearchCleared>(_onSearchCleared);
    on<ChatCreated>(_onChatCreated);
    on<ChatDeleted>(_onChatDeleted);
    on<ChatUpdated>(_onChatUpdated);
    on<ChatRenamed>(_onChatRenamed);
    on<ChatArchived>(_onChatArchived);
    on<ChatRestored>(_onChatRestored);
    on<ChatStarred>(_onChatStarred);
    on<ChatUnstarred>(_onChatUnstarred);
    on<ChatPinned>(_onChatPinned);
    on<ChatUnpinned>(_onChatUnpinned);
    on<ChatDuplicated>(_onChatDuplicated);
    on<ChatsExportedEvent>(_onChatsExported);
    on<ChatsImported>(_onChatsImported);
    on<ChatsSorted>(_onChatsSorted);
    on<ChatsFiltered>(_onChatsFiltered);
    on<ChatsFiltersCleared>(_onFiltersCleared);
    on<ChatsMultiSelected>(_onMultiSelected);
    on<ChatsMultiSelectionCleared>(_onMultiSelectionCleared);
    on<ChatsBulkAction>(_onBulkAction);
    on<ChatsRefreshed>(_onChatsRefreshed);
    on<ChatsSubscriptionStarted>(_onSubscriptionStarted);
    on<ChatsSubscriptionStopped>(_onSubscriptionStopped);
    on<ChatsReceived>(_onChatsReceived);
    on<ChatsStatisticsRequested>(_onStatisticsRequested);
    on<ChatsPaginated>(_onChatsPaginated);
    on<ChatsErrorOccurred>(_onErrorOccurred);
    on<ChatsErrorCleared>(_onErrorCleared);
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }

  /// Apply filters and sorting to chats
  List<Chat> _applyFiltersAndSort(
    List<Chat> chats,
    ChatsLoaded currentState, [
    ChatsSortConfig? sortConfig,
    ChatsFilterConfig? filterConfig,
  ]) {
    final sort = sortConfig ?? currentState.sortConfig;
    final filter = filterConfig ?? currentState.filterConfig;

    // Apply filters
    var filteredChats = chats.where((chat) {
      if (filter.projectId != null && chat.projectId != filter.projectId) {
        return false;
      }
      if (filter.hasMessages != null &&
          (chat.hasMessages != filter.hasMessages)) {
        return false;
      }
      if (filter.isStarred != null &&
          (chat.metadata?['starred'] != filter.isStarred)) {
        return false;
      }
      if (filter.isPinned != null &&
          (chat.metadata?['pinned'] != filter.isPinned)) {
        return false;
      }
      if (filter.isArchived != null &&
          (chat.metadata?['archived'] != filter.isArchived)) {
        return false;
      }
      if (filter.createdAfter != null &&
          chat.createdAt.isBefore(filter.createdAfter!)) {
        return false;
      }
      if (filter.createdBefore != null &&
          chat.createdAt.isAfter(filter.createdBefore!)) {
        return false;
      }
      return true;
    }).toList();

    // Apply sorting
    filteredChats.sort((a, b) {
      int comparison;
      switch (sort.sortBy) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updated':
          comparison = (a.updatedAt ?? a.createdAt)
              .compareTo(b.updatedAt ?? b.createdAt);
          break;
        case 'messageCount':
          comparison = a.messageCount.compareTo(b.messageCount);
          break;
        default:
          comparison = (a.updatedAt ?? a.createdAt)
              .compareTo(b.updatedAt ?? b.createdAt);
      }
      return sort.ascending ? comparison : -comparison;
    });

    return filteredChats;
  }

  /// Calculate statistics from chats
  ChatsStatistics _calculateStatistics(List<Chat> chats) {
    final totalMessages =
        chats.fold<int>(0, (sum, chat) => sum + chat.messageCount);
    final starredCount =
        chats.where((chat) => chat.metadata?['starred'] == true).length;
    final pinnedCount =
        chats.where((chat) => chat.metadata?['pinned'] == true).length;
    final archivedCount =
        chats.where((chat) => chat.metadata?['archived'] == true).length;
    final chatsWithArtifacts =
        chats.where((chat) => chat.hasMessages).length; // Simplified

    final chatsByProject = <String, int>{};
    for (final chat in chats) {
      if (chat.projectId != null) {
        chatsByProject[chat.projectId!] =
            (chatsByProject[chat.projectId!] ?? 0) + 1;
      }
    }

    final messagesByMonth = <String, int>{}; // Simplified implementation

    final oldestChat = chats.isEmpty
        ? null
        : chats.reduce(
            (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
          );
    final newestChat = chats.isEmpty
        ? null
        : chats.reduce(
            (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
          );

    final averageMessages =
        chats.isNotEmpty ? totalMessages / chats.length : 0.0;

    return ChatsStatistics(
      totalChats: chats.length,
      totalMessages: totalMessages,
      starredChats: starredCount,
      pinnedChats: pinnedCount,
      archivedChats: archivedCount,
      chatsWithArtifacts: chatsWithArtifacts,
      chatsByProject: chatsByProject,
      messagesByMonth: messagesByMonth,
      oldestChatDate: oldestChat?.createdAt,
      newestChatDate: newestChat?.createdAt,
      averageMessagesPerChat: averageMessages,
    );
  }

  /// Perform bulk action
  Future<void> _onBulkAction(
    ChatsBulkAction event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(ChatsBulkOperating(
      operation: event.action,
      chatIds: event.chatIds,
      progress: 0,
      total: event.chatIds.length,
    ));

    try {
      for (int i = 0; i < event.chatIds.length; i++) {
        final chatId = event.chatIds[i];

        switch (event.action) {
          case 'delete':
            await _deleteChat.call(DeleteChatParams(chatId: chatId));
            break;
          case 'archive':
            add(ChatArchived(chatId));
            break;
          case 'star':
            add(ChatStarred(chatId));
            break;
          case 'unstar':
            add(ChatUnstarred(chatId));
            break;
        }

        emit(ChatsBulkOperating(
          operation: event.action,
          chatIds: event.chatIds,
          progress: i + 1,
          total: event.chatIds.length,
        ));
      }

      // Reload chats after bulk operation
      add(const ChatsRefreshed());
    } catch (e) {
      emit(ChatsError(
        message: 'Bulk operation failed',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Archive a chat
  Future<void> _onChatArchived(
    ChatArchived event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'archived': true}, emit);
  }

  /// Create a new chat
  Future<void> _onChatCreated(
    ChatCreated event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(ChatsCreating(title: event.title, projectId: event.projectId));

    try {
      final now = DateTime.now();
      final chat = Chat(
        id: '', // Will be assigned by repository
        title: event.title,
        description: event.description,
        messages: [],
        createdAt: now,
        updatedAt: now,
        projectId: event.projectId,
      );

      final result = await _createChat.call(CreateChatParams(chat: chat));

      result.fold(
        (failure) => emit(ChatsError(
          message: 'Failed to create chat',
          details: failure.message,
          previousState: currentState,
        )),
        (chatId) {
          final createdChat = chat.copyWith(id: chatId);
          final updatedChats = [createdChat, ...currentState.allChats];

          emit(currentState.copyWith(
            allChats: updatedChats,
            filteredChats: _applyFiltersAndSort(updatedChats, currentState),
          ));
        },
      );
    } catch (e) {
      emit(ChatsError(
        message: 'Unexpected error creating chat',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Delete a chat
  Future<void> _onChatDeleted(
    ChatDeleted event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final chatToDelete = currentState.allChats.firstWhere(
      (chat) => chat.id == event.chatId,
      orElse: () => throw Exception('Chat not found'),
    );

    final remainingChats =
        currentState.allChats.where((chat) => chat.id != event.chatId).toList();

    emit(ChatsDeleting(chatId: event.chatId, remainingChats: remainingChats));

    final result =
        await _deleteChat.call(DeleteChatParams(chatId: event.chatId));

    result.fold(
      (failure) => emit(ChatsError(
        message: 'Failed to delete chat',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(
        allChats: remainingChats,
        filteredChats: _applyFiltersAndSort(remainingChats, currentState),
        recentChats: currentState.recentChats
            .where((chat) => chat.id != event.chatId)
            .toList(),
        starredChats: currentState.starredChats
            .where((chat) => chat.id != event.chatId)
            .toList(),
        pinnedChats: currentState.pinnedChats
            .where((chat) => chat.id != event.chatId)
            .toList(),
      )),
    );
  }

  void _onChatDuplicated(ChatDuplicated event, Emitter<ChatsState> emit) {
    // Implementation for duplicating chat
  }

  /// Pin a chat
  Future<void> _onChatPinned(
    ChatPinned event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'pinned': true}, emit);
  }

  /// Rename a chat
  Future<void> _onChatRenamed(
    ChatRenamed event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final chatIndex = currentState.allChats.indexWhere(
      (chat) => chat.id == event.chatId,
    );

    if (chatIndex == -1) {
      emit(ChatsError(
        message: 'Chat not found',
        previousState: currentState,
      ));
      return;
    }

    final originalChat = currentState.allChats[chatIndex];
    final updatedChat = originalChat.copyWith(
      title: event.newTitle,
      updatedAt: DateTime.now(),
    );

    emit(ChatsUpdating(updatedChat));

    final result = await _updateChat.call(UpdateChatParams(chat: updatedChat));

    result.fold(
      (failure) => emit(ChatsError(
        message: 'Failed to rename chat',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final updatedChats = List<Chat>.from(currentState.allChats);
        updatedChats[chatIndex] = updatedChat;

        emit(currentState.copyWith(
          allChats: updatedChats,
          filteredChats: _applyFiltersAndSort(updatedChats, currentState),
        ));
      },
    );
  }

  /// Restore an archived chat
  Future<void> _onChatRestored(
    ChatRestored event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'archived': false}, emit);
  }

  void _onChatsExported(ChatsExportedEvent event, Emitter<ChatsState> emit) {
    // Implementation for exporting chats
  }

  /// Filter chats
  void _onChatsFiltered(
    ChatsFiltered event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;
    final newFilterConfig = currentState.filterConfig.copyWith(
      projectId: event.projectId,
      hasMessages: event.hasMessages,
      isStarred: event.isStarred,
      isPinned: event.isPinned,
      createdAfter: event.createdAfter,
      createdBefore: event.createdBefore,
    );

    emit(currentState.copyWith(
      filterConfig: newFilterConfig,
      filteredChats: _applyFiltersAndSort(
          currentState.allChats, currentState, null, newFilterConfig),
    ));
  }

  void _onChatsImported(ChatsImported event, Emitter<ChatsState> emit) {
    // Implementation for importing chats
  }

  /// Initialize chats list
  Future<void> _onChatsInitialized(
    ChatsInitialized event,
    Emitter<ChatsState> emit,
  ) async {
    emit(const ChatsLoading());
    add(const ChatsLoadedEvent());
  }

  /// Load all chats
  Future<void> _onChatsLoaded(
    ChatsLoadedEvent event,
    Emitter<ChatsState> emit,
  ) async {
    try {
      final result =
          await _getChats.call(const GetChatsParams(type: GetChatsType.all));

      await result.fold(
        (failure) async {
          emit(ChatsError(
            message: 'Failed to load chats',
            details: failure.message,
          ));
        },
        (chats) async {
          // Load recent chats
          final recentResult = await _getChats.call(
            const GetChatsParams(type: GetChatsType.recent, limit: 10),
          );

          final recentChats = await recentResult.fold(
            (failure) async => <Chat>[],
            (recent) async => recent,
          );

          // Separate starred and pinned chats
          final starredChats =
              chats.where((chat) => chat.metadata?['starred'] == true).toList();
          final pinnedChats =
              chats.where((chat) => chat.metadata?['pinned'] == true).toList();

          emit(ChatsLoaded(
            allChats: chats,
            filteredChats: chats,
            recentChats: recentChats,
            starredChats: starredChats,
            pinnedChats: pinnedChats,
          ));

          // Start listening for real-time updates
          add(const ChatsSubscriptionStarted());
        },
      );
    } catch (e) {
      emit(ChatsError(
        message: 'Unexpected error loading chats',
        details: e.toString(),
      ));
    }
  }

  void _onChatsPaginated(ChatsPaginated event, Emitter<ChatsState> emit) {
    // Implementation for pagination
  }

  /// Handle received chats from subscription
  void _onChatsReceived(
    ChatsReceived event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final starredChats =
        event.chats.where((chat) => chat.metadata?['starred'] == true).toList();
    final pinnedChats =
        event.chats.where((chat) => chat.metadata?['pinned'] == true).toList();

    emit(currentState.copyWith(
      allChats: event.chats,
      filteredChats: _applyFiltersAndSort(event.chats, currentState),
      starredChats: starredChats,
      pinnedChats: pinnedChats,
    ));
  }

  /// Refresh chats
  void _onChatsRefreshed(
    ChatsRefreshed event,
    Emitter<ChatsState> emit,
  ) {
    add(const ChatsLoadedEvent());
  }

  /// Search chats
  Future<void> _onChatsSearched(
    ChatsSearched event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(clearSearch: true));
      return;
    }

    try {
      final result = await _searchChats.call(
        SearchChatsParams(
          query: event.query,
          projectId: event.projectId,
        ),
      );

      result.fold(
        (failure) => emit(ChatsError(
          message: 'Failed to search chats',
          details: failure.message,
          previousState: currentState,
        )),
        (searchResults) => emit(currentState.copyWith(
          filteredChats: searchResults,
          searchQuery: event.query,
        )),
      );
    } catch (e) {
      emit(ChatsError(
        message: 'Search failed',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Sort chats
  void _onChatsSorted(
    ChatsSorted event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;
    final newSortConfig = ChatsSortConfig(
      sortBy: event.sortBy,
      ascending: event.ascending,
    );

    emit(currentState.copyWith(
      sortConfig: newSortConfig,
      filteredChats: _applyFiltersAndSort(
          currentState.allChats, currentState, newSortConfig),
    ));
  }

  /// Star a chat
  Future<void> _onChatStarred(
    ChatStarred event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'starred': true}, emit);
  }

  /// Unpin a chat
  Future<void> _onChatUnpinned(
    ChatUnpinned event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'pinned': false}, emit);
  }

  /// Unstar a chat
  Future<void> _onChatUnstarred(
    ChatUnstarred event,
    Emitter<ChatsState> emit,
  ) async {
    await _updateChatMetadata(event.chatId, {'starred': false}, emit);
  }

  // Placeholder implementations for remaining events
  void _onChatUpdated(ChatUpdated event, Emitter<ChatsState> emit) {
    // Implementation for updating chat
  }

  /// Clear errors
  void _onErrorCleared(
    ChatsErrorCleared event,
    Emitter<ChatsState> emit,
  ) {
    if (state is ChatsError) {
      final errorState = state as ChatsError;
      if (errorState.previousState != null) {
        emit(errorState.previousState!);
      } else {
        emit(const ChatsInitial());
        add(const ChatsInitialized());
      }
    }
  }

  /// Handle errors
  void _onErrorOccurred(
    ChatsErrorOccurred event,
    Emitter<ChatsState> emit,
  ) {
    emit(ChatsError(
      message: event.message,
      details: event.details,
      previousState: state is ChatsError ? null : state,
    ));
  }

  /// Clear filters
  void _onFiltersCleared(
    ChatsFiltersCleared event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(currentState.copyWith(
      clearFilters: true,
      filteredChats: _applyFiltersAndSort(
          currentState.allChats, currentState, null, const ChatsFilterConfig()),
    ));
  }

  /// Multi-select chats
  void _onMultiSelected(
    ChatsMultiSelected event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(currentState.copyWith(
      selectedChatIds: event.chatIds,
      isMultiSelectMode: event.chatIds.isNotEmpty,
    ));
  }

  /// Clear multi-selection
  void _onMultiSelectionCleared(
    ChatsMultiSelectionCleared event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(currentState.copyWith(clearSelection: true));
  }

  /// Load chats for a specific project
  Future<void> _onProjectChatsLoaded(
    ChatsProjectLoaded event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final result = await _getChats.call(
      GetChatsParams(type: GetChatsType.project, projectId: event.projectId),
    );

    result.fold(
      (failure) => emit(ChatsError(
        message: 'Failed to load project chats',
        details: failure.message,
        previousState: currentState,
      )),
      (projectChats) {
        final updatedFilter = currentState.filterConfig.copyWith(
          projectId: event.projectId,
        );
        emit(currentState.copyWith(
          filteredChats: projectChats,
          filterConfig: updatedFilter,
        ));
      },
    );
  }

  /// Load recent chats
  Future<void> _onRecentChatsLoaded(
    ChatsRecentLoaded event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final result = await _getChats.call(
      GetChatsParams(type: GetChatsType.recent, limit: event.limit),
    );

    result.fold(
      (failure) => emit(ChatsError(
        message: 'Failed to load recent chats',
        details: failure.message,
        previousState: currentState,
      )),
      (recentChats) => emit(currentState.copyWith(recentChats: recentChats)),
    );
  }

  /// Clear search
  void _onSearchCleared(
    ChatsSearchCleared event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    emit(currentState.copyWith(
      filteredChats: currentState.allChats,
      clearSearch: true,
    ));
  }

  /// Get statistics
  Future<void> _onStatisticsRequested(
    ChatsStatisticsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    try {
      final chatsToAnalyze = event.projectId != null
          ? currentState.allChats
              .where((chat) => chat.projectId == event.projectId)
              .toList()
          : currentState.allChats;

      final statistics = _calculateStatistics(chatsToAnalyze);

      emit(currentState.copyWith(statistics: statistics));
    } catch (e) {
      emit(ChatsError(
        message: 'Failed to calculate statistics',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Start listening to real-time chat updates
  void _onSubscriptionStarted(
    ChatsSubscriptionStarted event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    _chatsSubscription?.cancel();

    final watchParams = event.projectId != null
        ? WatchChatsParams(
            type: WatchChatsType.project, projectId: event.projectId)
        : const WatchChatsParams(type: WatchChatsType.all);

    _chatsSubscription = _watchChats.call(watchParams).listen(
      (result) {
        result.fold(
          (failure) => add(ChatsErrorOccurred(
            'Lost connection to chats',
            details: failure.message,
          )),
          (chats) => add(ChatsReceived(chats)),
        );
      },
    );

    emit(currentState.copyWith(isListening: true));
  }

  /// Stop listening to real-time updates
  void _onSubscriptionStopped(
    ChatsSubscriptionStopped event,
    Emitter<ChatsState> emit,
  ) {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    _chatsSubscription?.cancel();
    _chatsSubscription = null;

    emit(currentState.copyWith(isListening: false));
  }

  /// Helper method to update chat metadata
  Future<void> _updateChatMetadata(
    String chatId,
    Map<String, dynamic> metadataUpdate,
    Emitter<ChatsState> emit,
  ) async {
    if (state is! ChatsLoaded) return;

    final currentState = state as ChatsLoaded;

    final chatIndex = currentState.allChats.indexWhere(
      (chat) => chat.id == chatId,
    );

    if (chatIndex == -1) return;

    final originalChat = currentState.allChats[chatIndex];
    final updatedMetadata =
        Map<String, dynamic>.from(originalChat.metadata ?? {});
    updatedMetadata.addAll(metadataUpdate);

    final updatedChat = originalChat.copyWith(
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );

    final result = await _updateChat.call(UpdateChatParams(chat: updatedChat));

    result.fold(
      (failure) => emit(ChatsError(
        message: 'Failed to update chat',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final updatedChats = List<Chat>.from(currentState.allChats);
        updatedChats[chatIndex] = updatedChat;

        // Update specialized lists
        final starredChats = updatedChats
            .where((chat) => chat.metadata?['starred'] == true)
            .toList();
        final pinnedChats = updatedChats
            .where((chat) => chat.metadata?['pinned'] == true)
            .toList();

        emit(currentState.copyWith(
          allChats: updatedChats,
          filteredChats: _applyFiltersAndSort(updatedChats, currentState),
          starredChats: starredChats,
          pinnedChats: pinnedChats,
        ));
      },
    );
  }
}
