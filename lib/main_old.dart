import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// Add this method inside your MyApp class, before the @override Widget build method:

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

class Chat {
  final String id;
  String title;
  final List<Message> messages;
  final String? projectId;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.title,
    List<Message>? messages,
    this.projectId,
    required this.createdAt,
  }) : messages = messages ?? [];

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List?)
                ?.map((m) => Message.fromJson(m))
                .toList() ??
            [],
        projectId: json['projectId'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
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
        'messages': messages.map((m) => m.toJson()).toList(),
        'projectId': projectId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showNewChatDialog(context),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey.shade600),
                  SizedBox(height: 16),
                  Text('No chats yet',
                      style: TextStyle(color: Colors.grey.shade400)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showNewChatDialog(context),
                    child: Text('Start New Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              return ListTile(
                title: Text(chat.title),
                subtitle: Text(chat.lastMessage),
                trailing: Text(chat.formattedTime),
                onTap: () {
                  chatProvider.setCurrentChat(chat);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatPage()),
                  );
                },
                onLongPress: () => _showChatOptions(context, chat),
              );
            },
          );
        },
      ),
    );
  }

  _createNewChat(BuildContext context, Project? project) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chat = chatProvider.createNewChat(project);
    chatProvider.setCurrentChat(chat);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }

  _renameChatDialog(BuildContext context, Chat chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Chat'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Chat title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .renameChat(chat, controller.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  _showChatOptions(BuildContext context, Chat chat) {
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
              _renameChatDialog(context, chat);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<ChatProvider>(context, listen: false)
                  .deleteChat(chat);
            },
          ),
        ],
      ),
    );
  }

  _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('General Chat'),
              onTap: () {
                Navigator.pop(context);
                _createNewChat(context, null);
              },
            ),
            Consumer<ProjectProvider>(
              builder: (context, projectProvider, child) {
                return Column(
                  children: projectProvider.projects.map((project) {
                    return ListTile(
                      title: Text('Chat in ${project.name}'),
                      onTap: () {
                        Navigator.pop(context);
                        _createNewChat(context, project);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

// Providers
class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  Chat? _currentChat;
  String _apiKey = '';
  bool _isLoading = false;
  String _selectedModel = 'claude-3-sonnet-20240229';
  final List<String> _pendingAttachments = [];

  final List<String> availableModels = [
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
    'claude-3-opus-20240229',
  ];

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  String get selectedModel => _selectedModel;

  void addAttachment(PlatformFile file) {
    _pendingAttachments.add(file.name);
    notifyListeners();
  }

  Chat createNewChat(Project? project) {
    final chat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      projectId: project?.id,
      createdAt: DateTime.now(),
    );
    _chats.insert(0, chat);
    _saveChats();
    notifyListeners();
    return chat;
  }

  void deleteChat(Chat chat) {
    _chats.remove(chat);
    if (_currentChat == chat) {
      _currentChat = null;
    }
    _saveChats();
    notifyListeners();
  }

  void loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final chatsJson = prefs.getString('chats');
    if (chatsJson != null) {
      final chatsList = jsonDecode(chatsJson) as List;
      _chats = chatsList.map((json) => Chat.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void renameChat(Chat chat, String newTitle) {
    chat.title = newTitle;
    _saveChats();
    notifyListeners();
  }

  void sendMessage(String content) async {
    if (_currentChat == null) return;

    _isLoading = true;
    notifyListeners();

    // Add user message
    final userMessage = Message(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      attachments: List.from(_pendingAttachments),
    );

    _currentChat!.messages.add(userMessage);
    _pendingAttachments.clear();

    // Update chat title if it's the first message
    if (_currentChat!.messages.length == 1) {
      _currentChat!.title =
          content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }

    notifyListeners();

    try {
      final response = await _callClaudeAPI(content);

      final assistantMessage = Message(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _currentChat!.messages.add(assistantMessage);
      _saveChats();
    } catch (e) {
      final errorMessage = Message(
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentChat!.messages.add(errorMessage);
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
    notifyListeners();
  }

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  Future<String> _callClaudeAPI(String message) async {
    const apiUrl = 'https://api.anthropic.com/v1/messages';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _selectedModel,
        'max_tokens': 4000,
        'messages': [
          {'role': 'user', 'content': message}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  void _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    final chatsJson = _chats.map((chat) => chat.toJson()).toList();
    await prefs.setString('chats', jsonEncode(chatsJson));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

// Data Models
class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String> attachments;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.attachments = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        attachments: List<String>.from(json['attachments'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'attachments': attachments,
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
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFBD5D3A) // Claude orange for user messages
              : Colors.white, // White for Claude messages
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
                            child: Text(attachment,
                                style: TextStyle(fontSize: 12))),
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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Claude Chat Clone',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: _createMaterialColor(const Color(0xFFBD5D3A)),
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFBD5D3A), // Orange as accent only
            secondary: const Color(0xFFDA7756),
            surface: const Color(0xFF2C2C2E),
            onSurface: const Color(0xFFFFFFFF),
          ),
          fontFamily: GoogleFonts.inter().fontFamily,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1C1C1E),
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF2C2C2E),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD5D3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF1C1C1E),
            selectedItemColor: const Color(0xFFBD5D3A),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createChatInProject(context),
          ),
        ],
      ),
      body: Column(
        children: [
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
                    Text(project.description),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final projectChats = chatProvider.chats
                    .where((chat) => chat.projectId == project.id)
                    .toList();

                if (projectChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No chats in this project yet'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _createChatInProject(context),
                          child: Text('Start Chat'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: projectChats.length,
                  itemBuilder: (context, index) {
                    final chat = projectChats[index];
                    return ListTile(
                      title: Text(chat.title),
                      subtitle: Text(chat.lastMessage),
                      trailing: Text(chat.formattedTime),
                      onTap: () {
                        chatProvider.setCurrentChat(chat);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatPage()),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _createChatInProject(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chat = chatProvider.createNewChat(project);
    chatProvider.setCurrentChat(chat);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage()),
    );
  }
}

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  void createProject(String name, String description) {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void deleteProject(Project project) {
    _projects.remove(project);
    _saveProjects();
    notifyListeners();
  }

  void loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString('projects');
    if (projectsJson != null) {
      final projectsList = jsonDecode(projectsJson) as List;
      _projects = projectsList.map((json) => Project.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = _projects.map((project) => project.toJson()).toList();
    await prefs.setString('projects', jsonEncode(projectsJson));
  }
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
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.projects.isEmpty) {
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
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];
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

  _openProject(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailPage(project: project),
      ),
    );
  }

  _showCreateProjectDialog(BuildContext context) {
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
                Provider.of<ProjectProvider>(context, listen: false)
                    .createProject(
                        nameController.text, descriptionController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  _showProjectOptions(BuildContext context, Project project) {
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
              // Implement edit functionality
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<ProjectProvider>(context, listen: false)
                  .deleteProject(project);
            },
          ),
        ],
      ),
    );
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
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('App appearance'),
            onTap: () {
              // Implement theme selection
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Claude Chat Clone v1.0'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Claude Chat Clone',
      applicationVersion: '1.0.0',
      children: [
        Text('A lightweight Claude.ai alternative using the Anthropic API.'),
      ],
    );
  }

  _showApiKeyDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('claude_api_key') ?? '';
    final controller = TextEditingController(text: currentKey);

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
            onPressed: () async {
              final apiKey = controller.text.trim();
              if (apiKey.isNotEmpty) {
                await prefs.setString('claude_api_key', apiKey);
                Provider.of<ChatProvider>(context, listen: false)
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
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Text(chatProvider.currentChat?.title ?? 'Chat');
          },
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3A3A3C)),
                ),
                child: DropdownButton<String>(
                  value: chatProvider.selectedModel,
                  items: chatProvider.availableModels.map((model) {
                    String displayName = model;
                    if (model.contains('sonnet')) displayName = 'Claude Sonnet';
                    if (model.contains('haiku')) displayName = 'Claude Haiku';
                    if (model.contains('opus')) displayName = 'Claude Opus';

                    return DropdownMenuItem(
                        value: model,
                        child: Text(
                          displayName,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ));
                  }).toList(),
                  onChanged: (model) {
                    if (model != null) {
                      chatProvider.setModel(model);
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
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.currentChat?.messages ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            border: Border(
                top: BorderSide(color: const Color(0xFF3A3A3C), width: 0.5)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: Colors.grey),
                onPressed: chatProvider.isLoading ? null : _pickFile,
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
                  enabled: !chatProvider.isLoading,
                  onSubmitted: (text) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: chatProvider.isLoading
                      ? Colors.grey.shade600
                      : const Color(0xFFBD5D3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: chatProvider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.send, color: Colors.white),
                  onPressed: chatProvider.isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      final file = result.files.single;
      Provider.of<ChatProvider>(context, listen: false).addAttachment(file);
    }
  }

  _scrollToBottom() {
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

  _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ChatListPage(),
      ProjectsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProjectProvider>(context, listen: false).loadProjects();
    Provider.of<ChatProvider>(context, listen: false).loadChats();
  }

  _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('claude_api_key');
    if (apiKey == null) {
      _showApiKeyDialog();
    } else {
      Provider.of<ChatProvider>(context, listen: false).setApiKey(apiKey);

      // Show proxy instructions for web users
      if (kIsWeb) {
        _showWebInstructions();
      }
    }
  }

  _showApiKeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter Claude API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your Anthropic API key to get started:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'sk-ant-api03-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final apiKey = controller.text.trim();
              if (apiKey.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('claude_api_key', apiKey);
                Provider.of<ChatProvider>(context, listen: false)
                    .setApiKey(apiKey);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  _showWebInstructions() {
    Future.delayed(Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: const Color(0xFFBD5D3A)),
              SizedBox(width: 8),
              Text('Web Setup Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'To use Claude API in web browser, you need to run a local proxy server:'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Install Node.js from nodejs.org',
                        style: TextStyle(fontSize: 12)),
                    Text('2. Save proxy_server.js and package.json',
                        style: TextStyle(fontSize: 12)),
                    Text('3. Run: npm install && npm start',
                        style: TextStyle(fontSize: 12)),
                    Text('4. Keep proxy running while using app',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text('Or run the app on mobile/desktop to avoid this step!',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it!'),
            ),
          ],
        ),
      );
    });
  }
}
