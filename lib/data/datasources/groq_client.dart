import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../core/config.dart';

class GroqClient {
  final String apiKey;
  final Dio _dio;

  GroqClient({required this.apiKey}) : _dio = Dio();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Options _options({bool stream = false}) => Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'content-type': 'application/json',
        },
        responseType: stream ? ResponseType.stream : ResponseType.json,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        validateStatus: (status) => status != null && status < 500,
      );

  List<Map<String, dynamic>> _buildMessages({
    required String? systemPrompt,
    required String userMessage,
    List<Map<String, String>>? history,
  }) {
    final msgs = <Map<String, dynamic>>[];
    if (systemPrompt != null) msgs.add({'role': 'system', 'content': systemPrompt});
    if (history != null) {
      for (final m in history) {
        msgs.add({'role': m['role'] ?? 'user', 'content': m['content'] ?? ''});
      }
    }
    msgs.add({'role': 'user', 'content': userMessage});
    return msgs;
  }

  // ── Streaming (SSE) ────────────────────────────────────────────────────────

  Stream<String> streamMessage({
    required String userMessage,
    required String? systemPrompt,
    List<Map<String, String>>? history,
    int maxTokens = 2048,
  }) async* {
    if (AppConfig.useMockAI) {
      for (final word in 'Mock odpowiedź strumieniowa.'.split(' ')) {
        yield '$word ';
        await Future.delayed(const Duration(milliseconds: 80));
      }
      return;
    }

    final payload = {
      'model': AppConfig.groqModel,
      'messages': _buildMessages(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: history,
      ),
      'max_tokens': maxTokens,
      'temperature': 0.7,
      'stream': true,
    };

    final response = await _dio.post<ResponseBody>(
      _baseUrl,
      options: _options(stream: true),
      data: payload,
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd Groq API (Status: ${response.statusCode})');
    }

    var buffer = '';
    await for (final chunk in response.data!.stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // zachowaj niekompletną linię

      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data: ')) continue;
        final data = trimmed.substring(6);
        if (data == '[DONE]') return;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices[0]['delta'] as Map?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) yield content;
        } catch (_) {}
      }
    }
  }

  // ── Jednorazowy request (fiszki, quiz, egzamin) ───────────────────────────

  Future<String> sendMessage({
    required String userMessage,
    required String? systemPrompt,
    List<Map<String, String>>? history,
    int maxTokens = 2048,
  }) async {
    if (AppConfig.useMockAI) {
      return 'Mock: $userMessage';
    }

    final payload = {
      'model': AppConfig.groqModel,
      'messages': _buildMessages(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: history,
      ),
      'max_tokens': maxTokens,
      'temperature': 0.7,
    };

    final response = await _dio.post(_baseUrl, options: _options(), data: payload);

    if (response.statusCode == 200) {
      final content = response.data['choices'][0]['message']['content'] as String?;
      if (content != null && content.isNotEmpty) return content;
    } else if (response.statusCode == 401) {
      throw Exception('Nieprawidłowy klucz API. Pobierz z https://console.groq.com/keys');
    }

    throw Exception('Brak odpowiedzi z Groq API (Status: ${response.statusCode})');
  }

  // ── Ekstrakcja JSON (fiszki / quiz) ───────────────────────────────────────

  Future<String> extractJsonStructure({
    required String userMessage,
    required String? systemPrompt,
  }) async {
    if (AppConfig.useMockAI) {
      return '[{"question":"Mock pytanie?","answer":"Mock odpowiedź"}]';
    }

    final payload = {
      'model': AppConfig.groqModel,
      'messages': _buildMessages(systemPrompt: systemPrompt, userMessage: userMessage),
      'max_tokens': 4096,
      'temperature': 0.1,
    };

    final response = await _dio.post(_baseUrl, options: _options(), data: payload);

    if (response.statusCode == 200) {
      final content = response.data['choices'][0]['message']['content'] as String?;
      if (content != null && content.isNotEmpty) {
        final match = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true).firstMatch(content);
        return match?.group(0) ?? content;
      }
    }

    throw Exception('Brak odpowiedzi z Groq API (Status: ${response.statusCode})');
  }

  // ── Vision (ekstrakcja tekstu z obrazu) ───────────────────────────────────

  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    if (AppConfig.useMockAI) return 'Tekst z obrazu (mock)';

    final base64Image = base64Encode(imageBytes);
    final mimeType = _detectMimeType(imageBytes);

    final payload = {
      'model': AppConfig.groqVisionModel,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Wyciągnij CAŁY tekst z tego obrazu. Zwróć tylko czysty tekst bez komentarzy.',
            },
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
            },
          ],
        },
      ],
      'max_tokens': 4096,
      'temperature': 0.1,
    };

    final response = await _dio.post(_baseUrl, options: _options(), data: payload);

    if (response.statusCode == 200) {
      final content = response.data['choices'][0]['message']['content'] as String?;
      if (content != null && content.isNotEmpty) return content;
    }

    throw Exception('Błąd Groq Vision API (Status: ${response.statusCode})');
  }

  String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
    if (bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
    if (bytes.length >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
    return 'image/jpeg';
  }
}
