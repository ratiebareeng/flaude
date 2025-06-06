// pubspec.yaml dependencies to add:
/*
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_database: ^10.4.0
  firebase_auth: ^4.15.3
  provider: ^6.1.1
  http: ^1.1.2
  file_picker: ^6.1.1
  google_fonts: ^6.1.0
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
*/

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// ====================== VIEWS ======================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// ====================== MODELS ======================

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        email: json['email'],
        displayName: json['displayName'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ====================== VIEW MODELS ======================

class AuthViewModel extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await FirebaseService.signInAnonymously();
    } catch (e) {
      print('Auth error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        if (authVM.isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authVM.isAuthenticated) {
          return LoginPage();
        }

        return HomePage();
      },
    );
  }
}

class Chat {
  final String id;
  String title;
  final String userId;
  final String? projectId;
  final String? folderId;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Message> messages;

  Chat({
    required this.id,
    required this.title,
    required this.userId,
    this.projectId,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'],
        title: json['title'],
        userId: json['userId'],
        projectId: json['projectId'],
        folderId: json['folderId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        messages: (json['messages'] as Map<String, dynamic>?)
                ?.values
                .map((msgJson) =>
                    Message.fromJson(Map<String, dynamic>.from(msgJson)))
                .toList() ??
            [],
      );

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get lastMessage {
    if (messages.isEmpty) return 'No messages yet';
    return messages.last.content;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'userId': userId,
        'projectId': projectId,
        'folderId': folderId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createNewChat(context),
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, chatVM, child) {
          if (chatVM.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No chats yet', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createNewChat(context),
                    child: Text('Start New Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatVM.chats.length,
            itemBuilder: (context, index) {
              final chat = chatVM.chats[index];
              return ListTile(
                title: Text(chat.title),
                subtitle: Text(chat.lastMessage),
                trailing: Text(chat.formattedTime),
                onTap: () => _openChat(context, chat),
                onLongPress: () => _showChatOptions(context, chat),
              );
            },
          );
        },
      ),
    );
  }

  void _createNewChat(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    final chat = await chatVM.createNewChat(authVM.currentUser!.id);
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  void _openChat(BuildContext context, Chat chat) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  void _showChatOptions(BuildContext context, Chat chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement rename functionality
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<ChatViewModel>(context, listen: false)
                  .deleteChat(chat.id);
            },
          ),
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chat_bubble_outline),
      title: Text(chat.title),
      subtitle: Text(chat.lastMessage),
      trailing: Text(chat.formattedTime),
      onTap: onTap,
    );
  }
}

class ChatViewModel extends ChangeNotifier {
  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _currentMessages = [];
  bool _isLoading = false;
  String _selectedModel = 'claude-3-sonnet-20240229';
  String _apiKey = '';

  final List<String> availableModels = [
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
    'claude-3-opus-20240229',
    'claude-3-5-sonnet-20241022',
  ];

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String get selectedModel => _selectedModel;

