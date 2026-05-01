import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class InstitutionalOwnershipContent extends StatelessWidget {
  final String ticker;
  const InstitutionalOwnershipContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final institutionalActivityLinks = buildInstitutionalOwnershipLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotionBulletSummary(
          title: '${ticker.toUpperCase()} Institutional Ownership',
          subtitle: 'Report view for large-holder activity.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Ownership signal',
              value:
                  'Review whether institutions are accumulating, reducing, or maintaining exposure.',
              icon: Icons.account_balance,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Interpretation',
              value:
                  'Institutional buying can support confidence; selling can flag risk or rebalancing pressure.',
              icon: Icons.compare_arrows,
              tone: AppSummaryTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Institutional Ownership References:',
          links: institutionalActivityLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
