import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:url_launcher/url_launcher.dart';

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
        } else {
          content = Text('Details for $section will be displayed here.');
        }

        return CollapsibleSection(title: section, content: content);
      },
    );
  }
}

class FinancialHighlightsContent extends StatelessWidget {
  final String ticker;
  const FinancialHighlightsContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final finLinks = buildFinancialLinks(ticker);
    final profLinks = buildProfitabilityLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text(
          'Revenue/Sales: Consistently increasing over the last 5-10 years.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Net Income: Consistently increasing over the last 5-10 years.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Cash Flow from Operations: Consistently increasing over the last 5-10 years.',
        ),
        const SizedBox(height: 16),

        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Note: If net income is not consistently increasing, look at operating income.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        // ---- reference chips ----
        const Text(
          'Income Statement References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: finLinks.entries.map((e) {
            return ActionChip(
              label: Text(e.key),
              onPressed: () => _launch(e.value),
              backgroundColor: Colors.blueGrey.shade50,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // ---- profitability metrics ----
        const Text(
          'Profitability Metrics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Gross Profit Margin: consistent or increasing for 5 years.'),
        const SizedBox(height: 8),
        const Text('Net Profit Margin: consistent or increasing for 5 years.'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Increasing / Consistent for 5 Years (Greater than 10% is considered good).',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        // ---- profitability references ----
        const Text(
          'Profitability References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profLinks.entries.map((e) {
            return ActionChip(
              label: Text(e.key),
              onPressed: () => _launch(e.value),
              backgroundColor: Colors.green.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }
}
