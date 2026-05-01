import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class InsiderActivityContent extends StatelessWidget {
  final String ticker;
  const InsiderActivityContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final insiderActivityLinks = buildInsiderActivityLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotionBulletSummary(
          title: '${ticker.toUpperCase()} Insider Activity',
          subtitle: 'Report view for management and insider trading signal.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Insider buying',
              value:
                  'Can indicate confidence when purchases are meaningful and not routine.',
              icon: Icons.trending_up,
              tone: AppSummaryTone.success,
            ),
            NotionSummaryBullet(
              label: 'Insider selling',
              value:
                  'Can be routine, but repeated or unusual selling should be checked against the thesis.',
              icon: Icons.warning_amber,
              tone: AppSummaryTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Insider Trading Activity References:',
          links: insiderActivityLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
