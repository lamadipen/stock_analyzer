import 'dart:convert';

import 'package:http/http.dart' as http;

enum AiAnalysisProvider {
  ollama('Ollama Local'),
  gemini('Gemini'),
  groq('Groq');

  const AiAnalysisProvider(this.label);

  final String label;
}

class OllamaAiService {
  const OllamaAiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<String> generateAnalysisSummary({
    AiAnalysisProvider provider = AiAnalysisProvider.ollama,
    required String baseUrl,
    required String model,
    required String analysisMarkdown,
    String apiKey = '',
  }) async {
    final client = _client ?? http.Client();
    final ownsClient = _client == null;

    try {
      return switch (provider) {
        AiAnalysisProvider.ollama => _generateWithOllama(
          client: client,
          baseUrl: baseUrl,
          model: model,
          analysisMarkdown: analysisMarkdown,
        ),
        AiAnalysisProvider.gemini => _generateWithGemini(
          client: client,
          apiKey: apiKey,
          model: model,
          analysisMarkdown: analysisMarkdown,
        ),
        AiAnalysisProvider.groq => _generateWithGroq(
          client: client,
          apiKey: apiKey,
          model: model,
          analysisMarkdown: analysisMarkdown,
        ),
      };
    } on OllamaAiException {
      rethrow;
    } catch (error) {
      throw OllamaAiException(
        'Could not connect to ${provider.label}. Check the provider settings, API key, and model name.',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<String> _generateWithOllama({
    required http.Client client,
    required String baseUrl,
    required String model,
    required String analysisMarkdown,
  }) async {
    final response = await client
        .post(
          _ollamaGenerateUri(baseUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': model.trim(),
            'stream': false,
            'options': {'temperature': 0.2},
            'prompt': _buildPrompt(analysisMarkdown),
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Ollama returned HTTP ${response.statusCode}. Check that the model is available locally.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final text = '${decoded['response'] ?? ''}'.trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    throw const OllamaAiException('Ollama returned an empty response.');
  }

  Future<String> _generateWithGemini({
    required http.Client client,
    required String apiKey,
    required String model,
    required String analysisMarkdown,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const OllamaAiException('Enter your Gemini API key.');
    }

    final response = await client
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/${Uri.encodeComponent(model.trim())}:generateContent',
          ),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey.trim(),
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': _buildPrompt(analysisMarkdown)},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.2},
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Gemini returned HTTP ${response.statusCode}. Check your API key and model name.',
      );
    }

    final decoded = jsonDecode(response.body);
    final candidates = decoded is Map<String, dynamic>
        ? decoded['candidates']
        : null;
    if (candidates is List && candidates.isNotEmpty) {
      final content = candidates.first is Map<String, dynamic>
          ? candidates.first['content']
          : null;
      final parts = content is Map<String, dynamic> ? content['parts'] : null;
      if (parts is List) {
        final text = parts
            .whereType<Map<String, dynamic>>()
            .map((part) => '${part['text'] ?? ''}')
            .join()
            .trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    throw const OllamaAiException('Gemini returned an empty response.');
  }

  Future<String> _generateWithGroq({
    required http.Client client,
    required String apiKey,
    required String model,
    required String analysisMarkdown,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const OllamaAiException('Enter your Groq API key.');
    }

    final response = await client
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${apiKey.trim()}',
          },
          body: jsonEncode({
            'model': model.trim(),
            'temperature': 0.2,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You summarize a user-provided investment checklist without inventing missing facts or giving personalized financial advice.',
              },
              {'role': 'user', 'content': _buildPrompt(analysisMarkdown)},
            ],
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Groq returned HTTP ${response.statusCode}. Check your API key and model name.',
      );
    }

    final decoded = jsonDecode(response.body);
    final choices = decoded is Map<String, dynamic> ? decoded['choices'] : null;
    if (choices is List && choices.isNotEmpty) {
      final message = choices.first is Map<String, dynamic>
          ? choices.first['message']
          : null;
      if (message is Map<String, dynamic>) {
        final text = '${message['content'] ?? ''}'.trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    throw const OllamaAiException('Groq returned an empty response.');
  }

  Uri _ollamaGenerateUri(String baseUrl) {
    final normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final endpoint = normalized.endsWith('/api')
        ? '$normalized/generate'
        : '$normalized/api/generate';
    return Uri.parse(endpoint);
  }

  String _buildPrompt(String analysisMarkdown) {
    return '''
You are an investment research assistant helping summarize a user's own stock-analysis checklist.

Important:
- Do not give personalized financial advice.
- Do not invent missing facts.
- Use only the provided analysis notes.
- Call out missing or weak evidence.
- Keep the answer concise and decision-focused.

Return this exact structure:
1. Executive Summary
2. Bull Case
3. Bear Case / Key Risks
4. Valuation and Entry Read
5. What To Verify Next
6. Final AI Takeaway

Analysis notes:
$analysisMarkdown
''';
  }
}

class OllamaAiException implements Exception {
  const OllamaAiException(this.message);

  final String message;

  @override
  String toString() => message;
}
