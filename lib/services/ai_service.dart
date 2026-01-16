import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Groq API Key from .env
String get _kGroqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class ChatMessage {
  final String role; // 'user' or 'assistant' or 'system'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  final String _model = 'llama-3.3-70b-versatile'; // Fast and free tier friendly
  
  final List<ChatMessage> _chatHistory = [];
  
  AIService() {
    // Initialize with system message
    _chatHistory.add(ChatMessage(
      role: 'system',
      content: 'Sen profesyonel bir fitness ve beslenme koçusun. Kullanıcılara spor, egzersiz teknikleri, '
          'beslenme, öğün planlama, supplementler ve fitness hedefleri hakkında motive edici, kısa ve '
          'net tavsiyeler ver. Tıbbi tavsiye vermekten kaçın. Her zaman pozitif ve destekleyici ol. '
          'Kısa ve öz cevaplar ver, gereksiz detaylara girme. Türkçe cevap ver.',
    ));
  }

  Future<String> sendMessage(String message) async {
    final apiKey = _kGroqApiKey;
    if (apiKey.isEmpty) {
      return "Lütfen .env dosyasında GROQ_API_KEY tanımlı olduğundan emin olun.";
    }

    try {
      // Add user message to history
      _chatHistory.add(ChatMessage(role: 'user', content: message));

      // Prepare request
      final url = Uri.parse('$_baseUrl/chat/completions');
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      
      final body = jsonEncode({
        'model': _model,
        'messages': _chatHistory.map((msg) => msg.toJson()).toList(),
        'temperature': 0.7,
        'max_tokens': 1000,
      });

      // Make API request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final assistantMessage = jsonResponse['choices'][0]['message']['content'] as String;
        
        // Add assistant response to history
        _chatHistory.add(ChatMessage(role: 'assistant', content: assistantMessage));
        
        return assistantMessage;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Bilinmeyen hata';
        return "Hata: $errorMessage (Status: ${response.statusCode})";
      }
    } catch (e) {
      return "Hata: ${e.toString()}";
    }
  }
  
  // Start a new chat session (clear history)
  void startChat() {
    _chatHistory.clear();
    _chatHistory.add(ChatMessage(
      role: 'system',
      content: 'Sen profesyonel bir fitness ve beslenme koçusun. Kullanıcılara spor, egzersiz teknikleri, '
          'beslenme, öğün planlama, supplementler ve fitness hedefleri hakkında motive edici, kısa ve '
          'net tavsiyeler ver. Tıbbi tavsiye vermekten kaçın. Her zaman pozitif ve destekleyici ol. '
          'Kısa ve öz cevaplar ver, gereksiz detaylara girme. Türkçe cevap ver.',
    ));
  }
  
  // Get chat history (for debugging or future use)
  List<ChatMessage> getChatHistory() => List.unmodifiable(_chatHistory);
}
