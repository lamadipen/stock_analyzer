class SectionCompletionRules {
  const SectionCompletionRules._();

  static const Map<String, String> sectionStorageKeys = {
    'Decision Summary': 'decisionSummary',
    'AI Analysis Summary': 'aiAnalysisSummary',
    'Business Overview': 'businessOverview',
    'Competitor Study': 'competitorStudy',
    'Economic Moat': 'economicMoat',
    'Valuation Method': 'valuationMethod',
    'Margin of Safety': 'marginOfSafety',
    'Price Alerts / Target Tracking': 'priceAlerts',
    'Sale Target': 'saleTarget',
  };

  static bool isComplete({
    required String sectionTitle,
    required Map<String, dynamic> tickerData,
  }) {
    final sectionKey = sectionStorageKeys[sectionTitle];
    final data = sectionKey == null ? null : tickerData[sectionKey];
    if (data is! Map<String, dynamic>) {
      return false;
    }

    return switch (sectionTitle) {
      'Decision Summary' => _hasAllText(data, const [
        'businessQuality',
        'valuation',
        'entryPoint',
        'riskLevel',
        'finalAction',
        'notes',
      ]),
      'AI Analysis Summary' => _hasText(data['summary']),
      'Business Overview' => _businessOverviewComplete(data),
      'Competitor Study' => _competitorStudyComplete(data),
      'Economic Moat' => _checkedCount(data['items']) >= 4,
      'Valuation Method' => _checkedCount(data['checked']) > 0,
      'Margin of Safety' => _marginOfSafetyComplete(data),
      'Price Alerts / Target Tracking' => _hasAllText(data, const [
        'currentPrice',
        'buyZone',
        'sellTarget',
        'marginOfSafetyPrice',
      ]),
      'Sale Target' => _saleTargetComplete(data),
      _ => false,
    };
  }

  static int completedCount({
    required Iterable<String> sectionTitles,
    required Map<String, dynamic> tickerData,
  }) {
    return sectionTitles.where((title) {
      return isComplete(sectionTitle: title, tickerData: tickerData);
    }).length;
  }

  static bool _businessOverviewComplete(Map<String, dynamic> data) {
    return _hasAllText(data, const [
          'businessModel',
          'revenueSources',
          'mainSegment',
          'growthDriver',
          'earningsSignal',
          'analystRating',
          'stockTrend',
        ]) &&
        _checkedCount(data['items']) >= 5;
  }

  static bool _competitorStudyComplete(Map<String, dynamic> data) {
    final parameters = data['parameters'];
    if (parameters is! List) {
      return false;
    }

    final completedParameters = parameters.where((parameter) {
      if (parameter is! Map<String, dynamic>) {
        return false;
      }
      return parameter['isChecked'] == true && _hasText(parameter['note']);
    }).length;

    return completedParameters >= 5;
  }

  static bool _marginOfSafetyComplete(Map<String, dynamic> data) {
    if (data['isGreatEntry'] != true) {
      return false;
    }

    final buyPoints = data['buyPoints'];
    if (buyPoints is! List) {
      return false;
    }

    return buyPoints.any((buyPoint) {
      if (buyPoint is! Map<String, dynamic>) {
        return false;
      }
      return _hasText(buyPoint['buyPoint']) &&
          _hasText(buyPoint['targetPrice']);
    });
  }

  static bool _saleTargetComplete(Map<String, dynamic> data) {
    final targets = data['targets'];
    if (targets is! List) {
      return false;
    }

    return targets.any((target) {
      if (target is! Map<String, dynamic>) {
        return false;
      }
      return _hasText(target['title']) &&
          _readNumber(target['principal']) > 0 &&
          _readNumber(target['growthRatePercent']) > 0 &&
          _readNumber(target['years']) > 0;
    });
  }

  static bool _hasAllText(Map<String, dynamic> data, List<String> keys) {
    return keys.every((key) => _hasText(data[key]));
  }

  static bool _hasText(Object? value) {
    return '${value ?? ''}'.trim().isNotEmpty;
  }

  static int _checkedCount(Object? value) {
    if (value is List) {
      return value.where((item) {
        if (item is bool) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          return item['isChecked'] == true;
        }
        return false;
      }).length;
    }
    return 0;
  }

  static num _readNumber(Object? value) {
    if (value is num) {
      return value;
    }
    return num.tryParse('${value ?? ''}'.replaceAll(',', '').trim()) ?? 0;
  }
}
