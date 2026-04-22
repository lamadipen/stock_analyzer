import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/business_overview_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/competitor_study_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/economic_moat_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/financial_highlights_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/growth_driver_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/implied_volatility_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/insider_activity_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/institutional_ownership_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/investment_risks_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/margin_of_safety_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/sale_target_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/sector_comparison_content.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/valuation_method_content.dart';

typedef ContentWidgetBuilder = Widget Function(String ticker);

final Map<String, ContentWidgetBuilder> contentRegistry = {
  'Business Overview': (ticker) => BusinessOverviewContent(ticker: ticker),
  'Financial Highlights': (ticker) =>
      FinancialHighlightsContent(ticker: ticker),
  'Competitor Study': (ticker) => CompetitorStudyContent(ticker: ticker),
  'Economic Moat': (ticker) => EconomicMoatContent(ticker: ticker),
  'Growth Driver': (ticker) => GrowthDriverContent(ticker: ticker),
  'Valuation Method': (ticker) => ValuationMethodContent(ticker: ticker),
  'Margin of Safety': (ticker) => MarginOfSafetyContent(ticker: ticker),
  'Investment Risks': (ticker) => InvestmentRisksContent(ticker: ticker),
  'Sale Target': (ticker) => SaleTargetContent(ticker: ticker),
  'Implied Volatility (IV)': (ticker) =>
      ImpliedVolatilityContent(ticker: ticker),
  'Institutional Ownership': (ticker) =>
      InstitutionalOwnershipContent(ticker: ticker),
  'Insider Activity': (ticker) => InsiderActivityContent(ticker: ticker),
  'Sector Comparison': (ticker) => SectorComparisonContent(ticker: ticker),
  // Default/fallback widget
  'default': (ticker) =>
      Text('Details for the selected section will be displayed here.'),
};

Widget getContentWidget(String sectionTitle, String ticker) {
  final builder = contentRegistry[sectionTitle] ?? contentRegistry['default']!;
  return builder(ticker);
}
