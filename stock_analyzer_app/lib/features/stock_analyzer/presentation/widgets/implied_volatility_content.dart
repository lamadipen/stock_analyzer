import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
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
        // ---- criteria ----
        Text('View Implied Volatility : $ticker'),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'Implied Volatility is a measure of the price volatility of an option contract. It is used to gauge the expected price movement of the underlying asset in the future. A higher implied volatility indicates a more volatile asset, while a lower implied volatility indicates a less volatile asset.',
          ),
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
