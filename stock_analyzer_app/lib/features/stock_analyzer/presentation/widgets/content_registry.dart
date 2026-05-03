import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
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
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';
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
  'Resources': (ticker) => _TickerResourcesHub(ticker: ticker),
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

class _TickerResourcesHub extends StatelessWidget {
  const _TickerResourcesHub({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    final upper = ticker.toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotionBulletSummary(
          title: '$upper Resources',
          subtitle: 'Ticker-specific source hub for validating the checklist.',
          bullets: const [
            NotionSummaryBullet(
              label: 'Primary sources',
              value:
                  'Start with SEC filings, earnings releases, and investor relations pages before relying on third-party summaries.',
              icon: Icons.source_outlined,
              tone: AppSummaryTone.info,
            ),
            NotionSummaryBullet(
              label: 'Cross-checks',
              value:
                  'Compare analyst forecasts, financial tables, charts, and snapshot sites before finalizing the thesis.',
              icon: Icons.fact_check_outlined,
              tone: AppSummaryTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Company Profile and Filings:',
          links: {
            'Stock Analysis Overview': buildBusinessOverviewLinks(
              ticker,
            )['Stock Analysis Overview']!,
            ...buildCompanyFilingLinks(ticker),
          },
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Financials and Revenue:',
          links: {
            ...buildFinancialLinks(ticker),
            ...buildRevenueLinks(ticker),
            ...buildDebtLinks(ticker),
          },
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Earnings and Analyst Forecast:',
          links: {
            'Earnings Whispers EPS': buildBusinessOverviewLinks(
              ticker,
            )['Earnings Whispers EPS']!,
            ...buildAnalystForecastLinks(ticker),
          },
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Charts and Market Snapshot:',
          links: buildChartAndSnapshotLinks(ticker),
          color: Colors.blue,
        ),
      ],
    );
  }
}
