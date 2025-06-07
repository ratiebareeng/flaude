import 'package:claude_chat_clone/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppState extends ChangeNotifier {
  final List<Project> _projects = [];
  final List<Chat> _chats = [];
  String _selectedModel = 'claude-3-5-sonnet-20241022';
  String _apiKey = '';
  Chat? _currentChat;

  final List<String> availableModels = [
    'claude-3-5-sonnet-20241022',
    'claude-3-haiku-20240307',
    'claude-3-opus-20240229',
  ];
  final Uuid _uuid = Uuid();
  AppState() {
    _loadData();
  }
  String get apiKey => _apiKey;
  List<Chat> get chats => _chats;

  Chat? get currentChat => _currentChat;

  List<Project> get projects => _projects;

  String get selectedModel => _selectedModel;

  void addMessage(String content, bool isUser, {List<String>? attachments}) {
    if (_currentChat == null) return;

    final message = Message(
      id: _uuid.v4(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    _currentChat!.messages.add(message);
    _saveData();
    notifyListeners();
  }

  void createChat({String? projectId, String? title}) {
    final chat = Chat(
      id: _uuid.v4(),
      title: title ?? 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
      projectId: projectId,
    );

    if (projectId != null) {
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        _projects[projectIndex].chats.add(chat);
      }
    } else {
      _chats.add(chat);
    }

    _currentChat = chat;
    _saveData();
    notifyListeners();
  }

  void createProject(String title, String description) {
    final project = Project(
      id: _uuid.v4(),
      title: title,
      description: description,
      updatedAt: DateTime.now(),
      chats: [],
    );
    _projects.add(project);
    _saveData();
    notifyListeners();
  }

  void setApiKey(String key) {
    _apiKey = key;
    _saveData();
    notifyListeners();
  }

  void setCurrentChat(Chat chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    _saveData();
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('apiKey') ?? '';
    _selectedModel =
        prefs.getString('selectedModel') ?? 'claude-3-5-sonnet-20241022';

    // Load projects and chats from SharedPreferences
    // Implementation details omitted for brevity
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', _apiKey);
    await prefs.setString('selectedModel', _selectedModel);
    // Save projects and chats to SharedPreferences
    // Implementation details omitted for brevity
  }
}
