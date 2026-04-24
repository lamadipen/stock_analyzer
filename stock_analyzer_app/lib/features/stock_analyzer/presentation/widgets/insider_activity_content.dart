import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';

class InsiderActivityContent extends StatelessWidget {
  final String ticker;
  const InsiderActivityContent({super.key, required this.ticker});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final insiderActivityLinks = buildInsiderActivityLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        Text('View Insider Trading Activity : $ticker'),
        const SizedBox(height: 16),
        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This gives overview of how big investor are trading the stock. If they are selling the stock, it could be a sign of a sell off. If they are buying the stock, it could be a sign of a buy off.',
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
          children: insiderActivityLinks.entries.map((e) {
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
