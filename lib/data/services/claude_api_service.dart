import 'dart:convert';

import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:http/http.dart' as http;

class ClaudeApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  Future<String> sendMessage({
    required String message,
    required String model,
    required String apiKey,
    required List<Message> conversationHistory,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(
          'API key not set. Please configure your API key in settings.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };

    // Convert conversation history to Claude API format
    final messages = conversationHistory.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      };
    }).toList();

    // Add the new message
    messages.add({
      'role': 'user',
      'content': message,
    });

    final body = {
      'model': model,
      'max_tokens': 4096,
      'messages': messages,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'][0]['text'];
    } else {
      final error = json.decode(response.body);
      throw Exception('API Error: ${error['error']['message']}');
    }
  }
}
