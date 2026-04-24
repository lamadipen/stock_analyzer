import 'dart:math' as math;

class SaleTargetCalculator {
  const SaleTargetCalculator._();

  static double calculateTargetPrice({
    required double principal,
    required double growthRatePercent,
    required int years,
  }) {
    if (principal < 0 || growthRatePercent < 0 || years < 0) {
      throw ArgumentError(
        'Principal, growth rate, and years must be positive.',
      );
    }

    return principal * math.pow(1 + growthRatePercent / 100, years);
  }

  static DateTime calculateMaturityDate({
    required DateTime startDate,
    required int years,
  }) {
    if (years < 0) {
      throw ArgumentError('Years must be positive.');
    }

    final targetYear = startDate.year + years;
    final targetDay = math.min(
      startDate.day,
      _daysInMonth(targetYear, startDate.month),
    );

    return DateTime(
      targetYear,
      startDate.month,
      targetDay,
      startDate.hour,
      startDate.minute,
      startDate.second,
      startDate.millisecond,
      startDate.microsecond,
    );
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
