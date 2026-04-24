import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:url_launcher/url_launcher.dart';

class CompetitorStudyContent extends StatefulWidget {
  final String ticker;
  const CompetitorStudyContent({super.key, required this.ticker});

  @override
  State<CompetitorStudyContent> createState() => _CompetitorStudyContentState();
}

class _CompetitorStudyContentState extends State<CompetitorStudyContent> {
  late final List<_CompetitorParameter> _parameters = [
    _CompetitorParameter(
      title: 'Market Capitalization',
      isChecked: true,
      controller: TextEditingController(text: '1st Rank'),
    ),
    _CompetitorParameter(
      title: 'Total Revenue',
      isChecked: true,
      controller: TextEditingController(
        text: 'Not that good compared to competitor',
      ),
    ),
    _CompetitorParameter(
      title: 'Net Income',
      isChecked: true,
      controller: TextEditingController(text: 'Recovering after 2022'),
    ),
    _CompetitorParameter(
      title: 'Return On Equity',
      isChecked: true,
      controller: TextEditingController(
        text: 'Not that good compared to competitor',
      ),
    ),
    _CompetitorParameter(
      title: 'ROIC',
      isChecked: true,
      controller: TextEditingController(
        text: 'Not that good compared to competitor',
      ),
    ),
    _CompetitorParameter(
      title: 'Gross Profit Margin',
      isChecked: true,
      controller: TextEditingController(text: 'Average'),
    ),
    _CompetitorParameter(
      title: 'Net Profit Margin',
      controller: TextEditingController(),
    ),
    _CompetitorParameter(
      title: '10 Yrs chart comparison',
      controller: TextEditingController(),
    ),
    _CompetitorParameter(
      title: '5 Yrs chart comparison',
      controller: TextEditingController(),
    ),
  ];

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  void dispose() {
    for (final parameter in _parameters) {
      parameter.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competitorLinks = buildCompetitorStudyLinks(widget.ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parameter to Compare',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _parameters.asMap().entries.map((entry) {
              final index = entry.key;
              final parameter = entry.value;
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: parameter.isChecked,
                      onChanged: (value) {
                        setState(() {
                          _parameters[index] = parameter.copyWith(
                            isChecked: value ?? false,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(parameter.title),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: parameter.controller,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'Add comparison note',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Note: Compare the performance with its industry competitor.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Peer Comparison Chart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: competitorLinks.entries.take(2).map((entry) {
            return ActionChip(
              label: Text(entry.key),
              onPressed: () => _launch(entry.value),
              backgroundColor: Colors.blueGrey.shade50,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'S&P 500 Comparison Chart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: competitorLinks.entries.skip(2).map((entry) {
            return ActionChip(
              label: Text(entry.key),
              onPressed: () => _launch(entry.value),
              backgroundColor: Colors.green.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CompetitorParameter {
  const _CompetitorParameter({
    required this.title,
    required this.controller,
    this.isChecked = false,
  });

  final String title;
  final TextEditingController controller;
  final bool isChecked;

  _CompetitorParameter copyWith({bool? isChecked}) {
    return _CompetitorParameter(
      title: title,
      controller: controller,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
