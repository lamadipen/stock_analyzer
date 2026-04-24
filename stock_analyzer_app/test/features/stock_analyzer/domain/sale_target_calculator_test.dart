import 'package:flutter_test/flutter_test.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/sale_target_calculator.dart';

void main() {
  group('SaleTargetCalculator', () {
    test('calculates compound interest target price', () {
      final targetPrice = SaleTargetCalculator.calculateTargetPrice(
        principal: 8426,
        growthRatePercent: 10,
        years: 5,
      );

      expect(targetPrice, closeTo(13570.16, 0.01));
    });

    test('calculates maturity date by adding years', () {
      final maturityDate = SaleTargetCalculator.calculateMaturityDate(
        startDate: DateTime(2024, 4, 26),
        years: 5,
      );

      expect(maturityDate, DateTime(2029, 4, 26));
    });

    test('clamps leap day maturity dates to the last day of February', () {
      final maturityDate = SaleTargetCalculator.calculateMaturityDate(
        startDate: DateTime(2024, 2, 29),
        years: 1,
      );

      expect(maturityDate, DateTime(2025, 2, 28));
    });
  });
}
