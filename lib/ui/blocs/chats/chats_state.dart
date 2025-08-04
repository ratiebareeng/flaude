import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

/// State when performing bulk operations
class ChatsBulkOperating extends ChatsState {
  final String operation;
  final List<String> chatIds;
  final int progress;
  final int total;

  const ChatsBulkOperating({
    required this.operation,
    required this.chatIds,
    required this.progress,
    required this.total,
  });

  /// Check if operation is complete
  bool get isComplete => progress >= total;

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;

  @override
  List<Object?> get props => [operation, chatIds, progress, total];
}

/// State when creating a new chat
class ChatsCreating extends ChatsState {
  final String title;
  final String? projectId;

  const ChatsCreating({
    required this.title,
    this.projectId,
  });

  @override
  List<Object?> get props => [title, projectId];
}

/// State when deleting a chat
class ChatsDeleting extends ChatsState {
  final String chatId;
  final List<Chat> remainingChats;

  const ChatsDeleting({
    required this.chatId,
    required this.remainingChats,
  });

  @override
  List<Object?> get props => [chatId, remainingChats];
}

/// State when an error occurs
class ChatsError extends ChatsState {
  final String message;
  final String? details;
  final ChatsState? previousState;
  final String? errorCode;

  const ChatsError({
    required this.message,
    this.details,
    this.previousState,
    this.errorCode,
  });

  /// Check if this is a network error
  bool get isNetworkError =>
      errorCode == 'network' ||
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection');

  /// Check if the error is recoverable
  bool get isRecoverable => isNetworkError;

  /// Check if this is a storage error
  bool get isStorageError =>
      errorCode == 'storage' ||
      message.toLowerCase().contains('storage') ||
      message.toLowerCase().contains('database');

  @override
  List<Object?> get props => [message, details, previousState, errorCode];
}

/// State when export is complete
class ChatsExported extends ChatsState {
  final List<String> chatIds;
  final String format;
  final String exportPath;
  final int exportedCount;

  const ChatsExported({
    required this.chatIds,
    required this.format,
    required this.exportPath,
    required this.exportedCount,
  });

  @override
  List<Object?> get props => [chatIds, format, exportPath, exportedCount];
}

/// State when exporting chats
class ChatsExporting extends ChatsState {
  final List<String> chatIds;
  final String format;
  final int progress;
  final int total;

  const ChatsExporting({
    required this.chatIds,
    required this.format,
    required this.progress,
    required this.total,
  });

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;

  @override
  List<Object?> get props => [chatIds, format, progress, total];
}

/// Configuration for filtering chats
class ChatsFilterConfig extends Equatable {
  final String? projectId;
  final bool? hasMessages;
  final bool? isStarred;
  final bool? isPinned;
  final bool? isArchived;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final List<String>? tags;

