// domain/usecases/usecases.dart
library;

// Base use case
export 'base_usecase.dart';
export 'chat/create_chat.dart';
export 'chat/delete_chat.dart';
// Chat use cases
export 'chat/get_chats.dart';
export 'chat/search_chats.dart';
export 'chat/update_chat.dart';
// Claude API use cases
export 'claude/get_models.dart';
export 'claude/send_conversation.dart';
export 'claude/send_prompt.dart';
export 'claude/validate_api_key.dart';
export 'messages/delete_message.dart';
export 'messages/get_messages.dart';
// Message use cases
export 'messages/send_message.dart';
export 'messages/update_message.dart';
export 'messages/watch_messages.dart';
export 'projects/add_artifact_to_project.dart';
export 'projects/create_project.dart';
export 'projects/delete_project.dart';
export 'projects/get_project_artifacts.dart';
// Project use cases
export 'projects/get_projects.dart';
export 'projects/remove_artifact_from_project.dart';
export 'projects/search_projects.dart';
export 'projects/update_project.dart';
export 'user/get_api_key.dart';
// User use cases
export 'user/get_user.dart';
export 'user/get_user_preferences.dart';
export 'user/save_api_key.dart';
export 'user/save_user.dart';
export 'user/save_user_preferences.dart';
