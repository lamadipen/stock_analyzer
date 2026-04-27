import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MarginOfSafetyContent extends StatefulWidget {
  final String ticker;
  const MarginOfSafetyContent({super.key, required this.ticker});

  @override
  State<MarginOfSafetyContent> createState() => _MarginOfSafetyContentState();
}

class _MarginOfSafetyContentState extends State<MarginOfSafetyContent> {
  bool _isGreatEntry = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRestoring = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;
  Timer? _saveDebounce;

  final List<_BuyPointRow> _buyPoints = [];
  final List<_ReferenceLinkRow> _referenceLinks = [];

  @override
  void initState() {
    super.initState();
    _setDefaultRows();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.marginOfSafetySection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isRestoring = true;
    _disposeRows();
    _buyPoints
      ..clear()
      ..addAll(_buyPointsFromJson(data['buyPoints']));
    _referenceLinks
      ..clear()
      ..addAll(_referenceLinksFromJson(data['referenceLinks']));

    setState(() {
      _isGreatEntry = data['isGreatEntry'] == true;
      _hasSavedData = true;
      _isLoading = false;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
    });
    _isRestoring = false;
  }

  void _setDefaultRows() {
    _buyPoints
      ..clear()
      ..addAll([
        _createBuyPointRow(
          dateCreated: '03-04-2026',
          buyPoint: 'Buy point 1',
          targetPrice: '200',
        ),
        _createBuyPointRow(
          dateCreated: '03-04-2026',
          buyPoint: 'Buy point 2',
          targetPrice: '150',
        ),
        _createBuyPointRow(
          dateCreated: '03-04-2026',
          buyPoint: 'Buy point 3',
          targetPrice: '100',
        ),
      ]);

    _referenceLinks
      ..clear()
      ..addAll(
        buildMarginOfSafetyLinks(widget.ticker).entries.map((entry) {
          return _createReferenceLinkRow(label: entry.key, url: entry.value);
        }),
      );
  }

  List<_BuyPointRow> _buyPointsFromJson(Object? value) {
    if (value is! List) {
      return [];
    }

    return value.whereType<Map<String, dynamic>>().map((item) {
      return _createBuyPointRow(
        dateCreated: '${item['dateCreated'] ?? ''}',
        buyPoint: '${item['buyPoint'] ?? ''}',
        targetPrice: '${item['targetPrice'] ?? ''}',
      );
    }).toList();
  }

  List<_ReferenceLinkRow> _referenceLinksFromJson(Object? value) {
    if (value is! List) {
      return [];
    }

    return value.whereType<Map<String, dynamic>>().map((item) {
      return _createReferenceLinkRow(
        label: '${item['label'] ?? ''}',
        url: '${item['url'] ?? ''}',
      );
    }).toList();
  }

  _BuyPointRow _createBuyPointRow({
    String dateCreated = '',
    String buyPoint = '',
    String targetPrice = '',
  }) {
    final row = _BuyPointRow(
      dateController: TextEditingController(text: dateCreated),
      buyPointController: TextEditingController(text: buyPoint),
      targetPriceController: TextEditingController(text: targetPrice),
    );
    row.dateController.addListener(_scheduleSave);
    row.buyPointController.addListener(_scheduleSave);
    row.targetPriceController.addListener(_scheduleSave);
    return row;
  }

  _ReferenceLinkRow _createReferenceLinkRow({
    String label = '',
    String url = '',
  }) {
    final row = _ReferenceLinkRow(
      labelController: TextEditingController(text: label),
      urlController: TextEditingController(text: url),
    );
    row.labelController.addListener(_scheduleSave);
    row.urlController.addListener(_scheduleSave);
    return row;
  }

  Map<String, dynamic> _toJson() {
    final savedAt = DateTime.now();
    return {
      'isGreatEntry': _isGreatEntry,
      'savedAt': savedAt.toIso8601String(),
      'buyPoints': _buyPoints.map((row) {
        return {
          'dateCreated': row.dateController.text,
          'buyPoint': row.buyPointController.text,
          'targetPrice': row.targetPriceController.text,
        };
      }).toList(),
      'referenceLinks': _referenceLinks.map((row) {
        return {
          'label': row.labelController.text,
          'url': row.urlController.text,
        };
      }).toList(),
    };
  }

