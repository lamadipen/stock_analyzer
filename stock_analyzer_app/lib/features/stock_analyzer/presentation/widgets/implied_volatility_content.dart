import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';

class ImpliedVolatilityContent extends StatelessWidget {
  final String ticker;
  const ImpliedVolatilityContent({super.key, required this.ticker});
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final impliedVolatilityLinks = buildImplivedVolatilityLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        Text('View Implied Volatility : $ticker'),
        const SizedBox(height: 16),
        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Implied Volatility is a measure of the price volatility of an option contract. It is used to gauge the expected price movement of the underlying asset in the future. A higher implied volatility indicates a more volatile asset, while a lower implied volatility indicates a less volatile asset.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        // ---- profitability references ----
        const Text(
          'Insider Trading Activity References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: impliedVolatilityLinks.entries.map((e) {
            return ActionChip(
              label: Text(e.key),
              onPressed: () => _launch(e.value),
              backgroundColor: Colors.green.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }
}
