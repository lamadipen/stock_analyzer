import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class FinancialHighlightsContent extends StatelessWidget {
  final String ticker;
  const FinancialHighlightsContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final finLinks = buildFinancialLinks(ticker);
    final profLinks = buildProfitabilityLinks(ticker);
    final debtLinks = buildDebtLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChecklistCard(
          items: [
            ChecklistCardItem(
              title:
                  'Revenue/Sales: Consistently increasing over the last 5-10 years.',
            ),
            ChecklistCardItem(
              title:
                  'Net Income: Consistently increasing over the last 5-10 years.',
            ),
            ChecklistCardItem(
              title:
                  'Cash Flow from Operations: Consistently increasing over the last 5-10 years.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'If net income is not consistently increasing, look at operating income.',
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
        const AppNote(
          tone: AppNoteTone.success,
          child: Text(
            'Increasing / Consistent for 5 Years (Greater than 10% is considered good).',
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
        const AppNote(
          tone: AppNoteTone.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Look for a Current Ratio of at least 1, ideally 2. Any value below 1 means the company\'s short-term obligations exceed its short-term assets.',
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
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ReferenceLinks(
          title: 'Debt & Solvency References:',
          links: debtLinks,
          color: Colors.orange,
        ),

        const SizedBox(height: 16),

        ReferenceLinks(title: 'Income Statement References:', links: finLinks),

        const SizedBox(height: 16),

        ReferenceLinks(
          title: 'Profitability References:',
          links: profLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
