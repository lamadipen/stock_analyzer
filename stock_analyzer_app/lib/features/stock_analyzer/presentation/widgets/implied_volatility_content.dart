import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class ImpliedVolatilityContent extends StatelessWidget {
  final String ticker;
  const ImpliedVolatilityContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final impliedVolatilityLinks = buildImplivedVolatilityLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotionBulletSummary(
          title: '${ticker.toUpperCase()} Implied Volatility',
          subtitle: 'Report view for option-market volatility signal.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Definition',
              value:
                  'Implied volatility estimates expected future price movement from option prices.',
              icon: Icons.show_chart,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Read',
              value:
                  'Higher IV signals greater expected movement; lower IV signals calmer expectations.',
              icon: Icons.speed,
              tone: AppSummaryTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Implied Volatility References:',
          links: impliedVolatilityLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
