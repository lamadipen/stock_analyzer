import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';

class ShortTermInvestmentGuideContent extends StatelessWidget {
  final String ticker;
  const ShortTermInvestmentGuideContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return NotionBulletSummary(
      title: '${ticker.toUpperCase()} Short Term Investment Guide',
      subtitle: 'Report view for short-term trade framing.',
      bullets: const [
        NotionSummaryBullet(
          label: 'Growth setup',
          value: 'High growth rate can support a short-term opportunity.',
          icon: Icons.trending_up,
          tone: AppSummaryTone.success,
        ),
        NotionSummaryBullet(
          label: 'Risk setup',
          value:
              'High debt increases risk and should limit position size or holding period.',
          icon: Icons.warning_amber,
          tone: AppSummaryTone.risk,
        ),
        NotionSummaryBullet(
          label: 'Time frame',
          value:
              'Buy and sell within 6 months when using this short-term framework.',
          icon: Icons.timeline,
          tone: AppSummaryTone.info,
        ),
      ],
    );
  }
}
