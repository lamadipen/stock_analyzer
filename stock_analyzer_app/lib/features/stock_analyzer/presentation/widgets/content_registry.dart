import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/ai_analysis_summary_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/business_overview_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/competitor_study_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/decision_summary_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/economic_moat_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/financial_highlights_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/growth_driver_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/implied_volatility_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/insider_activity_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/institutional_ownership_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/investment_risks_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/margin_of_safety_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/price_alerts_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/sale_target_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/sector_comparison_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/valuation_method_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/short_term_investment_guide_content.dart';

typedef ContentWidgetBuilder = Widget Function(String ticker);

final Map<String, ContentWidgetBuilder> contentRegistry = {
  'Decision Summary': (ticker) => DecisionSummaryContent(ticker: ticker),
  'AI Analysis Summary': (ticker) => AiAnalysisSummaryContent(ticker: ticker),
  'Business Overview': (ticker) => BusinessOverviewContent(ticker: ticker),
  'Financial Highlights': (ticker) =>
      FinancialHighlightsContent(ticker: ticker),
  'Competitor Study': (ticker) => CompetitorStudyContent(ticker: ticker),
  'Economic Moat': (ticker) => EconomicMoatContent(ticker: ticker),
  'Growth Driver': (ticker) => GrowthDriverContent(ticker: ticker),
  'Valuation Method': (ticker) => ValuationMethodContent(ticker: ticker),
  'Margin of Safety': (ticker) => MarginOfSafetyContent(ticker: ticker),
  'Price Alerts / Target Tracking': (ticker) =>
      PriceAlertsContent(ticker: ticker),
  'Investment Risks': (ticker) => InvestmentRisksContent(ticker: ticker),
  'Sale Target': (ticker) => SaleTargetContent(ticker: ticker),
  'Implied Volatility (IV)': (ticker) =>
      ImpliedVolatilityContent(ticker: ticker),
  'Institutional Ownership': (ticker) =>
      InstitutionalOwnershipContent(ticker: ticker),
  'Insider Activity': (ticker) => InsiderActivityContent(ticker: ticker),
  'Sector Comparison': (ticker) => SectorComparisonContent(ticker: ticker),
  'Short Term Investment': (ticker) =>
      ShortTermInvestmentGuideContent(ticker: ticker),
  'Resources': (ticker) => NotionBulletSummary(
    title: '${ticker.toUpperCase()} Resources',
    subtitle: 'Reference hub for validating the investment checklist.',
    bullets: const [
      NotionSummaryBullet(
        label: 'Primary sources',
        value:
            'Use company filings, earnings releases, and investor presentations when available.',
        icon: Icons.source_outlined,
        tone: AppSummaryTone.info,
      ),
      NotionSummaryBullet(
        label: 'Cross-checks',
        value:
            'Compare third-party financial sites against reported company numbers before finalizing the thesis.',
        icon: Icons.fact_check_outlined,
        tone: AppSummaryTone.warning,
      ),
    ],
  ),
  // Default/fallback widget
  'default': (ticker) => NotionBulletSummary(
    title: '${ticker.toUpperCase()} Section Report',
    subtitle: 'No dedicated section renderer is configured yet.',
    bullets: const [
      NotionSummaryBullet(
        label: 'Next step',
        value: 'Add a section-specific workspace or report renderer.',
        icon: Icons.info_outline,
        tone: AppSummaryTone.info,
      ),
    ],
  ),
};

Widget getContentWidget(String sectionTitle, String ticker) {
  final builder = contentRegistry[sectionTitle] ?? contentRegistry['default']!;
  return builder(ticker);
}
