import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';

class AnalysisResultsView extends StatelessWidget {
  const AnalysisResultsView({super.key});

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
        return CollapsibleSection(
          title: section,
          content: Text('Details for $section will be displayed here.'),
        );
      },
    );
  }
}
