import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/financial_highlights_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/sector_comparison_content.dart';

class AnalysisResultsView extends StatelessWidget {
  final String ticker;
  const AnalysisResultsView({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final List<String> analysisSections = [
      'Business Overview',
      'Financial Highlights',
      'Competitor Study',
      'Economic Moat',
      'Growth Driver',
      'Valuation Method',
      'Margin of Safety',
      'Investment Risks',
      'Sale Target',
      'Implied Volatility (IV)',
      'Institutional Ownership',
      'Insider Activity',
      'Sector Comparison',
      'Short Term Investment',
      'Resources',
    ];

    return ListView.builder(
      itemCount: analysisSections.length,
      itemBuilder: (context, index) {
        final section = analysisSections[index];
        Widget content;

        if (section == 'Financial Highlights') {
          content = FinancialHighlightsContent(ticker: ticker);
        } else if (section == 'Financial Highlights') {
          content = FinancialHighlightsContent(ticker: ticker);
        } else if (section == 'Institutional Ownership') {
          content = FinancialHighlightsContent(ticker: ticker);
        } else if (section == 'Sector Comparison') {
          content = SectorComparisonContent(ticker: ticker);
        } else {
          content = Text('Details for $section will be displayed here.');
        }

        return CollapsibleSection(title: section, content: content);
      },
    );
  }
}
