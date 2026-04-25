import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class ValuationMethodContent extends StatefulWidget {
  final String ticker;
  const ValuationMethodContent({super.key, required this.ticker});

  @override
  State<ValuationMethodContent> createState() => _ValuationMethodContentState();
}

class _ValuationMethodContentState extends State<ValuationMethodContent> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;

  final List<_ValuationChecklistItem> _items = const [
    _ValuationChecklistItem('1. Historic PE Comparison'),
    _ValuationChecklistItem(
      '2. Primary Method -> Discounted Cash Flow (DCF) method',
    ),
    _ValuationChecklistItem(
      '3. Cash from Operations 1.5X more than net income -> Discounted Free Cash Flow (FCF) Method',
    ),
    _ValuationChecklistItem(
      '4. Net Income Increasing more consistently than Cash from operations (Financial Stocks) -> Discounted Net Income (DNI) Method',
    ),
    _ValuationChecklistItem('5. Banks -> Price to Book Ratio'),
    _ValuationChecklistItem(
      '6. REITs -> Dividend (DPU) Yield, Price to NAV Ratio',
    ),
    _ValuationChecklistItem(
      '7. Speculative Growth Stocks -> Price to Sales Growth Ratio, Comparing Price / Sales Ratio',
    ),
  ];

  late final List<bool> _checked = List<bool>.filled(_items.length, false);

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.valuationMethodSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    final checked = data['checked'];
    if (checked is List) {
      for (var i = 0; i < checked.length && i < _checked.length; i++) {
        _checked[i] = checked[i] == true;
      }
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
      section: StockAnalysisStorage.valuationMethodSection,
      data: {'savedAt': savedAt.toIso8601String(), 'checked': _checked},
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
      section: StockAnalysisStorage.valuationMethodSection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      for (var i = 0; i < _checked.length; i++) {
        _checked[i] = false;
      }
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final valuationLinks = buildValuationMethodLinks(widget.ticker);
    final historicPeLink = valuationLinks.entries.first;
    final referenceLinks = valuationLinks.entries.skip(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Is it a Great Price?',
                style: TextStyle(fontWeight: FontWeight.w600),
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
        const SizedBox(height: 8),
        const Text('Price is below or near to the intrinsic value.'),
        const SizedBox(height: 16),
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
                value: _checked[index],
                onChanged: (value) {
                  setState(() {
                    _checked[index] = value ?? false;
                  });
                  _saveNow();
                },
                title: Text(item.title),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: const EdgeInsets.only(left: 8, right: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historic PE Comparison',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: 26x, which is less than the historical average.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ActionChip(
                label: Text(historicPeLink.key),
                onPressed: () => _launch(historicPeLink.value),
                backgroundColor: Colors.blueGrey.shade50,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cf1d6245-d41c-4de2-842a-e81a7b268676/Screen_Shot_2022-03-02_at_10.28.23_AM.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey.shade100,
                      child: const Text(
                        'Historic PE screenshot could not be loaded.',
                      ),
                    );
                  },
                ),
              ),
            ],
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
            'Note: When the share price is below the intrinsic value, there is margin of safety.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Valuation References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: referenceLinks.map((entry) {
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

class _ValuationChecklistItem {
  const _ValuationChecklistItem(this.title);

  final String title;
}
