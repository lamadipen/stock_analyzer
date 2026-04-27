import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class EconomicMoatContent extends StatefulWidget {
  final String ticker;
  const EconomicMoatContent({super.key, required this.ticker});

  @override
  State<EconomicMoatContent> createState() => _EconomicMoatContentState();
}

class _EconomicMoatContentState extends State<EconomicMoatContent> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;

  late List<_MoatChecklistItem> _items = _defaultItems();

  List<_MoatChecklistItem> _defaultItems() {
    return [
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
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.economicMoatSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    final savedItems = data['items'];
    if (savedItems is List) {
      final checkedByTitle = <String, bool>{};
      for (final item in savedItems.whereType<Map<String, dynamic>>()) {
        checkedByTitle['${item['title']}'] = item['isChecked'] == true;
      }

      _items = _items.map((item) {
        return item.copyWith(isChecked: checkedByTitle[item.title]);
      }).toList();
    }

    setState(() {
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
    });
  }

  Future<void> _saveNow() async {
    setState(() => _isSaving = true);
    final savedAt = DateTime.now();
    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.economicMoatSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'items': _items.map((item) {
          return {'title': item.title, 'isChecked': item.isChecked};
        }).toList(),
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _hasSavedData = true;
      _lastSavedAt = savedAt;
    });
  }

  Future<void> _resetSection() async {
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.economicMoatSection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _items = _defaultItems();
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Economic Moat Checklist for ${widget.ticker}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SectionSaveStatusChip(
              isSaving: _isSaving,
              hasSavedData: _hasSavedData,
              lastSavedAt: _lastSavedAt,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _resetSection,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ChecklistCard(
          items: _items.map((item) {
            return ChecklistCardItem(
              title: item.title,
              isChecked: item.isChecked,
              isChild: item.isChild,
            );
          }).toList(),
          onChanged: (index, isChecked) {
            setState(() {
              _items[index] = _items[index].copyWith(isChecked: isChecked);
            });
            _saveNow();
          },
        ),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'Based on peer comparison, select if the company has some kind of moat.',
          ),
        ),
        const SizedBox(height: 12),
        const AppNote(
          tone: AppNoteTone.warning,
          child: Text(
            'Technological innovations, patents, and pharmaceutical patents are often not sustainable.',
          ),
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
