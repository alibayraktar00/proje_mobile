import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


// Get one here: https://aistudio.google.com/app/apikey
const String _kGeminiApiKey = 'AIzaSyBm11jOTdHJh9LhZ5wlapxVZ0FCQ9L1UeE';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _kGeminiApiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    if (_kGeminiApiKey == 'YOUR_API_KEY_HERE') {
      return "Please set your Gemini API Key in `lib/services/ai_service.dart`.";
    }

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't understand that, sorry.";
    } catch (e) {
      return "Error: $e";
    }
  }
  
  // Optional: distinct method for chat session if we want history context
  // maintaining a chat session object would be better for context.
  
  ChatSession startChat() {
     return _model.startChat();
  }
}
