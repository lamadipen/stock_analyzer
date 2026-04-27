import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class SectorComparisonContent extends StatelessWidget {
  final String ticker;
  const SectorComparisonContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final profLinks = buildSectorComparisionLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text('View Sector Performance:'),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'This gives overview of how each sector is performing in comparison to the stock.',
          ),
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Sector Performance References:',
          links: profLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
