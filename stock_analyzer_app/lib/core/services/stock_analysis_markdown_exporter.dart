import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';

class StockAnalysisMarkdownExporter {
  const StockAnalysisMarkdownExporter._();

  static const List<String> _valuationMethods = [
    'Historic PE Comparison',
    'Primary Method -> Discounted Cash Flow (DCF) method',
    'Cash from Operations 1.5X more than net income -> Discounted Free Cash Flow (FCF) Method',
    'Net Income Increasing more consistently than Cash from operations (Financial Stocks) -> Discounted Net Income (DNI) Method',
    'Banks -> Price to Book Ratio',
    'REITs -> Dividend (DPU) Yield, Price to NAV Ratio',
    'Speculative Growth Stocks -> Price to Sales Growth Ratio, Comparing Price / Sales Ratio',
  ];

  static String buildMarkdown({
    required String ticker,
    required Map<String, dynamic> data,
  }) {
    final buffer = StringBuffer()
      ..writeln('# ${ticker.toUpperCase()} Investment Analysis')
      ..writeln()
      ..writeln('Generated: ${_formatDateTime(DateTime.now())}')
      ..writeln();

    _writeDecisionSummary(
      buffer,
      data[StockAnalysisStorage.decisionSummarySection],
    );
    _writeAiAnalysisSummary(
      buffer,
      data[StockAnalysisStorage.aiAnalysisSummarySection],
    );
    _writeReviewStatuses(buffer, data['reviewStatuses']);
    _writeCompetitorStudy(
      buffer,
      data[StockAnalysisStorage.competitorStudySection],
    );
    _writeEconomicMoat(buffer, data[StockAnalysisStorage.economicMoatSection]);
    _writeValuationMethod(
      buffer,
      data[StockAnalysisStorage.valuationMethodSection],
    );
    _writeMarginOfSafety(
      buffer,
      data[StockAnalysisStorage.marginOfSafetySection],
    );
    _writeSaleTargets(buffer, data[StockAnalysisStorage.saleTargetSection]);

    return buffer.toString().trimRight();
  }

  static void _writeDecisionSummary(StringBuffer buffer, Object? value) {
    buffer
      ..writeln('## Decision Summary')
      ..writeln();

    final data = _asMap(value);
    if (data == null) {
      buffer
        ..writeln('No decision summary saved yet.')
        ..writeln();
      return;
    }

    _writeBullet(buffer, 'Business Quality', data['businessQuality']);
    _writeBullet(buffer, 'Valuation', data['valuation']);
    _writeBullet(buffer, 'Entry Point', data['entryPoint']);
    _writeBullet(buffer, 'Risk Level', data['riskLevel']);
    _writeBullet(buffer, 'Final Action', data['finalAction']);
    final notes = '${data['notes'] ?? ''}'.trim();
    if (notes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Notes')
        ..writeln()
        ..writeln(notes)
        ..writeln();
    } else {
      buffer.writeln();
    }
  }

  static void _writeAiAnalysisSummary(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final summary = '${data['summary'] ?? ''}'.trim();
    if (summary.isEmpty) {
      return;
    }

    buffer
      ..writeln('## AI Analysis Summary')
      ..writeln()
      ..writeln(summary)
      ..writeln();
  }

  static void _writeReviewStatuses(StringBuffer buffer, Object? value) {
    final statuses = _asMap(value);
    if (statuses == null || statuses.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Review Progress')
      ..writeln();

    for (final entry in statuses.entries) {
      _writeBullet(buffer, entry.key, _humanizeStatus('${entry.value}'));
    }

    buffer.writeln();
  }

  static void _writeCompetitorStudy(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final parameters = data['parameters'];
    if (parameters is! List || parameters.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Competitor Study')
      ..writeln();

    for (final item in parameters.whereType<Map<String, dynamic>>()) {
      final checked = item['isChecked'] == true ? 'Yes' : 'No';
      final note = '${item['note'] ?? ''}'.trim();
      buffer.writeln(
        '- ${item['title'] ?? 'Parameter'}: $checked${note.isEmpty ? '' : ' - $note'}',
      );
    }

    buffer.writeln();
  }

  static void _writeEconomicMoat(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final items = data['items'];
    if (items is! List || items.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Economic Moat')
      ..writeln();

    for (final item in items.whereType<Map<String, dynamic>>()) {
      final mark = item['isChecked'] == true ? 'x' : ' ';
      buffer.writeln('- [$mark] ${item['title'] ?? 'Checklist item'}');
    }

    buffer.writeln();
  }

  static void _writeValuationMethod(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final checked = data['checked'];
    if (checked is! List || checked.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Valuation Method')
      ..writeln();

    for (var i = 0; i < _valuationMethods.length; i++) {
      final mark = i < checked.length && checked[i] == true ? 'x' : ' ';
      buffer.writeln('- [$mark] ${_valuationMethods[i]}');
    }

    buffer.writeln();
  }

  static void _writeMarginOfSafety(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    buffer
      ..writeln('## Margin of Safety')
      ..writeln();

    _writeBullet(
      buffer,
      'Great point of entry',
      data['isGreatEntry'] == true ? 'Yes' : 'No',
    );

    final buyPoints = data['buyPoints'];
    if (buyPoints is List && buyPoints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Buy Points')
        ..writeln();

      for (final item in buyPoints.whereType<Map<String, dynamic>>()) {
        buffer.writeln(
          '- ${item['buyPoint'] ?? 'Buy point'}: target ${item['targetPrice'] ?? ''}, created ${item['dateCreated'] ?? ''}',
        );
      }
    }

    final referenceLinks = data['referenceLinks'];
    if (referenceLinks is List && referenceLinks.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### References')
        ..writeln();

      for (final item in referenceLinks.whereType<Map<String, dynamic>>()) {
        final label = '${item['label'] ?? 'Reference'}'.trim();
        final url = '${item['url'] ?? ''}'.trim();
        if (url.isEmpty) {
          buffer.writeln('- $label');
        } else {
          buffer.writeln('- [$label]($url)');
        }
      }
    }

    buffer.writeln();
  }

  static void _writeSaleTargets(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final targets = data['targets'];
    if (targets is! List || targets.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Sale Targets')
      ..writeln();

    for (final item in targets.whereType<Map<String, dynamic>>()) {
      _writeBullet(buffer, 'Title', item['title']);
      _writeBullet(buffer, 'Start Date', _formatStoredDate(item['startDate']));
      _writeBullet(buffer, 'Principal', item['principal']);
      _writeBullet(
        buffer,
        'Growth Rate',
        '${item['growthRatePercent'] ?? ''}%',
      );
      _writeBullet(buffer, 'Years', item['years']);
      buffer.writeln();
    }
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static void _writeBullet(StringBuffer buffer, String label, Object? value) {
    buffer.writeln('- **$label:** ${value ?? 'Not set'}');
  }

  static String _humanizeStatus(String value) {
    return switch (value) {
      'notStarted' => 'Not Started',
      'inReview' => 'In Review',
      'complete' => 'Complete',
      _ => value,
    };
  }

  static String _formatStoredDate(Object? value) {
    final date = DateTime.tryParse('$value');
    if (date == null) {
      return '$value';
    }

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime value) {
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