  Future<Chat> createNewChat(String userId,
      {String? projectId, String? folderId}) async {
    final chat = Chat(
      id: const Uuid().v4(),
      title: 'New Chat',
      userId: userId,
      projectId: projectId,
      folderId: folderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await FirebaseService.createChat(chat);
    return chat;
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await FirebaseService.deleteChat(chatId);
      if (_currentChat?.id == chatId) {
        _currentChat = null;
        _currentMessages = [];
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  void listenToChatMessages(String chatId) {
    FirebaseService.getChatMessages(chatId).listen((messages) {
      _currentMessages = messages;
      notifyListeners();
    });
  }

  void listenToFolderChats(String folderId) {
    FirebaseService.getFolderChats(folderId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  void listenToUserChats(String userId) {
    FirebaseService.getUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String content) async {
    if (_currentChat == null || _apiKey.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMessage = Message(
        id: const Uuid().v4(),
        content: content,
        isUser: true,
        chatId: _currentChat!.id,
        timestamp: DateTime.now(),
      );

      await FirebaseService.addMessage(userMessage);

      // Update chat title if it's the first message
      if (_currentMessages.length == 1) {
        _currentChat!.title =
            content.length > 30 ? '${content.substring(0, 30)}...' : content;
        await FirebaseService.updateChat(_currentChat!);
      }

      // Get AI response
      final response = await ClaudeApiService.sendMessage(
        apiKey: _apiKey,
        message: content,
        model: _selectedModel,
        conversationHistory:
            _currentMessages.where((m) => !m.isUser).take(10).toList(),
      );

      // Add assistant message
      final assistantMessage = Message(
        id: const Uuid().v4(),
        content: response,
        isUser: false,
        chatId: _currentChat!.id,
        timestamp: DateTime.now(),
        model: _selectedModel,
      );

      await FirebaseService.addMessage(assistantMessage);
      await FirebaseService.updateChat(_currentChat!);
    } catch (e) {
      final errorMessage = Message(
        id: const Uuid().v4(),
        content: 'Error: ${e.toString()}',
        isUser: false,
        chatId: _currentChat!.id,
        timestamp: DateTime.now(),
      );
      await FirebaseService.addMessage(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    notifyListeners();
  }

  void setCurrentChat(Chat chat) {
    _currentChat = chat;
    listenToChatMessages(chat.id);
    notifyListeners();
  }

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }
}

class ClaudeApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  static Future<String> sendMessage({
    required String apiKey,
    required String message,
    required String model,
    List<Message> conversationHistory = const [],
  }) async {
    try {
      final messages = [
        ...conversationHistory.map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.content,
            }),
        {
          'role': 'user',
          'content': message,
        }
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 4000,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}

// ====================== SERVICES ======================

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _users = 'users';
  static const String _projects = 'projects';
  static const String _folders = 'folders';
  static const String _chats = 'chats';
  static const String _messages = 'messages';

  static String? get currentUserId => _auth.currentUser?.uid;

  // Messages
  static Future<void> addMessage(Message message) async {
    await _database.ref('$_messages/${message.id}').set(message.toJson());
  }

  // Chats
  static Future<void> createChat(Chat chat) async {
    await _database.ref('$_chats/${chat.id}').set(chat.toJson());
  }

  // Folders
  static Future<void> createFolder(Folder folder) async {
    await _database.ref('$_folders/${folder.id}').set(folder.toJson());
  }

  // Projects
  static Future<void> createProject(Project project) async {
    await _database.ref('$_projects/${project.id}').set(project.toJson());
  }

  static Future<void> deleteChat(String chatId) async {
    await _database.ref('$_chats/$chatId').remove();
    // Also delete messages in this chat
    final messagesQuery =
        _database.ref(_messages).orderByChild('chatId').equalTo(chatId);
    final messagesSnapshot = await messagesQuery.once();

    if (messagesSnapshot.snapshot.value != null) {
      final messages =
          Map<String, dynamic>.from(messagesSnapshot.snapshot.value as Map);
      for (String messageId in messages.keys) {
        await _database.ref('$_messages/$messageId').remove();
      }
    }
  }

  static Future<void> deleteFolder(String folderId) async {
    await _database.ref('$_folders/$folderId').remove();
    // Also delete chats in this folder
    final chatsQuery =
        _database.ref(_chats).orderByChild('folderId').equalTo(folderId);
    final chatsSnapshot = await chatsQuery.once();

    if (chatsSnapshot.snapshot.value != null) {
      final chats =
          Map<String, dynamic>.from(chatsSnapshot.snapshot.value as Map);
      for (String chatId in chats.keys) {
        await deleteChat(chatId);
      }
    }
  }

  static Future<void> deleteProject(String projectId) async {
    await _database.ref('$_projects/$projectId').remove();
    // Also delete related folders and chats
    final foldersQuery =
        _database.ref(_folders).orderByChild('projectId').equalTo(projectId);
    final chatsQuery =
        _database.ref(_chats).orderByChild('projectId').equalTo(projectId);

    final foldersSnapshot = await foldersQuery.once();
    final chatsSnapshot = await chatsQuery.once();

    if (foldersSnapshot.snapshot.value != null) {
      final folders =
          Map<String, dynamic>.from(foldersSnapshot.snapshot.value as Map);
      for (String folderId in folders.keys) {
        await _database.ref('$_folders/$folderId').remove();
      }
    }

    if (chatsSnapshot.snapshot.value != null) {
      final chats =
          Map<String, dynamic>.from(chatsSnapshot.snapshot.value as Map);
      for (String chatId in chats.keys) {
        await deleteChat(chatId);
      }
    }
  }

  static Stream<List<Message>> getChatMessages(String chatId) {
    return _database
        .ref(_messages)
        .orderByChild('chatId')
        .equalTo(chatId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Message>[];

      final messagesMap =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      return messagesMap.values
          .map((json) => Message.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Stream<List<Chat>> getFolderChats(String folderId) {
    return _database
        .ref(_chats)
        .orderByChild('folderId')
        .equalTo(folderId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Chat>[];

      final chatsMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      return chatsMap.values
          .map((json) => Chat.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  static Stream<List<Folder>> getProjectFolders(String projectId) {
    return _database
        .ref(_folders)
        .orderByChild('projectId')
        .equalTo(projectId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Folder>[];

      final foldersMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      return foldersMap.values
          .map((json) => Folder.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  static Stream<List<Chat>> getUserChats(String userId) {
    return _database
        .ref(_chats)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Chat>[];

      final chatsMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      return chatsMap.values
          .map((json) => Chat.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  static Stream<List<Project>> getUserProjects(String userId) {
    return _database
        .ref(_projects)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Project>[];

      final projectsMap =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      return projectsMap.values
          .map((json) => Project.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  // User Authentication
  static Future<AppUser?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        final appUser = AppUser(
          id: user.uid,
          email: 'anonymous@claude-clone.app',
          displayName: 'Anonymous User',
          createdAt: DateTime.now(),
        );

        await _database.ref('$_users/${user.uid}').set(appUser.toJson());
        return appUser;
      }
    } catch (e) {
      print('Error signing in: $e');
    }
    return null;
  }

  static Future<void> updateChat(Chat chat) async {
    chat.updatedAt = DateTime.now();
    await _database.ref('$_chats/${chat.id}').update(chat.toJson());
  }

  static Future<void> updateFolder(Folder folder) async {
    folder.updatedAt = DateTime.now();
    await _database.ref('$_folders/${folder.id}').update(folder.toJson());
  }

  static Future<void> updateProject(Project project) async {
    project.updatedAt = DateTime.now();
    await _database.ref('$_projects/${project.id}').update(project.toJson());
  }
}

class Folder {
  final String id;
  String name;
  final String projectId;
  final String userId;
  final DateTime createdAt;
  DateTime updatedAt;

  Folder({
    required this.id,
    required this.name,
    required this.projectId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        id: json['id'],
        name: json['name'],
        projectId: json['projectId'],
        userId: json['userId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'projectId': projectId,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class FolderDetailPage extends StatefulWidget {
  final Folder folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  _FolderDetailPageState createState() => _FolderDetailPageState();
}

class FolderTile extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;

  const FolderTile({super.key, required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.folder, color: Colors.amber),
      title: Text(folder.name),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class LoginPage extends StatelessWidget {
  final TextEditingController _apiKeyController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 80, color: Color(0xFFBD5D3A)),
            SizedBox(height: 24),
            Text(
              'Claude Chat Clone',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Claude API Key',
                hintText: 'sk-ant-api03-...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _signIn(context),
                child: Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn(BuildContext context) async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your API key')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    await authVM.signInAnonymously();
    chatVM.setApiKey(_apiKeyController.text.trim());
  }
}

class Message {
  final String id;
  final String content;
  final bool isUser;
  final String chatId;
  final DateTime timestamp;
  final List<String> attachments;
  final String? model;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.chatId,
    required this.timestamp,
    this.attachments = const [],
    this.model,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        content: json['content'],
        isUser: json['isUser'],
        chatId: json['chatId'],
        timestamp: DateTime.parse(json['timestamp']),
        attachments: List<String>.from(json['attachments'] ?? []),
        model: json['model'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isUser': isUser,
        'chatId': chatId,
        'timestamp': timestamp.toIso8601String(),
        'attachments': attachments,
        'model': model,
      };
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFBD5D3A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachments.isNotEmpty)
              ...message.attachments.map((attachment) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            attachment,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )),
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF3D3929),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: MaterialApp(
        title: 'Claude Chat Clone',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: _createMaterialColor(const Color(0xFFBD5D3A)),
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFBD5D3A),
            secondary: const Color(0xFFDA7756),
            surface: const Color(0xFF2C2C2E),
            onSurface: const Color(0xFFFFFFFF),
          ),
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: AuthWrapper(),
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class Project {
  final String id;
  String name;
  String description;
  final String userId;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Folder> folders;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.folders = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        userId: json['userId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        folders: (json['folders'] as Map<String, dynamic>?)
                ?.values
                .map((folderJson) =>
                    Folder.fromJson(Map<String, dynamic>.from(folderJson)))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateProjectDialog(context),
          ),
        ],
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, projectVM, child) {
          if (projectVM.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No projects yet', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateProjectDialog(context),
                    child: Text('Create Project'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: projectVM.projects.length,
            itemBuilder: (context, index) {
              final project = projectVM.projects[index];
              return ListTile(
                leading: Icon(Icons.folder),
                title: Text(project.name),
                subtitle: Text(project.description),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => _showProjectOptions(context, project),
                ),
                onTap: () => _openProject(context, project),
              );
            },
          );
        },
      ),
    );
  }

  void _openProject(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final authVM =
                    Provider.of<AuthViewModel>(context, listen: false);
                Provider.of<ProjectViewModel>(context, listen: false)
                    .createProject(
                  nameController.text,
                  descriptionController.text,
                  authVM.currentUser!.id,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showProjectOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit functionality
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<ProjectViewModel>(context, listen: false)
                  .deleteProject(project.id);
            },
          ),
        ],
      ),
    );
  }
}

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];
  List<Folder> _folders = [];
  bool _isLoading = false;

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;
  List<Project> get projects => _projects;

  Future<void> createFolder(
      String name, String projectId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final folder = Folder(
        id: const Uuid().v4(),
        name: name,
        projectId: projectId,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService.createFolder(folder);
    } catch (e) {
      print('Error creating folder: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProject(
      String name, String description, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final project = Project(
        id: const Uuid().v4(),
        name: name,
        description: description,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService.createProject(project);
    } catch (e) {
      print('Error creating project: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      await FirebaseService.deleteFolder(folderId);
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await FirebaseService.deleteProject(projectId);
    } catch (e) {
      print('Error deleting project: $e');
    }
  }

  void listenToFolders(String projectId) {
    FirebaseService.getProjectFolders(projectId).listen((folders) {
      _folders = folders;
      notifyListeners();
    });
  }

  void listenToProjects(String userId) {
    FirebaseService.getUserProjects(userId).listen((projects) {
      _projects = projects;
      notifyListeners();
    });
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.key),
            title: Text('Update API Key'),
            subtitle: Text('Change your Claude API key'),
            onTap: () => _showApiKeyDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('App appearance'),
            onTap: () {
              // TODO: Implement theme selection
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Claude Chat Clone v2.0'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Claude Chat Clone',
      applicationVersion: '2.0.0',
      children: [
        Text(
            'A lightweight Claude.ai alternative using the Anthropic API with Firebase backend.'),
      ],
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update API Key'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'sk-ant-api03-...',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final apiKey = controller.text.trim();
              if (apiKey.isNotEmpty) {
                Provider.of<ChatViewModel>(context, listen: false)
                    .setApiKey(apiKey);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('API key updated')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatViewModel>(
          builder: (context, chatVM, child) {
            return Text(chatVM.currentChat?.title ?? 'Chat');
          },
        ),
        actions: [
          Consumer<ChatViewModel>(
            builder: (context, chatVM, child) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3A3A3C)),
                ),
                child: DropdownButton<String>(
                  value: chatVM.selectedModel,
                  items: chatVM.availableModels.map((model) {
                    String displayName = model;
                    if (model.contains('sonnet')) displayName = 'Claude Sonnet';
                    if (model.contains('haiku')) displayName = 'Claude Haiku';
                    if (model.contains('opus')) displayName = 'Claude Opus';

                    return DropdownMenuItem(
                      value: model,
                      child: Text(
                        displayName,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (model) {
                    if (model != null) {
                      chatVM.setModel(model);
                    }
                  },
                  underline: SizedBox.shrink(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  dropdownColor: const Color(0xFF2C2C2E),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, chatVM, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: chatVM.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatVM.currentMessages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ChatViewModel>(
      builder: (context, chatVM, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            border: Border(
              top: BorderSide(color: const Color(0xFF3A3A3C), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: Colors.grey),
                onPressed: chatVM.isLoading ? null : _pickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Reply to Claude...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF3A3A3C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF3A3A3C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFFBD5D3A)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(color: Colors.white),
                  maxLines: null,
                  enabled: !chatVM.isLoading,
                  onSubmitted: (text) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: chatVM.isLoading
                      ? Colors.grey.shade600
                      : const Color(0xFFBD5D3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: chatVM.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.send, color: Colors.white),
                  onPressed: chatVM.isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      // TODO: Handle file attachment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File attachment coming soon!')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ChatViewModel>(context, listen: false).sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createChatInFolder(context),
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, chatVM, child) {
          final folderChats = chatVM.chats
              .where((chat) => chat.folderId == widget.folder.id)
              .toList();

          if (folderChats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No chats in this folder yet'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createChatInFolder(context),
                    child: Text('Start Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: folderChats.length,
            itemBuilder: (context, index) {
              final chat = folderChats[index];
              return ChatTile(
                chat: chat,
                onTap: () => _openChat(context, chat),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    chatVM.listenToFolderChats(widget.folder.id);
  }

  void _createChatInFolder(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    final chat = await chatVM.createNewChat(
      authVM.currentUser!.id,
      projectId: widget.folder.projectId,
      folderId: widget.folder.id,
    );
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  void _openChat(BuildContext context, Chat chat) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ChatsPage(),
      ProjectsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final projectVM = Provider.of<ProjectViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    if (authVM.currentUser != null) {
      projectVM.listenToProjects(authVM.currentUser!.id);
      chatVM.listenToUserChats(authVM.currentUser!.id);
    }
  }
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: () => _showCreateFolderDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createChatInProject(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Project Description
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Text(widget.project.description),
                  ],
                ),
              ),
            ),
          ),

          // Folders and Chats
          Expanded(
            child: Consumer2<ProjectViewModel, ChatViewModel>(
              builder: (context, projectVM, chatVM, child) {
                final folders = projectVM.folders;
                final projectChats = chatVM.chats
                    .where((chat) =>
                        chat.projectId == widget.project.id &&
                        chat.folderId == null)
                    .toList();

                return ListView(
                  children: [
                    // Folders
                    if (folders.isNotEmpty) ...[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Folders',
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      ...folders.map((folder) => FolderTile(
                            folder: folder,
                            onTap: () => _openFolder(context, folder),
                          )),
                    ],

                    // Direct chats in project
                    if (projectChats.isNotEmpty) ...[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Chats',
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      ...projectChats.map((chat) => ChatTile(
                            chat: chat,
                            onTap: () => _openChat(context, chat),
                          )),
                    ],

                    if (folders.isEmpty && projectChats.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.folder_open,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No folders or chats yet'),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _createChatInProject(context),
                                child: Text('Start Chat'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final projectVM = Provider.of<ProjectViewModel>(context, listen: false);
    projectVM.listenToFolders(widget.project.id);
  }

  void _createChatInProject(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    final chat = await chatVM.createNewChat(
      authVM.currentUser!.id,
      projectId: widget.project.id,
    );
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  void _openChat(BuildContext context, Chat chat) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    chatVM.setCurrentChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  void _openFolder(BuildContext context, Folder folder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderDetailPage(folder: folder)),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Folder'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final authVM =
                    Provider.of<AuthViewModel>(context, listen: false);
                Provider.of<ProjectViewModel>(context, listen: false)
                    .createFolder(
                  nameController.text,
                  widget.project.id,
                  authVM.currentUser!.id,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
