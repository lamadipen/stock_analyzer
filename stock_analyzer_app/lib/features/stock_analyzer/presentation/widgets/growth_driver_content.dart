import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';

class GrowthDriverContent extends StatelessWidget {
  final String ticker;
  const GrowthDriverContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return NotionBulletSummary(
      title: '${ticker.toUpperCase()} Growth Driver',
      subtitle: 'Report view checklist for future growth assumptions.',
      bullets: const [
        NotionSummaryBullet(
          label: 'Revenue growth',
          value:
              'Identify the products, segments, geographies, pricing power, or market expansion expected to grow revenue.',
          icon: Icons.trending_up,
          tone: AppSummaryTone.success,
        ),
        NotionSummaryBullet(
          label: 'Operating leverage',
          value:
              'Check whether growth can convert into higher margins, earnings, and free cash flow.',
          icon: Icons.speed,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Evidence to verify',
          value:
              'Confirm the growth story with recent revenue trends, management commentary, and competitor comparison.',
          icon: Icons.fact_check_outlined,
          tone: AppSummaryTone.warning,
        ),
      ],
    );
  }
}
