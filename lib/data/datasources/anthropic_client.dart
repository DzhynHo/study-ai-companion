import 'package:dio/dio.dart';

class AnthropicClient {
  final String apiKey;
  final Dio _dio;

  AnthropicClient({required this.apiKey}) : _dio = Dio();

  Future<String> sendMessage({
    required String userMessage,
    required String? systemPrompt,
    List<Map<String, String>>? conversationHistory,
    int maxTokens = 2048,
  }) async {
    try {
      final messages = [
        if (conversationHistory != null) ...conversationHistory.map((m) => {
          'role': m['role'],
          'content': m['content'],
        }),
        {
          'role': 'user',
          'content': userMessage,
        }
      ];

      final payload = {
        'model': 'claude-3-5-sonnet-20241022',
        'max_tokens': maxTokens,
        if (systemPrompt != null) 'system': systemPrompt,
        'messages': messages,
      };

      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: payload,
      );

      if (response.statusCode == 200) {
        final content = response.data['content'] as List;
        if (content.isNotEmpty) {
          return content[0]['text'] as String;
        }
      }

      throw Exception('Brak odpowiedzi z API');
    } catch (e) {
      throw Exception('Błąd Anthropic API: $e');
    }
  }

  Future<String> extractJsonStructure({
    required String userMessage,
    required String? systemPrompt,
    String jsonFormat = '[]',
  }) async {
    try {
      final payload = {
        'model': 'claude-3-5-sonnet-20241022',
        'max_tokens': 4096,
        if (systemPrompt != null) 'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': userMessage,
          }
        ],
      };

      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: payload,
      );

      if (response.statusCode == 200) {
        final content = response.data['content'] as List;
        if (content.isNotEmpty) {
          final text = content[0]['text'] as String;
          // Wyciąg JSON z odpowiedzi
          final jsonMatch = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true).firstMatch(text);
          if (jsonMatch != null) {
            return jsonMatch.group(0)!;
          }
          return text;
        }
      }

      throw Exception('Brak odpowiedzi z API');
    } catch (e) {
      throw Exception('Błąd podczas ekstrakcji JSON: $e');
    }
  }
}
