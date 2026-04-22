import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/content_registry.dart';

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
      'Short Term Investment', // This will use the default widget
      'Resources', // This will use the default widget
    ];

    return ListView.builder(
      itemCount: analysisSections.length,
      itemBuilder: (context, index) {
        final section = analysisSections[index];
        // The if-else chain is now replaced with a single lookup
        final content = getContentWidget(section, ticker);

        return CollapsibleSection(title: section, content: content);
      },
    );
  }
}