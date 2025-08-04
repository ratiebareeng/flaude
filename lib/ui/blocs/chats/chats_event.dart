import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

/// Event to archive a chat
class ChatArchived extends ChatsEvent {
  final String chatId;

  const ChatArchived(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to create a new chat
class ChatCreated extends ChatsEvent {
  final String title;
  final String? projectId;
  final String? description;

  const ChatCreated({
    required this.title,
    this.projectId,
    this.description,
  });

  @override
  List<Object?> get props => [title, projectId, description];
}

/// Event to delete a chat
class ChatDeleted extends ChatsEvent {
  final String chatId;

  const ChatDeleted(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to duplicate a chat
class ChatDuplicated extends ChatsEvent {
  final String chatId;
  final String? newTitle;

  const ChatDuplicated({
    required this.chatId,
    this.newTitle,
  });

  @override
  List<Object?> get props => [chatId, newTitle];
}

/// Event to pin a chat
class ChatPinned extends ChatsEvent {
  final String chatId;

  const ChatPinned(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to rename a chat
class ChatRenamed extends ChatsEvent {
  final String chatId;
  final String newTitle;

  const ChatRenamed({
    required this.chatId,
    required this.newTitle,
  });

  @override
  List<Object?> get props => [chatId, newTitle];
}

/// Event to restore an archived chat
class ChatRestored extends ChatsEvent {
  final String chatId;

  const ChatRestored(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to perform bulk action on selected chats
class ChatsBulkAction extends ChatsEvent {
  final String action; // 'delete', 'archive', 'export', 'star', 'unstar'
  final List<String> chatIds;

  const ChatsBulkAction({
    required this.action,
    required this.chatIds,
  });

  @override
  List<Object?> get props => [action, chatIds];
}

/// Event to clear errors
class ChatsErrorCleared extends ChatsEvent {
  const ChatsErrorCleared();
}

/// Event to handle errors
class ChatsErrorOccurred extends ChatsEvent {
  final String message;
  final String? details;

  const ChatsErrorOccurred(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Base class for all chats events
abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to export multiple chats
class ChatsExportedEvent extends ChatsEvent {
  final List<String> chatIds;
  final String format; // 'json', 'markdown', 'zip'

  const ChatsExportedEvent({
    required this.chatIds,
    required this.format,
  });

  @override
  List<Object?> get props => [chatIds, format];
}

/// Event to filter chats
class ChatsFiltered extends ChatsEvent {
  final String? projectId;
  final bool? hasMessages;
  final bool? isStarred;
  final bool? isPinned;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const ChatsFiltered({
    this.projectId,
    this.hasMessages,
    this.isStarred,
    this.isPinned,
    this.createdAfter,
    this.createdBefore,
  });

  @override
  List<Object?> get props => [
        projectId,
        hasMessages,
        isStarred,
        isPinned,
        createdAfter,
        createdBefore,
      ];
}

/// Event to clear filters
class ChatsFiltersCleared extends ChatsEvent {
  const ChatsFiltersCleared();
}

/// Event to import chats
class ChatsImported extends ChatsEvent {
  final String filePath;
  final String format;

  const ChatsImported({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

/// Event to initialize the chats list
class ChatsInitialized extends ChatsEvent {
  const ChatsInitialized();
}

/// Event to load all chats
class ChatsLoadedEvent extends ChatsEvent {
  final bool includeArchived;

  const ChatsLoadedEvent({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

/// Event to select multiple chats
class ChatsMultiSelected extends ChatsEvent {
  final List<String> chatIds;

  const ChatsMultiSelected(this.chatIds);

  @override
  List<Object?> get props => [chatIds];
}

/// Event to clear multiple selection
class ChatsMultiSelectionCleared extends ChatsEvent {
  const ChatsMultiSelectionCleared();
}

/// Event to paginate chats (load more)
class ChatsPaginated extends ChatsEvent {
  final int limit;
  final int offset;

  const ChatsPaginated({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to load chats for a specific project
class ChatsProjectLoaded extends ChatsEvent {
  final String projectId;

  const ChatsProjectLoaded(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event when chats are received from subscription
class ChatsReceived extends ChatsEvent {
  final List<Chat> chats;

  const ChatsReceived(this.chats);

  @override
  List<Object?> get props => [chats];
}

/// Event to load recent chats
class ChatsRecentLoaded extends ChatsEvent {
  final int limit;

  const ChatsRecentLoaded({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Event to refresh chats list
class ChatsRefreshed extends ChatsEvent {
  const ChatsRefreshed();
}

/// Event to clear search
class ChatsSearchCleared extends ChatsEvent {
  const ChatsSearchCleared();
}

/// Event to search chats
class ChatsSearched extends ChatsEvent {
  final String query;
  final String? projectId;

  const ChatsSearched({
    required this.query,
    this.projectId,
  });

  @override
  List<Object?> get props => [query, projectId];
}

/// Event to sort chats
class ChatsSorted extends ChatsEvent {
  final String sortBy; // 'title', 'created', 'updated', 'messageCount'
  final bool ascending;

  const ChatsSorted({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}

/// Event to get chat statistics
class ChatsStatisticsRequested extends ChatsEvent {
  final String? projectId;

  const ChatsStatisticsRequested({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// Event to start listening to real-time chat updates
class ChatsSubscriptionStarted extends ChatsEvent {
  final String? projectId;

  const ChatsSubscriptionStarted({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// Event to stop listening to real-time updates
class ChatsSubscriptionStopped extends ChatsEvent {
  const ChatsSubscriptionStopped();
}

/// Event to star a chat
class ChatStarred extends ChatsEvent {
  final String chatId;

  const ChatStarred(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to unpin a chat
class ChatUnpinned extends ChatsEvent {
  final String chatId;

  const ChatUnpinned(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to unstar a chat
class ChatUnstarred extends ChatsEvent {
  final String chatId;

  const ChatUnstarred(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to update a chat
class ChatUpdated extends ChatsEvent {
  final Chat chat;

  const ChatUpdated(this.chat);

  @override
  List<Object?> get props => [chat];
}
