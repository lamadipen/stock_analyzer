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
          data: {'finalAction': 'Buy Zone', 'riskLevel': 'Low'},
        );
        await StockAnalysisStorage.saveReviewStatus(
          ticker: 'AAPL',
          section: 'Decision Summary',
          status: 'complete',
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
  });
}
