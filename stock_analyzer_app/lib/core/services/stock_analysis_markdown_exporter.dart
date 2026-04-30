import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/analysis_section_models.dart';

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
    _writeBusinessOverview(
      buffer,
      data[StockAnalysisStorage.businessOverviewSection],
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
    final summary = DecisionSummary.fromJson(data);

    _writeBullet(buffer, 'Business Quality', summary.businessQuality);
    _writeBullet(buffer, 'Valuation', summary.valuation);
    _writeBullet(buffer, 'Entry Point', summary.entryPoint);
    _writeBullet(buffer, 'Risk Level', summary.riskLevel);
    _writeBullet(buffer, 'Final Action', summary.finalAction);
    final notes = summary.notes.trim();
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

  static void _writeBusinessOverview(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    buffer
      ..writeln('## Business Overview')
      ..writeln();

    _writeBullet(buffer, 'Business Quality', data['qualityLabel']);
    _writeBullet(buffer, 'Quality Score', data['qualityScore']);
    _writeBullet(buffer, 'Business Model', data['businessModel']);
    _writeBullet(buffer, 'Revenue Sources', data['revenueSources']);
    _writeBullet(buffer, 'Main Segment', data['mainSegment']);
    _writeBullet(buffer, 'Growth Driver', data['growthDriver']);
    _writeBullet(buffer, 'Earnings Signal', data['earningsSignal']);
    _writeBullet(buffer, 'Stock Trend', data['stockTrend']);

    final items = data['items'];
    if (items is List && items.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Business Quality Checklist')
        ..writeln();

      for (final item in items.whereType<Map<String, dynamic>>()) {
        final mark = item['isChecked'] == true ? 'x' : ' ';
        buffer.writeln('- [$mark] ${item['title'] ?? 'Checklist item'}');
      }
    }

    final rawResearch = '${data['rawResearch'] ?? ''}'.trim();
    if (rawResearch.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Raw Research')
        ..writeln()
        ..writeln(rawResearch);
    }

    buffer.writeln();
  }

  static void _writeCompetitorStudy(StringBuffer buffer, Object? value) {
    final data = _asMap(value);
    if (data == null) {
      return;
    }

    final study = CompetitorStudy.fromJson(data);
    if (study.parameters.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Competitor Study')
      ..writeln();

    for (final item in study.parameters) {
      final checked = item.isChecked ? 'Yes' : 'No';
      final note = item.note.trim();
      buffer.writeln(
        '- ${item.title.isEmpty ? 'Parameter' : item.title}: $checked${note.isEmpty ? '' : ' - $note'}',
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
    final marginOfSafety = MarginOfSafety.fromJson(data);

    buffer
      ..writeln('## Margin of Safety')
      ..writeln();

    _writeBullet(
      buffer,
      'Great point of entry',
      marginOfSafety.isGreatEntry ? 'Yes' : 'No',
    );

    if (marginOfSafety.buyPoints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Buy Points')
        ..writeln();

      for (final item in marginOfSafety.buyPoints) {
        buffer.writeln(
          '- ${item.buyPoint.isEmpty ? 'Buy point' : item.buyPoint}: target ${item.targetPrice}, created ${item.dateCreated}',
        );
      }
    }

    if (marginOfSafety.referenceLinks.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### References')
        ..writeln();

      for (final item in marginOfSafety.referenceLinks) {
        final label = item.label.trim().isEmpty ? 'Reference' : item.label;
        final url = item.url.trim();
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

    final section = SaleTargetSection.fromJson(data);
    if (section.targets.isEmpty) {
      return;
    }

    buffer
      ..writeln('## Sale Targets')
      ..writeln();

    for (final item in section.targets) {
      _writeBullet(buffer, 'Title', item.title);
      _writeBullet(buffer, 'Start Date', _formatStoredDate(item.startDate));
      _writeBullet(buffer, 'Principal', item.principal);
      _writeBullet(buffer, 'Growth Rate', '${item.growthRatePercent}%');
      _writeBullet(buffer, 'Years', item.years);
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
