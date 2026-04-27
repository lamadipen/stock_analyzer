import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class InstitutionalOwnershipContent extends StatelessWidget {
  final String ticker;
  const InstitutionalOwnershipContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final institutionalActivityLinks = buildInstitutionalOwnershipLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        Text('View Institutional Ownership Activity : $ticker'),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'This gives overview of how big investor are trading the stock. If they are selling the stock, it could be a sign of a sell off. If they are buying the stock, it could be a sign of a buy off.',
          ),
        ),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Institutional Ownership References:',
          links: institutionalActivityLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}
