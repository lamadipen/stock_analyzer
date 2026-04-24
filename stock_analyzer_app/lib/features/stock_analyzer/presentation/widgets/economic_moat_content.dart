import 'package:flutter/material.dart';

class EconomicMoatContent extends StatefulWidget {
  final String ticker;
  const EconomicMoatContent({super.key, required this.ticker});

  @override
  State<EconomicMoatContent> createState() => _EconomicMoatContentState();
}

class _EconomicMoatContentState extends State<EconomicMoatContent> {
  final List<_MoatChecklistItem> _items = [
    _MoatChecklistItem(
      title: 'Sustainable Competitive Advantage',
      isChecked: true,
    ),
    _MoatChecklistItem(
      title: 'Is it a Brand Monopoly? e.g. McDonald\'s, Google',
      isChecked: true,
      isChild: true,
    ),
    _MoatChecklistItem(
      title: 'High Barriers to Entry? Boeing, Google',
      isChild: true,
    ),
    _MoatChecklistItem(
      title: 'Huge Economies of Scale? Amazon, Walmart',
      isChecked: true,
      isChild: true,
    ),
    _MoatChecklistItem(
      title: 'Network Effect? Facebook, Google, eBay',
      isChild: true,
    ),
    _MoatChecklistItem(
      title: 'High Switching Costs? Microsoft, Adobe',
      isChild: true,
    ),
    _MoatChecklistItem(
      title:
          'A long term uptrend (10-20 Year chart) is a good visual indication for sustainable competitive advantage',
      isChild: true,
    ),
    _MoatChecklistItem(
      title:
          'See the comparison of charts with its competitor in any charting software',
      isChild: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Economic Moat Checklist for ${widget.ticker}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return CheckboxListTile(
                value: item.isChecked,
                onChanged: (value) {
                  setState(() {
                    _items[index] = item.copyWith(isChecked: value ?? false);
                  });
                },
                title: Text(item.title),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: EdgeInsets.only(
                  left: item.isChild ? 32 : 8,
                  right: 12,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const _MoatNote(
          text:
              'Based on peer comparison, select if the company has some kind of moat.',
        ),
        const SizedBox(height: 12),
        const _MoatNote(
          text:
              'Technological innovations, patents, and pharmaceutical patents are often not sustainable.',
        ),
      ],
    );
  }
}

class _MoatChecklistItem {
  const _MoatChecklistItem({
    required this.title,
    this.isChecked = false,
    this.isChild = false,
  });

  final String title;
  final bool isChecked;
  final bool isChild;

  _MoatChecklistItem copyWith({bool? isChecked}) {
    return _MoatChecklistItem(
      title: title,
      isChecked: isChecked ?? this.isChecked,
      isChild: isChild,
    );
  }
}

class _MoatNote extends StatelessWidget {
  const _MoatNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
