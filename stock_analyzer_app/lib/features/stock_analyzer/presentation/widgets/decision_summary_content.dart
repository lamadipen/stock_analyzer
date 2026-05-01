import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/analysis_section_models.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class DecisionSummaryContent extends StatefulWidget {
  const DecisionSummaryContent({super.key, required this.ticker});

  final String ticker;

  @override
  State<DecisionSummaryContent> createState() => _DecisionSummaryContentState();
}

class _DecisionSummaryContentState extends State<DecisionSummaryContent> {
  static const List<String> _businessQualityOptions = ['Pass', 'Watch', 'Fail'];
  static const List<String> _valuationOptions = [
    'Attractive',
    'Fair',
    'Expensive',
  ];
  static const List<String> _entryPointOptions = ['Good', 'Wait'];
  static const List<String> _riskLevelOptions = ['Low', 'Medium', 'High'];
  static const List<String> _finalActionOptions = [
    'Watchlist',
    'Buy Zone',
    'Avoid',
  ];

  final TextEditingController _notesController = TextEditingController();
  Timer? _saveDebounce;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  bool _showReportMode = false;
  DateTime? _lastSavedAt;
  String? _businessOverviewMessage;
  BusinessOverview? _businessOverview;

  String _businessQuality = 'Watch';
  String _valuation = 'Fair';
  String _entryPoint = 'Wait';
  String _riskLevel = 'Medium';
  String _finalAction = 'Watchlist';

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_scheduleSave);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final decisionData = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.decisionSummarySection,
    );
    final businessOverviewData = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.businessOverviewSection,
    );

    if (!mounted) {
      return;
    }

    final businessOverview = businessOverviewData == null
        ? null
        : BusinessOverview.fromJson(businessOverviewData);

    if (decisionData == null) {
      if (businessOverview != null) {
        final note = _buildBusinessOverviewNote(businessOverview);
        _businessQuality = businessOverview.decisionBusinessQuality;
        _notesController.text = note;
      }

      setState(() {
        _businessOverview = businessOverview;
        _businessOverviewMessage = businessOverview == null
            ? null
            : 'Auto-loaded Business Overview: ${businessOverview.qualityLabel} mapped to ${businessOverview.decisionBusinessQuality}.';
        _isLoading = false;
      });
      return;
    }

    final summary = DecisionSummary.fromJson(decisionData);

    _businessQuality = _readOption(
      summary.businessQuality,
      _businessQualityOptions,
      _businessQuality,
    );
    _valuation = _readOption(summary.valuation, _valuationOptions, _valuation);
    _entryPoint = _readOption(
      summary.entryPoint,
      _entryPointOptions,
      _entryPoint,
    );
    _riskLevel = _readOption(summary.riskLevel, _riskLevelOptions, _riskLevel);
    _finalAction = _readOption(
      summary.finalAction,
      _finalActionOptions,
      _finalAction,
    );
    _notesController.text = summary.notes;

    setState(() {
      _businessOverview = businessOverview;
      _businessOverviewMessage = businessOverview == null
          ? null
          : 'Business Overview signal available: ${businessOverview.qualityLabel} maps to ${businessOverview.decisionBusinessQuality}.';
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = summary.savedAt;
    });
  }

  String _readOption(Object? value, List<String> options, String fallback) {
    final text = '$value';
    return options.contains(text) ? text : fallback;
  }

  void _scheduleSave() {
    if (_isLoading) {
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
      section: StockAnalysisStorage.decisionSummarySection,
      data: DecisionSummary(
        savedAt: savedAt,
        businessQuality: _businessQuality,
        valuation: _valuation,
        entryPoint: _entryPoint,
        riskLevel: _riskLevel,
        finalAction: _finalAction,
        notes: _notesController.text,
      ).toJson(),
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
      section: StockAnalysisStorage.decisionSummarySection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _businessQuality = 'Watch';
      _valuation = 'Fair';
      _entryPoint = 'Wait';
      _riskLevel = 'Medium';
      _finalAction = 'Watchlist';
      _notesController.clear();
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
      _businessOverviewMessage = null;
      _businessOverview = null;
    });
  }

  void _setValue(void Function() update) {
    setState(update);
    _scheduleSave();
  }

  Future<void> _applyBusinessOverview() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.businessOverviewSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() {
        _businessOverviewMessage =
            'No saved Business Overview found for ${widget.ticker.toUpperCase()}.';
      });
      return;
    }

    final businessOverview = BusinessOverview.fromJson(data);
    final qualityLabel = businessOverview.qualityLabel;
    final businessQuality = businessOverview.decisionBusinessQuality;
    final overviewNote = _buildBusinessOverviewNote(businessOverview);
    final currentNotes = _removeExistingBusinessOverviewBlock(
      _notesController.text,
    ).trim();

    setState(() {
      _businessQuality = businessQuality;
      _businessOverview = businessOverview;
      _notesController.text = [
        overviewNote,
        if (currentNotes.isNotEmpty) currentNotes,
      ].join('\n\n');
      _businessOverviewMessage =
          'Applied Business Overview: $qualityLabel mapped to $businessQuality.';
    });

    await _saveNow();
  }

  String _buildBusinessOverviewNote(BusinessOverview businessOverview) {
    final lines = <String>[
      '[Business Overview]',
      'Business quality: ${businessOverview.qualityLabel} (${businessOverview.qualityScore} score)',
      _noteLine('Business model', businessOverview.businessModel),
      _noteLine('Revenue sources', businessOverview.revenueSources),
      _noteLine('Main segment', businessOverview.mainSegment),
      _noteLine('Growth driver', businessOverview.growthDriver),
      _noteLine('Earnings signal', businessOverview.earningsSignal),
      _noteLine('Stock trend', businessOverview.stockTrend),
      '[/Business Overview]',
    ];

    return lines.where((line) => line.trim().isNotEmpty).join('\n');
  }

  String _noteLine(String label, Object? value) {
    final text = '${value ?? ''}'.trim();
    if (text.isEmpty) {
      return '';
    }
    return '$label: $text';
  }

  String _removeExistingBusinessOverviewBlock(String text) {
    return text
        .replaceAll(
          RegExp(r'\n*\[Business Overview\][\s\S]*?\[/Business Overview\]\n*'),
          '\n',
        )
        .trim();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _notesController.dispose();
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Final Investment Summary for ${widget.ticker.toUpperCase()}',
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
        AppNote(
          title: 'Decision Snapshot',
          icon: Icons.fact_check_outlined,
          tone: _noteTone,
          child: Text(
            'Final Action: $_finalAction. Business Quality is $_businessQuality, valuation is $_valuation, entry point is $_entryPoint, and risk is $_riskLevel.',
          ),
        ),
        const SizedBox(height: 12),
        _SectionModeToggle(
          showReportMode: _showReportMode,
          onChanged: (value) => setState(() => _showReportMode = value),
        ),
        const SizedBox(height: 12),
        if (_showReportMode) ...[
          _decisionSummaryReport(),
        ] else ...[
          if (_businessOverview != null) ...[
            AppNote(
              title: 'Connected Business Overview',
              icon: Icons.account_tree_outlined,
              tone: _businessOverview!.qualityLabel == 'Strong'
                  ? AppNoteTone.success
                  : _businessOverview!.qualityLabel == 'Weak'
                  ? AppNoteTone.risk
                  : AppNoteTone.warning,
              child: Text(
                '${_businessOverview!.qualityLabel} business overview maps to $_businessQuality for Decision Summary.',
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _applyBusinessOverview,
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Refresh Business Overview'),
              ),
            ],
          ),
          if (_businessOverviewMessage != null) ...[
            const SizedBox(height: 12),
            AppNote(
              title: 'Business Overview sync',
              icon: Icons.sync_alt,
              tone: _businessOverviewMessage!.startsWith('No saved')
                  ? AppNoteTone.warning
                  : AppNoteTone.success,
              child: Text(_businessOverviewMessage!),
            ),
          ],
          const SizedBox(height: 16),
          EditableTable(
            rows: [
              EditableTableRow(
                label: 'Business Quality',
                value: _optionField(
                  value: _businessQuality,
                  options: _businessQualityOptions,
                  onChanged: (value) =>
                      _setValue(() => _businessQuality = value),
                ),
              ),
              EditableTableRow(
                label: 'Valuation',
                value: _optionField(
                  value: _valuation,
                  options: _valuationOptions,
                  onChanged: (value) => _setValue(() => _valuation = value),
                ),
              ),
              EditableTableRow(
                label: 'Entry Point',
                value: _optionField(
                  value: _entryPoint,
                  options: _entryPointOptions,
                  onChanged: (value) => _setValue(() => _entryPoint = value),
                ),
              ),
              EditableTableRow(
                label: 'Risk Level',
                value: _optionField(
                  value: _riskLevel,
                  options: _riskLevelOptions,
                  onChanged: (value) => _setValue(() => _riskLevel = value),
                ),
              ),
              EditableTableRow(
                label: 'Final Action',
                value: _optionField(
                  value: _finalAction,
                  options: _finalActionOptions,
                  onChanged: (value) => _setValue(() => _finalAction = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Decision Notes',
              hintText:
                  'Summarize why this ticker belongs in this action bucket.',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _decisionSummaryReport() {
    return NotionBulletSummary(
      title: '${widget.ticker.toUpperCase()} Decision Summary',
      subtitle:
          'Final action: $_finalAction. Business quality is $_businessQuality, valuation is $_valuation, entry point is $_entryPoint, and risk is $_riskLevel.',
      bullets: [
        NotionSummaryBullet(
          label: 'Final action',
          value: _finalAction,
          icon: Icons.flag_outlined,
          tone: _finalAction == 'Buy Zone'
              ? AppSummaryTone.success
              : _finalAction == 'Avoid'
              ? AppSummaryTone.risk
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Business quality',
          value: _businessQuality,
          icon: Icons.business_center_outlined,
          tone: _businessQuality == 'Pass'
              ? AppSummaryTone.success
              : _businessQuality == 'Fail'
              ? AppSummaryTone.risk
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Valuation',
          value: _valuation,
          icon: Icons.price_check,
          tone: _valuation == 'Attractive'
              ? AppSummaryTone.success
              : _valuation == 'Expensive'
              ? AppSummaryTone.risk
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Entry point',
          value: _entryPoint,
          icon: Icons.login,
          tone: _entryPoint == 'Good'
              ? AppSummaryTone.success
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Risk level',
          value: _riskLevel,
          icon: Icons.warning_amber,
          tone: _riskLevel == 'Low'
              ? AppSummaryTone.success
              : _riskLevel == 'High'
              ? AppSummaryTone.risk
              : AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Business Overview signal',
          value: _businessOverview == null
              ? ''
              : '${_businessOverview!.qualityLabel} maps to ${_businessOverview!.decisionBusinessQuality}',
          icon: Icons.account_tree_outlined,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Decision notes',
          value: _notesController.text.trim(),
          icon: Icons.notes_outlined,
          tone: AppSummaryTone.neutral,
        ),
      ],
    );
  }

  AppNoteTone get _noteTone {
    return switch (_finalAction) {
      'Buy Zone' => AppNoteTone.success,
      'Avoid' => AppNoteTone.risk,
      _ => AppNoteTone.warning,
    };
  }

  Widget _optionField({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final color = AnalysisColors.forDecision(value);
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      style: TextStyle(color: color.shade900, fontWeight: FontWeight.w700),
      dropdownColor: color.shade50,
      items: options.map((option) {
        final optionColor = AnalysisColors.forDecision(option);
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: TextStyle(
              color: optionColor.shade900,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _SectionModeToggle extends StatelessWidget {
  const _SectionModeToggle({
    required this.showReportMode,
    required this.onChanged,
  });

  final bool showReportMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.edit_note),
          label: Text('Workspace'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.article_outlined),
          label: Text('Report'),
        ),
      ],
      selected: {showReportMode},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
