import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AISummarizer {
  AISummarizer({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static DateTime? _lastCallAt;
  static const Duration _minInterval = Duration(milliseconds: 1200);

  // .env içindeki API anahtarını okur
  String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('OPENAI_API_KEY missing from environment');
    }
    final trimmed = key.trim();
    // Kabaca doğrulama: sk- ile başlamalı ve uzun olmalı
    if (!trimmed.startsWith('sk-') || trimmed.length < 20) {
      throw StateError('OPENAI_API_KEY seems invalid. Check your .env');
    }
    return trimmed;
  }

  // İçeriği kısa bir özet haline getirir
  Future<String> summarize(String content, {String? model}) async {
    // Throttle
    final now = DateTime.now();
    if (_lastCallAt != null) {
      final diff = now.difference(_lastCallAt!);
      if (diff < _minInterval) {
        await Future.delayed(_minInterval - diff);
      }
    }
    _lastCallAt = DateTime.now();

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_apiKey}',
      if (dotenv.env['OPENAI_ORG']?.isNotEmpty == true)
        'OpenAI-Organization': dotenv.env['OPENAI_ORG']!,
      'Accept': 'application/json',
    };
    final resolvedModel = model ?? dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    final String trimmed =
        content.length > 6000 ? content.substring(0, 6000) : content;
    final body = json.encode({
      'model': resolvedModel,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a concise summarizer. Return a short Turkish summary.',
        },
        {'role': 'user', 'content': 'Şu metni kısa ve net özetle:\n\n$trimmed'},
      ],
      'temperature': 0.2,
      'max_tokens': 160,
    });
    final res = await _postWithRetry(uri, headers, body);
    if (res.statusCode != 200) {
      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception(
          'OpenAI auth failed (401/403). Check API key, model and billing. Body: ${res.body}',
        );
      }
      if (res.statusCode == 429) {
        throw Exception(
          'Rate limited (429). Yavaş deneyin veya kullanım/billing’i kontrol edin. Body: ${res.body}',
        );
      }
      throw Exception('OpenAI summarize failed: ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    final msg = choices?.first?['message']?['content'] as String?;
    if (msg == null || msg.isEmpty) {
      throw Exception('OpenAI returned empty response');
    }
    return msg.trim();
  }

  Future<http.Response> _postWithRetry(
    Uri uri,
    Map<String, String> headers,
    String body,
  ) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 800;
    while (true) {
      attempt += 1;
      try {
        final res = await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 20));
        if (res.statusCode == 429 && attempt < maxAttempts) {
          final retryAfter = res.headers['retry-after'];
          final waitMs =
              retryAfter != null
                  ? ((double.tryParse(retryAfter) ?? 1.0) * 1000).toInt()
                  : delayMs;
          await Future.delayed(Duration(milliseconds: waitMs));
          delayMs *= 2;
          continue;
        }
        return res;
      } catch (_) {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
  }
}
