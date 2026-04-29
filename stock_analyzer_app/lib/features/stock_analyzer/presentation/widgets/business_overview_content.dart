import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class BusinessOverviewContent extends StatelessWidget {
  final String ticker;
  const BusinessOverviewContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final links = buildBusinessOverviewLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppNote(
          title: 'Business snapshot',
          icon: Icons.lightbulb_outline,
          child: Text(
            'Understand what ${ticker.toUpperCase()} does, how revenue is generated, and whether earnings expectations support the business story.',
          ),
        ),
        const SizedBox(height: 16),
        const ChecklistCard(
          items: [
            ChecklistCardItem(
              title: 'What does the company sell?',
              subtitle:
                  'Identify the core products, services, subscriptions, platforms, or marketplaces.',
            ),
            ChecklistCardItem(
              title: 'How does the company generate revenue?',
              subtitle:
                  'Separate recurring revenue, transaction revenue, services, licensing, ads, hardware, and other meaningful streams.',
            ),
            ChecklistCardItem(
              title: 'Which segment drives the majority of revenue?',
              subtitle:
                  'Use the company overview and latest financials to find the main business segment and any fast-growing segment.',
            ),
            ChecklistCardItem(
              title: 'Is demand structurally growing?',
              subtitle:
                  'Look for durable demand drivers such as digitization, cloud adoption, AI workflows, payments volume, or healthcare utilization.',
            ),
            ChecklistCardItem(
              title: 'Does the stock trend confirm investor confidence?',
              subtitle:
                  'Check the 1-year, 5-year, and max charts to see if price action supports the business narrative.',
            ),
            ChecklistCardItem(
              title: 'Do earnings expectations confirm momentum?',
              subtitle:
                  'Review the next earnings date, expected EPS, whisper/market expectation, and expected price reaction.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Business Quality Notes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const EditableTable(
          rows: [
            EditableTableRow(
              label: 'Business model',
              value: Text(
                'Write a one-sentence explanation of what the company does and who pays for it.',
              ),
            ),
            EditableTableRow(
              label: 'Revenue sources',
              value: Text(
                'List the largest revenue streams and call out whether revenue is recurring, usage-based, cyclical, or one-time.',
              ),
            ),
            EditableTableRow(
              label: 'Growth engine',
              value: Text(
                'Name the main products, segments, geographies, or acquisitions expected to drive future revenue.',
              ),
            ),
            EditableTableRow(
              label: 'Investor signal',
              value: Text(
                'Compare recent price trend, analyst rating, price target, and earnings expectation before forming a view.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppNote(
          tone: AppNoteTone.info,
          child: Text(
            'Example for Adobe: Digital Media and Digital Experience are the key operating segments. Creative Cloud, Document Cloud, and enterprise experience tools explain most of the business model, while EPS expectations and price reaction help validate near-term sentiment.',
          ),
        ),
        const SizedBox(height: 16),
        const AppNote(
          tone: AppNoteTone.warning,
          icon: Icons.fact_check_outlined,
          child: Text(
            'Do not rely only on product popularity. Confirm revenue growth, profitability, earnings consistency, and whether recent acquisitions improve the core business.',
          ),
        ),
        const SizedBox(height: 16),
        ReferenceLinks(title: 'Business Overview References:', links: links),
      ],
    );
  }
}
