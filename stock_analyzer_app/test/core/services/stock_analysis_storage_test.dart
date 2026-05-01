import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';

void main() {
  group('StockAnalysisStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'loads saved ticker summaries sorted by most recently updated',
      () async {
        await StockAnalysisStorage.saveSection(
          ticker: 'AAPL',
          section: StockAnalysisStorage.decisionSummarySection,
          data: {
            'businessQuality': 'Pass',
            'valuation': 'Attractive',
            'entryPoint': 'Good',
            'finalAction': 'Buy Zone',
            'riskLevel': 'Low',
            'notes': 'Clear thesis.',
          },
        );
        await Future<void>.delayed(const Duration(milliseconds: 2));
        await StockAnalysisStorage.saveSection(
          ticker: 'MSFT',
          section: StockAnalysisStorage.decisionSummarySection,
          data: {'finalAction': 'Watchlist', 'riskLevel': 'Medium'},
        );

        final summaries = await StockAnalysisStorage.loadSavedTickerSummaries();

        expect(summaries.map((summary) => summary.ticker), ['MSFT', 'AAPL']);
        expect(summaries.first.finalAction, 'Watchlist');
        expect(summaries.first.riskLevel, 'Medium');
        expect(summaries.last.finalAction, 'Buy Zone');
        expect(summaries.last.riskLevel, 'Low');
        expect(summaries.last.completedSections, 1);
        expect(
          summaries.last.totalSections,
          StockAnalysisStorage.analysisSectionCount,
        );
      },
    );

    test('exports and imports all saved ticker data as JSON backup', () async {
      await StockAnalysisStorage.saveSection(
        ticker: 'ADBE',
        section: StockAnalysisStorage.decisionSummarySection,
        data: {'finalAction': 'Watchlist', 'riskLevel': 'Medium'},
      );
      await StockAnalysisStorage.saveSection(
        ticker: 'MSFT',
        section: StockAnalysisStorage.businessOverviewSection,
        data: {'qualityLabel': 'Strong', 'qualityScore': 5},
      );

      final backupJson = await StockAnalysisStorage.exportAllDataJson();

      SharedPreferences.setMockInitialValues({});
      final importedCount = await StockAnalysisStorage.importAllDataJson(
        backupJson,
      );
      final summaries = await StockAnalysisStorage.loadSavedTickerSummaries();
      final msft = await StockAnalysisStorage.loadSection(
        ticker: 'MSFT',
        section: StockAnalysisStorage.businessOverviewSection,
      );

      expect(importedCount, 2);
      expect(
        summaries.map((summary) => summary.ticker),
        containsAll(['ADBE', 'MSFT']),
      );
      expect(msft?['qualityLabel'], 'Strong');
    });

    test('rejects import JSON without a data object', () {
      expect(
        () => StockAnalysisStorage.importAllDataJson('{"schemaVersion":1}'),
        throwsA(isA<StockAnalysisImportException>()),
      );
    });
  });
}
