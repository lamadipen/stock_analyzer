import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stock_analyzer_app/core/services/ollama_ai_service.dart';

void main() {
  group('OllamaAiService', () {
    test(
      'posts to Ollama generate endpoint and returns response text',
      () async {
        Uri? requestedUri;
        final service = OllamaAiService(
          client: MockClient((request) async {
            requestedUri = request.url;
            return http.Response('{"response":"AI summary","done":true}', 200);
          }),
        );

        final summary = await service.generateAnalysisSummary(
          provider: AiAnalysisProvider.ollama,
          baseUrl: 'http://localhost:11434',
          model: 'gemma3',
          analysisMarkdown: '# AAPL',
        );

        expect(summary, 'AI summary');
        expect(requestedUri, Uri.parse('http://localhost:11434/api/generate'));
      },
    );

    test('posts to Gemini and extracts candidate text', () async {
      Uri? requestedUri;
      String? apiKey;
      final service = OllamaAiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          apiKey = request.headers['x-goog-api-key'];
          return http.Response(
            '{"candidates":[{"content":{"parts":[{"text":"Gemini summary"}]}}]}',
            200,
          );
        }),
      );

      final summary = await service.generateAnalysisSummary(
        provider: AiAnalysisProvider.gemini,
        baseUrl: '',
        model: 'gemini-2.5-flash',
        apiKey: 'gemini-key',
        analysisMarkdown: '# AAPL',
      );

      expect(summary, 'Gemini summary');
      expect(
        requestedUri,
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
        ),
      );
      expect(apiKey, 'gemini-key');
    });

    test('posts to Groq and extracts chat completion content', () async {
      Uri? requestedUri;
      String? authorization;
      final service = OllamaAiService(
        client: MockClient((request) async {
          requestedUri = request.url;
          authorization = request.headers['Authorization'];
          return http.Response(
            '{"choices":[{"message":{"content":"Groq summary"}}]}',
            200,
          );
        }),
      );

      final summary = await service.generateAnalysisSummary(
        provider: AiAnalysisProvider.groq,
        baseUrl: '',
        model: 'llama-3.3-70b-versatile',
        apiKey: 'groq-key',
        analysisMarkdown: '# AAPL',
      );

      expect(summary, 'Groq summary');
      expect(
        requestedUri,
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      );
      expect(authorization, 'Bearer groq-key');
    });

    test('throws a readable exception for non-success responses', () async {
      final service = OllamaAiService(
        client: MockClient((request) async {
          return http.Response('missing model', 404);
        }),
      );

      expect(
        () => service.generateAnalysisSummary(
          provider: AiAnalysisProvider.ollama,
          baseUrl: 'http://localhost:11434',
          model: 'missing-model',
          analysisMarkdown: '# AAPL',
        ),
        throwsA(isA<OllamaAiException>()),
      );
    });
  });
}
