import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:url_launcher/url_launcher.dart';

class MarginOfSafetyContent extends StatefulWidget {
  final String ticker;
  const MarginOfSafetyContent({super.key, required this.ticker});

  @override
  State<MarginOfSafetyContent> createState() => _MarginOfSafetyContentState();
}

class _MarginOfSafetyContentState extends State<MarginOfSafetyContent> {
  bool _isGreatEntry = true;

  late final List<_BuyPointRow> _buyPoints = [
    _BuyPointRow(
      dateController: TextEditingController(text: '03-04-2026'),
      buyPointController: TextEditingController(text: 'Buy point 1'),
      targetPriceController: TextEditingController(text: '200'),
    ),
    _BuyPointRow(
      dateController: TextEditingController(text: '03-04-2026'),
      buyPointController: TextEditingController(text: 'Buy point 2'),
      targetPriceController: TextEditingController(text: '150'),
    ),
    _BuyPointRow(
      dateController: TextEditingController(text: '03-04-2026'),
      buyPointController: TextEditingController(text: 'Buy point 3'),
      targetPriceController: TextEditingController(text: '100'),
    ),
  ];

  late final List<_ReferenceLinkRow> _referenceLinks =
      buildMarginOfSafetyLinks(widget.ticker).entries.map((entry) {
        return _ReferenceLinkRow(
          labelController: TextEditingController(text: entry.key),
          urlController: TextEditingController(text: entry.value),
        );
      }).toList();

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  void _addBuyPoint() {
    setState(() {
      _buyPoints.add(
        _BuyPointRow(
          dateController: TextEditingController(),
          buyPointController: TextEditingController(
            text: 'Buy point ${_buyPoints.length + 1}',
          ),
          targetPriceController: TextEditingController(),
        ),
      );
    });
  }

  void _deleteBuyPoint(int index) {
    final row = _buyPoints.removeAt(index);
    row.dispose();
    setState(() {});
  }

  void _addReferenceLink() {
    setState(() {
      _referenceLinks.add(
        _ReferenceLinkRow(
          labelController: TextEditingController(text: 'Chart Link'),
          urlController: TextEditingController(),
        ),
      );
    });
  }

  void _deleteReferenceLink(int index) {
    final row = _referenceLinks.removeAt(index);
    row.dispose();
    setState(() {});
  }

  @override
  void dispose() {
    for (final row in _buyPoints) {
      row.dispose();
    }
    for (final row in _referenceLinks) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Is it a Great Point of Entry?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CheckboxListTile(
            value: _isGreatEntry,
            onChanged: (value) {
              setState(() => _isGreatEntry = value ?? false);
            },
            title: const Text(
              'Price is at Dip of an Uptrend, at the Support Level of a Consolidation or Reversing into a new uptrend',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: const EdgeInsets.only(left: 8, right: 12),
          ),
        ),
        const SizedBox(height: 16),
        const _MarginNote(
          text:
              'Avoid buying at highs of uptrend, i.e. far from moving average.',
        ),
        const SizedBox(height: 12),
        const _MarginNote(
          text:
              'Always buy/add shares on the dip or wave down near to moving average.',
        ),
        const SizedBox(height: 12),
        const _MarginNote(
          text: 'Confirmed Uptrend: 50MA above 150MA and/or price above 200MA.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Possible Buy Points as per chart',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: _addBuyPoint,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(Colors.green.shade50),
              columns: const [
                DataColumn(label: Text('Date Created')),
                DataColumn(label: Text('Buy Points')),
                DataColumn(label: Text('Target Price')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _buyPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      _TableTextField(
                        controller: row.dateController,
                        hintText: 'MM-DD-YYYY',
                        width: 140,
                      ),
                    ),
                    DataCell(
                      _TableTextField(
                        controller: row.buyPointController,
                        hintText: 'Buy point',
                        width: 180,
                      ),
                    ),
                    DataCell(
                      _TableTextField(
                        controller: row.targetPriceController,
                        hintText: 'Target price',
                        width: 120,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteBuyPoint(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'References',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: _addReferenceLink,
              icon: const Icon(Icons.add_link),
              label: const Text('Add Link'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: _referenceLinks.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.labelController,
                          decoration: const InputDecoration(
                            labelText: 'Label',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: row.urlController,
                          decoration: const InputDecoration(
                            labelText: 'URL',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Open'),
                        onPressed: () => _launch(row.urlController.text),
                        backgroundColor: Colors.blueGrey.shade50,
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteReferenceLink(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BuyPointRow {
  _BuyPointRow({
    required this.dateController,
    required this.buyPointController,
    required this.targetPriceController,
  });

  final TextEditingController dateController;
  final TextEditingController buyPointController;
  final TextEditingController targetPriceController;

  void dispose() {
    dateController.dispose();
    buyPointController.dispose();
    targetPriceController.dispose();
  }
}

class _ReferenceLinkRow {
  _ReferenceLinkRow({
    required this.labelController,
    required this.urlController,
  });

  final TextEditingController labelController;
  final TextEditingController urlController;

  void dispose() {
    labelController.dispose();
    urlController.dispose();
  }
}

class _TableTextField extends StatelessWidget {
  const _TableTextField({
    required this.controller,
    required this.hintText,
    required this.width,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final double width;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          hintText: hintText,
        ),
      ),
    );
  }
}

class _MarginNote extends StatelessWidget {
  const _MarginNote({required this.text});

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
