import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class GrowthDriverContent extends StatefulWidget {
  final String ticker;
  const GrowthDriverContent({super.key, required this.ticker});

  @override
  State<GrowthDriverContent> createState() => _GrowthDriverContentState();
}

class _GrowthDriverContentState extends State<GrowthDriverContent> {
  final TextEditingController _growthThesisController = TextEditingController();
  final TextEditingController _demandDriversController =
      TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  final TextEditingController _watchoutsController = TextEditingController();
  final TextEditingController _sourceNotesController = TextEditingController();
  Timer? _saveDebounce;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  bool _showReportMode = true;
  bool _isRestoring = false;
  DateTime? _lastSavedAt;
  late List<_TemplateChecklistItem> _items = _defaultItems();

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_scheduleSave);
    }
    _loadSavedData();
  }

  List<TextEditingController> get _controllers => [
    _growthThesisController,
    _demandDriversController,
    _evidenceController,
    _watchoutsController,
    _sourceNotesController,
  ];

  List<_TemplateChecklistItem> _defaultItems() {
    return const [
      _TemplateChecklistItem(
        title: 'Growth driver is specific',
        subtitle:
            'Names the product, segment, customer group, geography, pricing lever, or market expansion.',
      ),
      _TemplateChecklistItem(
        title: 'Revenue impact is visible',
        subtitle:
            'Recent results, segment tables, or management commentary connect the driver to revenue.',
      ),
      _TemplateChecklistItem(
        title: 'Demand appears durable',
        subtitle:
            'The driver is tied to recurring need, secular demand, switching costs, or multi-year adoption.',
      ),
      _TemplateChecklistItem(
        title: 'Margins can improve',
        subtitle:
            'Growth can reasonably convert into operating leverage, earnings, or free cash flow.',
      ),
      _TemplateChecklistItem(
        title: 'Competitors do not erase the thesis',
        subtitle:
            'Peer comparison does not show the same driver is stronger elsewhere.',
      ),
    ];
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.growthDriverSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isRestoring = true;
    _growthThesisController.text = '${data['growthThesis'] ?? ''}';
    _demandDriversController.text = '${data['demandDrivers'] ?? ''}';
    _evidenceController.text = '${data['evidence'] ?? ''}';
    _watchoutsController.text = '${data['watchouts'] ?? ''}';
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
      section: StockAnalysisStorage.growthDriverSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'growthThesis': _growthThesisController.text.trim(),
        'demandDrivers': _demandDriversController.text.trim(),
        'evidence': _evidenceController.text.trim(),
        'watchouts': _watchoutsController.text.trim(),
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
      section: StockAnalysisStorage.growthDriverSection,
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
      ...buildRevenueLinks(widget.ticker),
      ...buildCompetitorStudyLinks(widget.ticker),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Growth Driver for ${widget.ticker.toUpperCase()}',
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
          _growthReport(),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Growth Driver Sources:', links: links),
        ] else ...[
          const AppNote(
            title: 'Growth template',
            icon: Icons.rocket_launch_outlined,
            child: Text(
              'Describe what can make revenue and earnings larger, then back it with source evidence and explicit watchouts.',
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
                label: 'Growth thesis',
                value: _textField(
                  controller: _growthThesisController,
                  hintText:
                      'What is the main thing that can make this business bigger?',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Demand drivers',
                value: _textField(
                  controller: _demandDriversController,
                  hintText:
                      'Products, use cases, customer groups, geographies, pricing, or market expansion.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Evidence',
                value: _textField(
                  controller: _evidenceController,
                  hintText:
                      'Recent revenue trends, segment growth, backlog, management commentary, or market data.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Watchouts',
                value: _textField(
                  controller: _watchoutsController,
                  hintText:
                      'What would prove the growth story is weaker than expected?',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Source notes',
                value: _textField(
                  controller: _sourceNotesController,
                  hintText:
                      'Paste source snippets or links used to validate the growth driver.',
                  minLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Growth Driver Sources:', links: links),
        ],
      ],
    );
  }

  Widget _growthReport() {
    return NotionBulletSummary(
      title: '${widget.ticker.toUpperCase()} Growth Driver',
      subtitle: '$_checkedCount/${_items.length} growth checks marked.',
      bullets: [
        NotionSummaryBullet(
          label: 'Growth thesis',
          value: _growthThesisController.text.trim(),
          icon: Icons.rocket_launch_outlined,
          tone: AppSummaryTone.success,
        ),
        NotionSummaryBullet(
          label: 'Demand drivers',
          value: _demandDriversController.text.trim(),
          icon: Icons.trending_up,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Evidence',
          value: _evidenceController.text.trim(),
          icon: Icons.fact_check_outlined,
          tone: AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Watchouts',
          value: _watchoutsController.text.trim(),
          icon: Icons.warning_amber,
          tone: AppSummaryTone.risk,
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

class _TemplateChecklistItem {
  const _TemplateChecklistItem({
    required this.title,
    required this.subtitle,
    this.isChecked = false,
  });

  final String title;
  final String subtitle;
  final bool isChecked;

  _TemplateChecklistItem copyWith({bool? isChecked}) {
    return _TemplateChecklistItem(
      title: title,
      subtitle: subtitle,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
