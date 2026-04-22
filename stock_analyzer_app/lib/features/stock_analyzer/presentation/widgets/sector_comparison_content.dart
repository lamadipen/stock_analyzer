import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SectorComparisonContent extends StatelessWidget {
  final String ticker;
  const SectorComparisonContent({super.key, required this.ticker});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finLinks = buildFinancialLinks(ticker);
    final profLinks = buildProfitabilityLinks(ticker);
    final debtLinks = buildDebtLinks(ticker);

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

        // ---- profitability metrics ----
        const Text(
          'Profitability Metrics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gross Profit Margin: consistent or increasing for 5 years.',
        ),
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

        // ---- Conservative Debt section ----
        const Text(
          'Conservative Debt',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Current Ratio = Current Assets / Current Liabilities > 1'),
        const SizedBox(height: 8),
        const Text('Debt to EBITDA Ratio = Total Debt / EBITDA < 3'),
        const SizedBox(height: 8),
        const Text('Debt Servicing Ratio < 30%'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Look for a Current Ratio of at least 1, ideally 2. Any value below 1 means the company\'s short-term obligations exceed its short-term assets.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Total Debt = short term + long term debt'),
              SizedBox(height: 4),
              Text(
                'EBITDA = Earnings Before Interest, Taxes, Depreciation & Amortization',
              ),
              SizedBox(height: 4),
              Text(
                'Debt Servicing ratio = net interest expense / cash flow from operations * 100',
              ),
              SizedBox(height: 8),
              Text(
                'For Banks, Financial Institutions, Insurance, REITs, Property Developer, Commodity above calculation doesn\'t work. We need to look for Common Equity Tier 1 Ratio > 10% to add the stock into watchlist. Search google for this ratio.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ---- debt & solvency references ----
        const Text(
          'Debt & Solvency References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: debtLinks.entries.map((e) {
            return ActionChip(
              label: Text(e.key),
              onPressed: () => _launch(e.value),
              backgroundColor: Colors.orange.shade50,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // ---- income statement references ----
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
}
