import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';

class SaleTargetContent extends StatelessWidget {
  final String ticker;
  const SaleTargetContent({super.key, required this.ticker});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profLinks = buildCompoundInterestLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text('View Sale Target:'),
        const SizedBox(height: 16),
        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This gives overview of the sale target for the stock. We calculate the sale target based on the current stock price, the expected growth rate, and the expected dividend yield. Then we compare the sale target with the current stock price to determine if the stock is overvalued or undervalued. And also compare this is compound interest calculation based on investment period and expected return rate.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Sale Target Calculated:'),

        //TODO
        const SizedBox(height: 16),
        const Text('Exist Strategy:'),
        const SizedBox(height: 16),
        // ---- profitability references ----
        const Text(
          'Compound Interest References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profLinks.entries.map((e) {
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
