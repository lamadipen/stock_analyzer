import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
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
        NotionBulletSummary(
          title: '${ticker.toUpperCase()} Financial Highlights',
          subtitle: 'Report view checklist for financial quality.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Revenue / sales',
              value: 'Look for consistent growth over the last 5-10 years.',
              icon: Icons.trending_up,
              tone: AppSummaryTone.success,
            ),
            NotionSummaryBullet(
              label: 'Net income',
              value:
                  'Look for consistent growth; if net income is noisy, check operating income.',
              icon: Icons.attach_money,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Cash flow from operations',
              value: 'Look for consistent growth over the last 5-10 years.',
              icon: Icons.account_balance_wallet_outlined,
              tone: AppSummaryTone.success,
            ),
            NotionSummaryBullet(
              label: 'Profitability',
              value:
                  'Gross and net profit margins should be consistent or increasing for 5 years; greater than 10% is generally good.',
              icon: Icons.percent,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Debt quality',
              value:
                  'Prefer current ratio above 1, debt to EBITDA below 3, and debt servicing ratio below 30%.',
              icon: Icons.warning_amber,
              tone: AppSummaryTone.warning,
            ),
          ],
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
