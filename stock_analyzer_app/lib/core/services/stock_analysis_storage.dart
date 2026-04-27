import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
