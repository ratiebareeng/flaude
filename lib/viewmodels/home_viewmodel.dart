import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  // Private state
  String _currentView = 'chat';
  String? _selectedChatId;
  bool _showArtifactDetail = false;
  Map<String, dynamic>? _currentArtifact;
  final List<Chat> _recentChats = [];
  final List<Chat> _starredChats = [];
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? get currentArtifact => _currentArtifact;
  // Getters
  String get currentView => _currentView;
  String? get error => _error;
  bool get isLoading => _isLoading;
  List<Chat> get recentChats => List.unmodifiable(_recentChats);
  String? get selectedChatId => _selectedChatId;
  bool get showArtifactDetail => _showArtifactDetail;
  List<Chat> get starredChats => List.unmodifiable(_starredChats);

  Future<void> addArtifactToProject() async {
    if (_currentArtifact == null) return;

    try {
      // Add your artifact-to-project logic here
      // await ProjectRepository.instance.addArtifact(_currentArtifact!);

      // For now, just simulate success
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Failed to add artifact to project: $e';
      notifyListeners();
    }
  }

  void changeView(String view, {String? chatId}) {
    _currentView = view;

    if (chatId != null) {
      _selectedChatId = chatId;
    } else if (view == 'new_chat') {
      _selectedChatId = null;
      _showArtifactDetail = false;
      _currentArtifact = null;
    }

    notifyListeners();
  }

  void createNewChat() {
    _currentView = 'new_chat';
    _selectedChatId = null;
    _showArtifactDetail = false;
    _currentArtifact = null;
    notifyListeners();
  }

  void handleArtifactView(Map<String, dynamic>? artifact) {
    _currentArtifact = artifact;
    _showArtifactDetail = artifact != null;
    notifyListeners();
  }

  // Business logic methods
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await ChatRepository.instance.readRecentChats();
      if (result.$2 != null) {
        _recentChats.clear();
        _recentChats.addAll(result.$2!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectChat(String chatId) {
    _currentView = 'chat';
    _selectedChatId = chatId;
    notifyListeners();
  }
}
