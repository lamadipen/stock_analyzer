import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class InvestmentRisksContent extends StatefulWidget {
  final String ticker;
  const InvestmentRisksContent({super.key, required this.ticker});

  @override
  State<InvestmentRisksContent> createState() => _InvestmentRisksContentState();
}

class _InvestmentRisksContentState extends State<InvestmentRisksContent> {
  final TextEditingController _businessRiskController = TextEditingController();
  final TextEditingController _financialRiskController =
      TextEditingController();
  final TextEditingController _valuationRiskController =
      TextEditingController();
  final TextEditingController _mitigationController = TextEditingController();
  final TextEditingController _sourceNotesController = TextEditingController();
  Timer? _saveDebounce;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  bool _showReportMode = true;
  bool _isRestoring = false;
  DateTime? _lastSavedAt;
  late List<_RiskChecklistItem> _items = _defaultItems();

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_scheduleSave);
    }
    _loadSavedData();
  }

  List<TextEditingController> get _controllers => [
    _businessRiskController,
    _financialRiskController,
    _valuationRiskController,
    _mitigationController,
    _sourceNotesController,
  ];

  List<_RiskChecklistItem> _defaultItems() {
    return const [
      _RiskChecklistItem(
        title: 'Business risk reviewed',
        subtitle:
            'Customer concentration, product disruption, cyclicality, execution, or demand weakness.',
      ),
      _RiskChecklistItem(
        title: 'Financial risk reviewed',
        subtitle:
            'Debt, margin pressure, weak cash flow, dilution, or earnings-quality issues.',
      ),
      _RiskChecklistItem(
        title: 'Valuation risk reviewed',
        subtitle:
            'Current expectations are compared against growth durability and margin of safety.',
      ),
      _RiskChecklistItem(
        title: 'Downside trigger identified',
        subtitle:
            'A concrete event or metric would invalidate the thesis or force a reassessment.',
      ),
      _RiskChecklistItem(
        title: 'Risk is reflected in final action',
        subtitle:
            'Decision Summary risk level and final action match the evidence here.',
      ),
    ];
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.investmentRisksSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isRestoring = true;
    _businessRiskController.text = '${data['businessRisk'] ?? ''}';
    _financialRiskController.text = '${data['financialRisk'] ?? ''}';
    _valuationRiskController.text = '${data['valuationRisk'] ?? ''}';
    _mitigationController.text = '${data['mitigation'] ?? ''}';
    _sourceNotesController.text = '${data['sourceNotes'] ?? ''}';
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
    _isRestoring = false;

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
    _saveDebounce?.cancel();
    setState(() => _isSaving = true);
    final savedAt = DateTime.now();

    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.investmentRisksSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'businessRisk': _businessRiskController.text.trim(),
        'financialRisk': _financialRiskController.text.trim(),
        'valuationRisk': _valuationRiskController.text.trim(),
        'mitigation': _mitigationController.text.trim(),
        'sourceNotes': _sourceNotesController.text.trim(),
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
    _saveDebounce?.cancel();
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.investmentRisksSection,
    );

    if (!mounted) {
      return;
    }

    _isRestoring = true;
    setState(() {
      for (final controller in _controllers) {
        controller.clear();
      }
      _items = _defaultItems();
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
    _isRestoring = false;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final links = {
      ...buildBusinessOverviewLinks(widget.ticker),
      ...buildDebtLinks(widget.ticker),
      ...buildValuationMethodLinks(widget.ticker),
      ...buildCompanyFilingLinks(widget.ticker),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Investment Risks for ${widget.ticker.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
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
        SectionReportModeToggle(
          showReportMode: _showReportMode,
          onChanged: (value) => setState(() => _showReportMode = value),
        ),
        const SizedBox(height: 12),
        if (_showReportMode) ...[
          _riskReport(),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Risk Review Sources:', links: links),
        ] else ...[
          const AppNote(
            title: 'Risk template',
            icon: Icons.warning_amber,
            tone: AppNoteTone.warning,
            child: Text(
              'Name the risks that could break the thesis, then connect each one to evidence and a decision rule.',
            ),
          ),
          const SizedBox(height: 16),
          ChecklistCard(
            items: _items.map((item) {
              return ChecklistCardItem(
                title: item.title,
                subtitle: item.subtitle,
                isChecked: item.isChecked,
              );
            }).toList(),
            onChanged: (index, isChecked) {
              setState(() {
                _items[index] = _items[index].copyWith(isChecked: isChecked);
              });
              _scheduleSave();
            },
          ),
          const SizedBox(height: 16),
          EditableTable(
            rows: [
              EditableTableRow(
                label: 'Business risk',
                value: _textField(
                  controller: _businessRiskController,
                  hintText:
                      'Customer concentration, disruption, weak demand, execution problems, or cyclicality.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Financial risk',
                value: _textField(
                  controller: _financialRiskController,
                  hintText:
                      'Debt load, falling margins, cash-flow weakness, dilution, or earnings quality.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Valuation risk',
                value: _textField(
                  controller: _valuationRiskController,
                  hintText:
                      'Expectations embedded in price, limited margin of safety, or multiple compression risk.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Mitigation / trigger',
                value: _textField(
                  controller: _mitigationController,
                  hintText:
                      'What evidence would reduce the risk, or what event would force Avoid / Sell / Wait?',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Source notes',
                value: _textField(
                  controller: _sourceNotesController,
                  hintText:
                      'Paste risk factors, balance-sheet notes, valuation snippets, or management warnings.',
                  minLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Risk Review Sources:', links: links),
        ],
      ],
    );
  }

  Widget _riskReport() {
    return NotionBulletSummary(
      title: '${widget.ticker.toUpperCase()} Investment Risks',
      subtitle: '$_checkedCount/${_items.length} risk checks marked.',
      bullets: [
        NotionSummaryBullet(
          label: 'Business risk',
          value: _businessRiskController.text.trim(),
          icon: Icons.business_center_outlined,
          tone: AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Financial risk',
          value: _financialRiskController.text.trim(),
          icon: Icons.account_balance_wallet_outlined,
          tone: AppSummaryTone.risk,
        ),
        NotionSummaryBullet(
          label: 'Valuation risk',
          value: _valuationRiskController.text.trim(),
          icon: Icons.price_check,
          tone: AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Mitigation / trigger',
          value: _mitigationController.text.trim(),
          icon: Icons.rule,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Checked prompts',
          value: _checkedSignals,
          icon: Icons.checklist,
          tone: _checkedCount >= 3
              ? AppSummaryTone.success
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Source notes',
          value: _sourceNotesController.text.trim(),
          icon: Icons.source_outlined,
          tone: AppSummaryTone.neutral,
        ),
      ],
    );
  }

  int get _checkedCount => _items.where((item) => item.isChecked).length;

  String get _checkedSignals {
    final checked = _items
        .where((item) => item.isChecked)
        .map((item) => item.title)
        .toList();
    return checked.join(', ');
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _RiskChecklistItem {
  const _RiskChecklistItem({
    required this.title,
    required this.subtitle,
    this.isChecked = false,
  });

  final String title;
  final String subtitle;
  final bool isChecked;

  _RiskChecklistItem copyWith({bool? isChecked}) {
    return _RiskChecklistItem(
      title: title,
      subtitle: subtitle,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
