import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StockAnalysisStorage {
  const StockAnalysisStorage._();

  static const String marginOfSafetySection = 'marginOfSafety';
  static const String _keyPrefix = 'stock_analysis';

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
