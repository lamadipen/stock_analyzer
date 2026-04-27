import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedTickerSummary {
  const SavedTickerSummary({
    required this.ticker,
    required this.updatedAt,
    required this.finalAction,
    required this.riskLevel,
    required this.completedSections,
    required this.totalSections,
  });

  final String ticker;
  final DateTime? updatedAt;
  final String finalAction;
  final String riskLevel;
  final int completedSections;
  final int totalSections;

  double get completionProgress {
    if (totalSections == 0) {
      return 0;
    }

    return completedSections / totalSections;
  }
}

class StockAnalysisStorage {
  const StockAnalysisStorage._();

  static const String competitorStudySection = 'competitorStudy';
  static const String decisionSummarySection = 'decisionSummary';
  static const String economicMoatSection = 'economicMoat';
  static const String marginOfSafetySection = 'marginOfSafety';
  static const String saleTargetSection = 'saleTarget';
  static const String valuationMethodSection = 'valuationMethod';
  static const String _keyPrefix = 'stock_analysis';
  static const String _reviewStatusesKey = 'reviewStatuses';
  static const int analysisSectionCount = 15;

  static Future<Map<String, dynamic>?> loadSection({
    required String ticker,
    required String section,
  }) async {
    final data = await _loadTickerData(ticker);
    final sectionData = data[section];
    if (sectionData is Map<String, dynamic>) {
      return sectionData;
    }
    return null;
  }

  static Future<void> saveSection({
    required String ticker,
    required String section,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tickerData = await _loadTickerData(ticker);
    final upperTicker = ticker.toUpperCase();

    tickerData['ticker'] = upperTicker;
    tickerData['updatedAt'] = DateTime.now().toIso8601String();
    tickerData[section] = data;

    await prefs.setString(_keyFor(upperTicker), jsonEncode(tickerData));
  }

  static Future<void> clearSection({
    required String ticker,
    required String section,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tickerData = await _loadTickerData(ticker);
    tickerData.remove(section);
    tickerData['ticker'] = ticker.toUpperCase();
    tickerData['updatedAt'] = DateTime.now().toIso8601String();
    await prefs.setString(_keyFor(ticker), jsonEncode(tickerData));
  }

  static Future<Map<String, dynamic>> loadTickerAnalysis({
    required String ticker,
  }) async {
    return _loadTickerData(ticker);
  }

  static Future<List<SavedTickerSummary>> loadSavedTickerSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final summaries = <SavedTickerSummary>[];

    for (final key in prefs.getKeys()) {
      if (!key.startsWith('${_keyPrefix}_')) {
        continue;
      }

      final rawData = prefs.getString(key);
      if (rawData == null) {
        continue;
      }

      final decoded = jsonDecode(rawData);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      final ticker =
          '${decoded['ticker'] ?? key.substring(_keyPrefix.length + 1)}'
              .toUpperCase();
      final decisionSummary = decoded[decisionSummarySection];
      final reviewStatuses = decoded[_reviewStatusesKey];
      final completedSections = reviewStatuses is Map<String, dynamic>
          ? reviewStatuses.values.where((status) => status == 'complete').length
          : 0;

      summaries.add(
        SavedTickerSummary(
          ticker: ticker,
          updatedAt: DateTime.tryParse('${decoded['updatedAt'] ?? ''}'),
          finalAction: decisionSummary is Map<String, dynamic>
              ? '${decisionSummary['finalAction'] ?? 'Watchlist'}'
              : 'Watchlist',
          riskLevel: decisionSummary is Map<String, dynamic>
              ? '${decisionSummary['riskLevel'] ?? 'Medium'}'
              : 'Medium',
          completedSections: completedSections,
          totalSections: analysisSectionCount,
        ),
      );
    }

    summaries.sort((a, b) {
      final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return summaries;
  }

  static Future<Map<String, String>> loadReviewStatuses({
    required String ticker,
  }) async {
    final tickerData = await _loadTickerData(ticker);
    final statuses = tickerData[_reviewStatusesKey];
    if (statuses is! Map<String, dynamic>) {
      return <String, String>{};
    }

    return statuses.map((key, value) => MapEntry(key, '$value'));
  }

  static Future<void> saveReviewStatus({
    required String ticker,
    required String section,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tickerData = await _loadTickerData(ticker);
    final upperTicker = ticker.toUpperCase();
    final statuses = Map<String, dynamic>.from(
      tickerData[_reviewStatusesKey] is Map<String, dynamic>
          ? tickerData[_reviewStatusesKey] as Map<String, dynamic>
          : <String, dynamic>{},
    );

    statuses[section] = status;
    tickerData['ticker'] = upperTicker;
    tickerData['updatedAt'] = DateTime.now().toIso8601String();
    tickerData[_reviewStatusesKey] = statuses;

    await prefs.setString(_keyFor(upperTicker), jsonEncode(tickerData));
  }

  static Future<Map<String, dynamic>> _loadTickerData(String ticker) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_keyFor(ticker));
    if (rawData == null) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(rawData);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static String _keyFor(String ticker) {
    return '${_keyPrefix}_${ticker.toUpperCase()}';
  }
}
