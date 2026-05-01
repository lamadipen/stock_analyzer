import 'package:flutter_test/flutter_test.dart';
import 'package:stock_analyzer_app/core/services/section_completion_rules.dart';

void main() {
  group('SectionCompletionRules', () {
    test('requires Business Overview fields and checklist signals', () {
      final tickerData = {
        'businessOverview': {
          'businessModel': 'Subscription software',
          'revenueSources': 'Creative Cloud',
          'mainSegment': 'Digital Media',
          'growthDriver': 'AI workflows',
          'earningsSignal': 'EPS expected to grow',
          'analystRating': 'Buy consensus',
          'stockTrend': 'Long-term uptrend',
          'items': [
            {'isChecked': true},
            {'isChecked': true},
            {'isChecked': true},
            {'isChecked': true},
            {'isChecked': true},
          ],
        },
      };

      expect(
        SectionCompletionRules.isComplete(
          sectionTitle: 'Business Overview',
          tickerData: tickerData,
        ),
        isTrue,
      );
    });

    test('does not complete Valuation Method without a selected method', () {
      expect(
        SectionCompletionRules.isComplete(
          sectionTitle: 'Valuation Method',
          tickerData: {
            'valuationMethod': {
              'checked': [false, false],
            },
          },
        ),
        isFalse,
      );
    });

    test('completes Margin of Safety only with entry and buy point', () {
      expect(
        SectionCompletionRules.isComplete(
          sectionTitle: 'Margin of Safety',
          tickerData: {
            'marginOfSafety': {
              'isGreatEntry': true,
              'buyPoints': [
                {'buyPoint': 'Support retest', 'targetPrice': '200'},
              ],
            },
          },
        ),
        isTrue,
      );
    });
  });
}