  void _scheduleSave() {
    if (_isRestoring || _isLoading) {
      return;
    }

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveNow);
  }

  Future<void> _saveNow() async {
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = true);
    final data = _toJson();
    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.marginOfSafetySection,
      data: data,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt']}');
    });
  }

  Future<void> _resetSection() async {
    _saveDebounce?.cancel();
    _isRestoring = true;
    _disposeRows();
    _setDefaultRows();
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.marginOfSafetySection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isGreatEntry = true;
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
    _isRestoring = false;
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  void _addBuyPoint() {
    setState(() {
      _buyPoints.add(
        _createBuyPointRow(buyPoint: 'Buy point ${_buyPoints.length + 1}'),
      );
    });
    _scheduleSave();
  }

  void _deleteBuyPoint(int index) {
    final row = _buyPoints.removeAt(index);
    row.dispose();
    setState(() {});
    _scheduleSave();
  }

  void _addReferenceLink() {
    setState(() {
      _referenceLinks.add(_createReferenceLinkRow(label: 'Chart Link'));
    });
    _scheduleSave();
  }

  void _deleteReferenceLink(int index) {
    final row = _referenceLinks.removeAt(index);
    row.dispose();
    setState(() {});
    _scheduleSave();
  }

  void _disposeRows() {
    for (final row in _buyPoints) {
      row.dispose();
    }
    for (final row in _referenceLinks) {
      row.dispose();
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _disposeRows();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Is it a Great Point of Entry?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            _SaveStatusChip(
              isSaving: _isSaving,
              hasSavedData: _hasSavedData,
              lastSavedAt: _lastSavedAt,
            ),
            OutlinedButton.icon(
              onPressed: _resetSection,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ],
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
              _scheduleSave();
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
        const AppNote(
          tone: AppNoteTone.warning,
          child: Text(
            'Avoid buying at highs of uptrend, i.e. far from moving average.',
          ),
        ),
        const SizedBox(height: 12),
        const AppNote(
          child: Text(
            'Always buy/add shares on the dip or wave down near to moving average.',
          ),
        ),
        const SizedBox(height: 12),
        const AppNote(
          tone: AppNoteTone.info,
          child: Text(
            'Confirmed Uptrend: 50MA above 150MA and/or price above 200MA.',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Possible Buy Points as per chart',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            FilledButton.icon(
              onPressed: _addBuyPoint,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _BuyPointsEditor(buyPoints: _buyPoints, onDelete: _deleteBuyPoint),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'References',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            FilledButton.icon(
              onPressed: _addReferenceLink,
              icon: const Icon(Icons.add_link),
              label: const Text('Add Link'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ReferenceLinksEditor(
          referenceLinks: _referenceLinks,
          onOpen: _launch,
          onDelete: _deleteReferenceLink,
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

class _BuyPointsEditor extends StatelessWidget {
  const _BuyPointsEditor({required this.buyPoints, required this.onDelete});

  final List<_BuyPointRow> buyPoints;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: buyPoints.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BuyPointCard(row: row, onDelete: () => onDelete(index)),
              );
            }).toList(),
          );
        }

        return DecoratedBox(
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
              rows: buyPoints.asMap().entries.map((entry) {
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
                        onPressed: () => onDelete(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _BuyPointCard extends StatelessWidget {
  const _BuyPointCard({required this.row, required this.onDelete});

  final _BuyPointRow row;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Buy Point',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: row.dateController,
            decoration: const InputDecoration(
              labelText: 'Date Created',
              hintText: 'MM-DD-YYYY',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: row.buyPointController,
            decoration: const InputDecoration(
              labelText: 'Buy Point',
              hintText: 'Buy point',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: row.targetPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target Price',
              hintText: 'Target price',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceLinksEditor extends StatelessWidget {
  const _ReferenceLinksEditor({
    required this.referenceLinks,
    required this.onOpen,
    required this.onDelete,
  });

  final List<_ReferenceLinkRow> referenceLinks;
  final ValueChanged<String> onOpen;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: referenceLinks.asMap().entries.map((entry) {
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;
                  final fields = [
                    TextField(
                      controller: row.labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    TextField(
                      controller: row.urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ];

                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('Open'),
                        onPressed: () => onOpen(row.urlController.text),
                        backgroundColor: Colors.blueGrey.shade50,
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fields[0],
                        const SizedBox(height: 10),
                        fields[1],
                        const SizedBox(height: 10),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: fields[0]),
                      const SizedBox(width: 12),
                      Expanded(flex: 4, child: fields[1]),
                      const SizedBox(width: 8),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
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

class _SaveStatusChip extends StatelessWidget {
  const _SaveStatusChip({
    required this.isSaving,
    required this.hasSavedData,
    required this.lastSavedAt,
  });

  final bool isSaving;
  final bool hasSavedData;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final label = isSaving
        ? 'Saving...'
        : hasSavedData
        ? 'Saved ${_formatTime(lastSavedAt)}'
        : 'Not saved yet';

    return Chip(
      avatar: Icon(
        isSaving ? Icons.sync : Icons.check_circle_outline,
        size: 18,
      ),
      label: Text(label),
      backgroundColor: hasSavedData ? AnalysisColors.favorable.shade50 : null,
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
