import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';

class InvestmentRisksContent extends StatelessWidget {
  final String ticker;
  const InvestmentRisksContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return NotionBulletSummary(
      title: '${ticker.toUpperCase()} Investment Risks',
      subtitle: 'Report view checklist for risks that can weaken the thesis.',
      bullets: const [
        NotionSummaryBullet(
          label: 'Business risk',
          value:
              'Look for customer concentration, product disruption, cyclicality, execution issues, or weakening demand.',
          icon: Icons.business_center_outlined,
          tone: AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Financial risk',
          value:
              'Check debt, falling margins, weak cash flow, dilution, or inconsistent earnings quality.',
          icon: Icons.account_balance_wallet_outlined,
          tone: AppSummaryTone.risk,
        ),
        NotionSummaryBullet(
          label: 'Valuation risk',
          value:
              'Compare current expectations against growth durability and margin of safety.',
          icon: Icons.price_check,
          tone: AppSummaryTone.warning,
        ),
      ],
    );
  }
}
