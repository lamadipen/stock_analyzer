import 'package:flutter_test/flutter_test.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_markdown_exporter.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';

void main() {
  group('StockAnalysisMarkdownExporter', () {
    test('writes connected section context from business overview', () {
      final markdown = StockAnalysisMarkdownExporter.buildMarkdown(
        ticker: 'ADBE',
        data: {
          StockAnalysisStorage.businessOverviewSection: {
            'qualityLabel': 'Strong',
            'qualityScore': 5,
            'businessModel': 'Subscription software',
            'revenueSources': 'Creative Cloud and Document Cloud',
            'items': [
              {'title': 'Clear business model', 'isChecked': true},
            ],
          },
        },
      );

      expect(markdown, contains('## Connected Section Context'));
      expect(
        markdown,
        contains(
          'Business Overview Signal:** Strong (5 score) -> Decision Business Quality Pass',
        ),
      );
      expect(
        markdown,
        contains(
          'Decision Summary Status:** Not saved yet. Use the Business Overview signal',
        ),
      );
      expect(markdown, contains('Decision Business Quality:** Pass'));
    });

    test('calls out mismatch between overview and decision summary', () {
      final markdown = StockAnalysisMarkdownExporter.buildMarkdown(
        ticker: 'ADBE',
        data: {
          StockAnalysisStorage.businessOverviewSection: {
            'qualityLabel': 'Weak',
            'qualityScore': 2,
          },
          StockAnalysisStorage.decisionSummarySection: {
            'businessQuality': 'Pass',
            'valuation': 'Fair',
            'entryPoint': 'Wait',
            'riskLevel': 'Medium',
            'finalAction': 'Watchlist',
          },
        },
      );

      expect(markdown, contains('Signal Mismatch'));
      expect(markdown, contains('maps to Fail'));
      expect(markdown, contains('set to Pass'));
    });
  });
}
