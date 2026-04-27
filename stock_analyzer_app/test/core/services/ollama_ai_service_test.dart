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
          baseUrl: 'http://localhost:11434',
          model: 'gemma3',
          analysisMarkdown: '# AAPL',
        );

        expect(summary, 'AI summary');
        expect(requestedUri, Uri.parse('http://localhost:11434/api/generate'));
      },
    );

    test('throws a readable exception for non-success responses', () async {
      final service = OllamaAiService(
        client: MockClient((request) async {
          return http.Response('missing model', 404);
        }),
      );

      expect(
        () => service.generateAnalysisSummary(
          baseUrl: 'http://localhost:11434',
          model: 'missing-model',
          analysisMarkdown: '# AAPL',
        ),
        throwsA(isA<OllamaAiException>()),
      );
    });
  });
}
