import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class SectorComparisonContent extends StatelessWidget {
  final String ticker;
  const SectorComparisonContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final profLinks = buildSectorComparisionLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotionBulletSummary(
          title: '${ticker.toUpperCase()} Sector Comparison',
          subtitle: 'Report view for market and sector context.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Sector performance',
              value:
                  'Compare the stock against sector performance to separate company-specific strength from market-wide moves.',
              icon: Icons.pie_chart_outline,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Relative strength',
              value:
                  'A stock outperforming its sector can confirm momentum; underperformance needs explanation.',
              icon: Icons.compare_arrows,
              tone: AppSummaryTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Sector Performance References:',
          links: profLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
