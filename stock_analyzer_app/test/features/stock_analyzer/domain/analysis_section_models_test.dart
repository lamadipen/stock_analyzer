import 'package:flutter_test/flutter_test.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/analysis_section_models.dart';

void main() {
  group('Analysis section models', () {
    test('DecisionSummary reads legacy map values with defaults', () {
      final summary = DecisionSummary.fromJson({
        'businessQuality': 'Pass',
        'finalAction': 'Buy Zone',
        'notes': 'Strong product suite',
      });

      expect(summary.businessQuality, 'Pass');
      expect(summary.valuation, 'Fair');
      expect(summary.entryPoint, 'Wait');
      expect(summary.riskLevel, 'Medium');
      expect(summary.finalAction, 'Buy Zone');
      expect(summary.notes, 'Strong product suite');
      expect(summary.toJson()['businessQuality'], 'Pass');
    });

    test('SaleTargetSection round trips targets and calculated values', () {
      final section = SaleTargetSection.fromJson({
        'savedAt': '2026-04-30T10:00:00.000',
        'targets': [
          {
            'title': '1st Level Goal',
            'startDate': '2026-04-30T00:00:00.000',
            'principal': 100,
            'growthRatePercent': 10,
            'years': 2,
          },
        ],
      });

      expect(section.savedAt?.year, 2026);
      expect(section.targets.single.targetPrice, closeTo(121, 0.0001));
      expect(section.targets.single.maturityDate.year, 2028);
      expect(section.toJson()['targets'], isA<List<dynamic>>());
    });

    test('MarginOfSafety round trips buy points and references', () {
      final marginOfSafety = MarginOfSafety.fromJson({
        'savedAt': '2026-04-30T10:00:00.000',
        'isGreatEntry': true,
        'buyPoints': [
          {
            'dateCreated': '04-30-2026',
            'buyPoint': 'Support retest',
            'targetPrice': '200',
          },
        ],
        'referenceLinks': [
          {'label': 'Chart', 'url': 'https://example.com/chart'},
        ],
      });

      expect(marginOfSafety.isGreatEntry, isTrue);
      expect(marginOfSafety.buyPoints.single.buyPoint, 'Support retest');
      expect(marginOfSafety.referenceLinks.single.label, 'Chart');
      expect(marginOfSafety.toJson()['referenceLinks'], isA<List<dynamic>>());
    });

    test('CompetitorStudy round trips comparison parameters', () {
      final study = CompetitorStudy.fromJson({
        'parameters': [
          {
            'title': 'Market Capitalization',
            'isChecked': true,
            'note': '1st Rank',
          },
        ],
      });

      expect(study.parameters.single.title, 'Market Capitalization');
      expect(study.parameters.single.isChecked, isTrue);
      expect(study.parameters.single.note, '1st Rank');
      expect(study.toJson()['parameters'], isA<List<dynamic>>());
    });
  });
}
