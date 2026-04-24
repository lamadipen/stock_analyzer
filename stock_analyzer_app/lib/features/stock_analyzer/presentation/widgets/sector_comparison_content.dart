import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';

class SectorComparisonContent extends StatelessWidget {
  final String ticker;
  const SectorComparisonContent({super.key, required this.ticker});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profLinks = buildSectorComparisionLinks(ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text('View Sector Performance:'),
        const SizedBox(height: 16),
        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This gives overview of how each sector is performing in comparison to the stock.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        // ---- profitability references ----
        const Text(
          'Sector Performance References:',
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
