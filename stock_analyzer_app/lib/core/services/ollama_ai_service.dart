import 'dart:convert';

import 'package:http/http.dart' as http;

class OllamaAiService {
  const OllamaAiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<String> generateAnalysisSummary({
    required String baseUrl,
    required String model,
    required String analysisMarkdown,
  }) async {
    final client = _client ?? http.Client();
    final ownsClient = _client == null;

    try {
      final response = await client
          .post(
            _generateUri(baseUrl),
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
    } on OllamaAiException {
      rethrow;
    } catch (error) {
      throw OllamaAiException(
        'Could not connect to Ollama. Make sure Ollama is running at $baseUrl and the model is installed.',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri _generateUri(String baseUrl) {
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
