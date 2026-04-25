import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class CompetitorStudyContent extends StatefulWidget {
  final String ticker;
  const CompetitorStudyContent({super.key, required this.ticker});

  @override
  State<CompetitorStudyContent> createState() => _CompetitorStudyContentState();
}

class _CompetitorStudyContentState extends State<CompetitorStudyContent> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRestoring = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;
  Timer? _saveDebounce;

  late final List<_CompetitorParameter> _parameters = _defaultParameters();

  List<_CompetitorParameter> _defaultParameters() {
    return [
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
  }

  @override
  void initState() {
    super.initState();
    for (final parameter in _parameters) {
      parameter.controller.addListener(_scheduleSave);
    }
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.competitorStudySection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    final savedParameters = data['parameters'];
    if (savedParameters is List) {
      final savedByTitle = <String, Map<String, dynamic>>{};
      for (final parameter
          in savedParameters.whereType<Map<String, dynamic>>()) {
        savedByTitle['${parameter['title']}'] = parameter;
      }

      for (var i = 0; i < _parameters.length; i++) {
        final saved = savedByTitle[_parameters[i].title];
        if (saved != null) {
          _parameters[i] = _parameters[i].copyWith(
            isChecked: saved['isChecked'] == true,
          );
          _parameters[i].controller.text = '${saved['note'] ?? ''}';
        }
      }
    }

    setState(() {
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
    });
  }

  void _scheduleSave() {
    if (_isLoading || _isRestoring) {
      return;
    }

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveNow);
  }

  Future<void> _saveNow() async {
    setState(() => _isSaving = true);
    final savedAt = DateTime.now();
    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.competitorStudySection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'parameters': _parameters.map((parameter) {
          return {
            'title': parameter.title,
            'isChecked': parameter.isChecked,
            'note': parameter.controller.text,
          };
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
    _saveDebounce?.cancel();
    _isRestoring = true;
    final defaults = _defaultParameters();
    for (var i = 0; i < _parameters.length; i++) {
      _parameters[i] = _parameters[i].copyWith(
        isChecked: defaults[i].isChecked,
      );
      _parameters[i].controller.text = defaults[i].controller.text;
      defaults[i].controller.dispose();
    }

    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.competitorStudySection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
    _isRestoring = false;
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final parameter in _parameters) {
      parameter.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final competitorLinks = buildCompetitorStudyLinks(widget.ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Parameter to Compare',
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
                        _scheduleSave();
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