  const ChatsFilterConfig({
    this.projectId,
    this.hasMessages,
    this.isStarred,
    this.isPinned,
    this.isArchived,
    this.createdAfter,
    this.createdBefore,
    this.tags,
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      projectId != null ||
      hasMessages != null ||
      isStarred != null ||
      isPinned != null ||
      isArchived != null ||
      createdAfter != null ||
      createdBefore != null ||
      (tags != null && tags!.isNotEmpty);

  @override
  List<Object?> get props => [
        projectId,
        hasMessages,
        isStarred,
        isPinned,
        isArchived,
        createdAfter,
        createdBefore,
        tags,
      ];

  ChatsFilterConfig copyWith({
    String? projectId,
    bool? hasMessages,
    bool? isStarred,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAfter,
    DateTime? createdBefore,
    List<String>? tags,
    bool clearProjectId = false,
    bool clearDates = false,
    bool clearTags = false,
  }) {
    return ChatsFilterConfig(
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      hasMessages: hasMessages ?? this.hasMessages,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAfter: clearDates ? null : (createdAfter ?? this.createdAfter),
      createdBefore: clearDates ? null : (createdBefore ?? this.createdBefore),
      tags: clearTags ? null : (tags ?? this.tags),
    );
  }
}

/// State when import is complete
class ChatsImportedEvents extends ChatsState {
  final String filePath;
  final String format;
  final int importedCount;
  final List<String> importedChatIds;

  const ChatsImportedEvents({
    required this.filePath,
    required this.format,
    required this.importedCount,
    required this.importedChatIds,
  });

  @override
  List<Object?> get props => [filePath, format, importedCount, importedChatIds];
}

/// State when importing chats
class ChatsImporting extends ChatsState {
  final String filePath;
  final String format;
  final int progress;
  final int total;

  const ChatsImporting({
    required this.filePath,
    required this.format,
    required this.progress,
    required this.total,
  });

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;

  @override
  List<Object?> get props => [filePath, format, progress, total];
}

/// Initial state when chats list is first created
class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

/// State when chats are loaded and ready
class ChatsLoaded extends ChatsState {
  final List<Chat> allChats;
  final List<Chat> filteredChats;
  final List<Chat> recentChats;
  final List<Chat> starredChats;
  final List<Chat> pinnedChats;
  final String? searchQuery;
  final bool isListening;
  final ChatsSortConfig sortConfig;
  final ChatsFilterConfig filterConfig;
  final List<String> selectedChatIds;
  final bool isMultiSelectMode;
  final ChatsStatistics? statistics;
  final bool hasMoreChats;
  final int currentPage;

  const ChatsLoaded({
    required this.allChats,
    required this.filteredChats,
    this.recentChats = const [],
    this.starredChats = const [],
    this.pinnedChats = const [],
    this.searchQuery,
    this.isListening = false,
    this.sortConfig = const ChatsSortConfig(),
    this.filterConfig = const ChatsFilterConfig(),
    this.selectedChatIds = const [],
    this.isMultiSelectMode = false,
    this.statistics,
    this.hasMoreChats = false,
    this.currentPage = 0,
  });

  /// Get active (non-archived) chats
  List<Chat> get activeChats {
    return allChats
        .where((chat) => chat.metadata?['archived'] != true)
        .toList();
  }

  /// Get archived chats
  List<Chat> get archivedChats {
    return allChats
        .where((chat) => chat.metadata?['archived'] == true)
        .toList();
  }

  /// Check if all displayed chats are selected
  bool get areAllDisplayedChatsSelected {
    if (displayChats.isEmpty) return false;
    return displayChats.every((chat) => selectedChatIds.contains(chat.id));
  }

  /// Get the effective chats to display (considering search and filters)
  List<Chat> get displayChats {
    if (isSearching) {
      return filteredChats
          .where((chat) =>
              chat.title.toLowerCase().contains(searchQuery!.toLowerCase()) ||
              (chat.description
                      ?.toLowerCase()
                      .contains(searchQuery!.toLowerCase()) ??
                  false))
          .toList();
    }
    return filteredChats;
  }

  /// Check if filters are active
  bool get hasActiveFilters => filterConfig.hasActiveFilters;

  /// Check if there are any chats
  bool get hasChats => allChats.isNotEmpty;

  /// Check if there are filtered chats to display
  bool get hasFilteredChats => filteredChats.isNotEmpty;

  /// Check if search is active
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  @override
  List<Object?> get props => [
        allChats,
        filteredChats,
        recentChats,
        starredChats,
        pinnedChats,
        searchQuery,
        isListening,
        sortConfig,
        filterConfig,
        selectedChatIds,
        isMultiSelectMode,
        statistics,
        hasMoreChats,
        currentPage,
      ];

  /// Get selected chats
  List<Chat> get selectedChats {
    return allChats.where((chat) => selectedChatIds.contains(chat.id)).toList();
  }

  /// Get the total number of chats
  int get totalChats => allChats.length;

  ChatsLoaded copyWith({
    List<Chat>? allChats,
    List<Chat>? filteredChats,
    List<Chat>? recentChats,
    List<Chat>? starredChats,
    List<Chat>? pinnedChats,
    String? searchQuery,
    bool? isListening,
    ChatsSortConfig? sortConfig,
    ChatsFilterConfig? filterConfig,
    List<String>? selectedChatIds,
    bool? isMultiSelectMode,
    ChatsStatistics? statistics,
    bool? hasMoreChats,
    int? currentPage,
    bool clearSearch = false,
    bool clearFilters = false,
    bool clearSelection = false,
  }) {
    return ChatsLoaded(
      allChats: allChats ?? this.allChats,
      filteredChats: filteredChats ?? this.filteredChats,
      recentChats: recentChats ?? this.recentChats,
      starredChats: starredChats ?? this.starredChats,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      isListening: isListening ?? this.isListening,
      sortConfig: sortConfig ?? this.sortConfig,
      filterConfig: clearFilters
          ? const ChatsFilterConfig()
          : (filterConfig ?? this.filterConfig),
      selectedChatIds:
          clearSelection ? [] : (selectedChatIds ?? this.selectedChatIds),
      isMultiSelectMode: clearSelection
          ? false
          : (isMultiSelectMode ?? this.isMultiSelectMode),
      statistics: statistics ?? this.statistics,
      hasMoreChats: hasMoreChats ?? this.hasMoreChats,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  /// Check if a chat is selected
  bool isChatSelected(String chatId) => selectedChatIds.contains(chatId);
}

/// State when chats are being loaded
class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

/// Configuration for sorting chats
class ChatsSortConfig extends Equatable {
  final String sortBy; // 'title', 'created', 'updated', 'messageCount'
  final bool ascending;

  const ChatsSortConfig({
    this.sortBy = 'updated',
    this.ascending = false, // Default to newest first
  });

  @override
  List<Object?> get props => [sortBy, ascending];

  ChatsSortConfig copyWith({
    String? sortBy,
    bool? ascending,
  }) {
    return ChatsSortConfig(
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Base class for all chats states
abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

/// Statistics about chats
class ChatsStatistics extends Equatable {
  final int totalChats;
  final int totalMessages;
  final int starredChats;
  final int pinnedChats;
  final int archivedChats;
  final int chatsWithArtifacts;
  final Map<String, int> chatsByProject;
  final Map<String, int> messagesByMonth;
  final DateTime? oldestChatDate;
  final DateTime? newestChatDate;
  final double averageMessagesPerChat;

  const ChatsStatistics({
    required this.totalChats,
    required this.totalMessages,
    required this.starredChats,
    required this.pinnedChats,
    required this.archivedChats,
    required this.chatsWithArtifacts,
    required this.chatsByProject,
    required this.messagesByMonth,
    this.oldestChatDate,
    this.newestChatDate,
    required this.averageMessagesPerChat,
  });

  @override
  List<Object?> get props => [
        totalChats,
        totalMessages,
        starredChats,
        pinnedChats,
        archivedChats,
        chatsWithArtifacts,
        chatsByProject,
        messagesByMonth,
        oldestChatDate,
        newestChatDate,
        averageMessagesPerChat,
      ];
}

/// State when updating a chat
class ChatsUpdating extends ChatsState {
  final Chat chat;

  const ChatsUpdating(this.chat);

  @override
  List<Object?> get props => [chat];
}
