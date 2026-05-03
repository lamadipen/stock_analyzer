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
      return await _generateText(
        client: client,
        provider: provider,
        baseUrl: baseUrl,
        model: model,
        apiKey: apiKey,
        prompt: _buildPrompt(analysisMarkdown),
      );
    } on OllamaAiException {
      rethrow;
    } catch (error) {
      throw OllamaAiException(_connectionErrorMessage(provider, error));
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<BusinessOverviewDraft> generateBusinessOverviewDraft({
    AiAnalysisProvider provider = AiAnalysisProvider.ollama,
    required String baseUrl,
    required String model,
    required String ticker,
    required String rawResearch,
    String apiKey = '',
  }) async {
    if (rawResearch.trim().isEmpty) {
      throw const OllamaAiException('Paste raw research before generating.');
    }

    final client = _client ?? http.Client();
    final ownsClient = _client == null;

    try {
      final response = await _generateText(
        client: client,
        provider: provider,
        baseUrl: baseUrl,
        model: model,
        apiKey: apiKey,
        prompt: _buildBusinessOverviewPrompt(
          ticker: ticker,
          rawResearch: rawResearch,
        ),
      );

      return BusinessOverviewDraft.fromAiResponse(response);
    } on OllamaAiException {
      rethrow;
    } catch (error) {
      throw OllamaAiException(_connectionErrorMessage(provider, error));
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<String> _generateText({
    required http.Client client,
    required AiAnalysisProvider provider,
    required String baseUrl,
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    return switch (provider) {
      AiAnalysisProvider.ollama => _generateWithOllama(
        client: client,
        baseUrl: baseUrl,
        model: model,
        prompt: prompt,
      ),
      AiAnalysisProvider.gemini => _generateWithGemini(
        client: client,
        apiKey: apiKey,
        model: model,
        prompt: prompt,
      ),
      AiAnalysisProvider.groq => _generateWithGroq(
        client: client,
        apiKey: apiKey,
        model: model,
        prompt: prompt,
      ),
    };
  }

  Future<String> _generateWithOllama({
    required http.Client client,
    required String baseUrl,
    required String model,
    required String prompt,
  }) async {
    final response = await client.post(
      _ollamaGenerateUri(baseUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model.trim(),
        'stream': false,
        'options': {'temperature': 0.2},
        'prompt': prompt,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Ollama returned HTTP ${response.statusCode}. ${_responseErrorDetail(response.body)}Check that the model is available locally.',
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
    required String prompt,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const OllamaAiException('Enter your Gemini API key.');
    }

    final response = await client.post(
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
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.2},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Gemini returned HTTP ${response.statusCode}. ${_responseErrorDetail(response.body)}Check your API key and model name.',
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
    required String prompt,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const OllamaAiException('Enter your Groq API key.');
    }

    final response = await client.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
      },
      body: jsonEncode({
        'model': model.trim(),
        'temperature': 0.2,
        'max_completion_tokens': 1200,
        'messages': [
          {
            'role': 'system',
            'content':
                'You help structure user-provided investment research without inventing missing facts or giving personalized financial advice.',
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaAiException(
        'Groq returned HTTP ${response.statusCode}. ${_responseErrorDetail(response.body)}Check your API key and model name.',
      );
    }

    final decoded = jsonDecode(response.body);
    final choices = decoded is Map<String, dynamic> ? decoded['choices'] : null;
    if (choices is List && choices.isNotEmpty) {
      final message = choices.first is Map<String, dynamic>
          ? choices.first['message']
          : null;
      if (message is Map<String, dynamic>) {
        final text = _extractText(message['content']);
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    throw const OllamaAiException('Groq returned an empty response.');
  }

  String _extractText(Object? value) {
    if (value is String) {
      return value.trim();
    }

    if (value is List) {
      return value
          .map((item) {
            if (item is Map<String, dynamic>) {
              return '${item['text'] ?? item['content'] ?? ''}';
            }
            return '$item';
          })
          .join()
          .trim();
    }

    return '${value ?? ''}'.trim();
  }

  String _connectionErrorMessage(AiAnalysisProvider provider, Object error) {
    final detail = '$error';
    final webAbortHint =
        provider == AiAnalysisProvider.groq &&
            detail.toLowerCase().contains('aborttrigger')
        ? ' In Flutter Web this can happen when the browser aborts the direct Groq request. Try again, verify the key/model, or run the app on desktop/mobile or through a small backend proxy if the browser keeps aborting it.'
        : '';

    return 'Could not connect to ${provider.label}. $detail$webAbortHint';
  }

  String _responseErrorDetail(String body) {
    if (body.trim().isEmpty) {
      return '';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = '${error['message'] ?? ''}'.trim();
          if (message.isNotEmpty) {
            return '$message ';
          }
        }
        final message = '${decoded['message'] ?? ''}'.trim();
        if (message.isNotEmpty) {
          return '$message ';
        }
      }
    } catch (_) {
      final text = body.trim();
      if (text.isNotEmpty) {
        return '${text.length > 220 ? text.substring(0, 220) : text} ';
      }
    }

    return '';
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

  String _buildBusinessOverviewPrompt({
    required String ticker,
    required String rawResearch,
  }) {
    return '''
You are an investment research assistant converting the user's raw research notes into structured business overview fields.

Important:
- Use only the raw notes provided.
- Do not invent missing facts.
- If a field is missing or unclear, write "Needs verification: ..." and say what should be checked.
- Keep each field concise, plain-English, and useful for an investor checklist.
- Do not give personalized financial advice.
- Return valid JSON only. Do not include markdown fences or commentary.

Return exactly these JSON keys:
{
  "businessModel": "",
  "revenueSources": "",
  "mainSegment": "",
  "growthDriver": "",
  "earningsSignal": "",
  "analystRating": "",
  "stockTrend": "",
  "conclusion": ""
}

Ticker: ${ticker.toUpperCase()}

Raw research notes:
$rawResearch
''';
  }
}

class BusinessOverviewDraft {
  const BusinessOverviewDraft({
    required this.businessModel,
    required this.revenueSources,
    required this.mainSegment,
    required this.growthDriver,
    required this.earningsSignal,
    required this.analystRating,
    required this.stockTrend,
    required this.conclusion,
  });

  final String businessModel;
  final String revenueSources;
  final String mainSegment;
  final String growthDriver;
  final String earningsSignal;
  final String analystRating;
  final String stockTrend;
  final String conclusion;

  factory BusinessOverviewDraft.fromAiResponse(String response) {
    final jsonText = _extractJsonObject(response);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const OllamaAiException(
        'AI returned a response that was not a JSON object.',
      );
    }

    return BusinessOverviewDraft(
      businessModel: _readString(decoded, 'businessModel'),
      revenueSources: _readString(decoded, 'revenueSources'),
      mainSegment: _readString(decoded, 'mainSegment'),
      growthDriver: _readString(decoded, 'growthDriver'),
      earningsSignal: _readString(decoded, 'earningsSignal'),
      analystRating: _readString(decoded, 'analystRating'),
      stockTrend: _readString(decoded, 'stockTrend'),
      conclusion: _readString(decoded, 'conclusion'),
    );
  }

  static String _readString(Map<String, dynamic> data, String key) {
    return '${data[key] ?? ''}'.trim();
  }

  static String _extractJsonObject(String response) {
    final trimmed = response.trim();
    final fenced = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(trimmed);
    final candidate = fenced?.group(1)?.trim() ?? trimmed;

    if (candidate.startsWith('{') && candidate.endsWith('}')) {
      return candidate;
    }

    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return candidate.substring(start, end + 1);
    }

    throw const OllamaAiException(
      'AI did not return JSON. Try again or paste more structured source text.',
    );
  }
}

class OllamaAiException implements Exception {
  const OllamaAiException(this.message);

  final String message;

  @override
  String toString() => message;
}
