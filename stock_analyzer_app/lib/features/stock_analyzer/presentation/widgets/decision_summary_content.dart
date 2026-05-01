import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/section_completion_rules.dart';
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
  bool _showReportMode = true;
  DateTime? _lastSavedAt;
  String? _businessOverviewMessage;
  String? _suggestionsMessage;
  BusinessOverview? _businessOverview;
  _DecisionSuggestions? _suggestions;

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
    final economicMoatData = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.economicMoatSection,
    );
    final valuationData = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.valuationMethodSection,
    );
    final marginOfSafetyData = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.marginOfSafetySection,
    );
    final reviewStatuses = await StockAnalysisStorage.loadReviewStatuses(
      ticker: widget.ticker,
    );
    final tickerData = await StockAnalysisStorage.loadTickerAnalysis(
      ticker: widget.ticker,
    );

    if (!mounted) {
      return;
    }

    final businessOverview = businessOverviewData == null
        ? null
        : BusinessOverview.fromJson(businessOverviewData);
    final suggestions = _buildDecisionSuggestions(
      businessOverview: businessOverview,
      economicMoatData: economicMoatData,
      valuationData: valuationData,
      marginOfSafetyData: marginOfSafetyData,
      reviewStatuses: reviewStatuses,
      tickerData: tickerData,
    );

    if (decisionData == null) {
      _applySuggestionValues(suggestions);
      _notesController.text = _buildSuggestionNotes(
        suggestions,
        businessOverview: businessOverview,
      );

      setState(() {
        _businessOverview = businessOverview;
        _suggestions = suggestions;
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
      _suggestions = suggestions;
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
      _suggestionsMessage = null;
      _businessOverview = null;
      _suggestions = null;
    });
  }

  void _setValue(void Function() update) {
    setState(update);
    _scheduleSave();
  }

  void _applySuggestionValues(_DecisionSuggestions suggestions) {
    _businessQuality = suggestions.businessQuality.value;
    _valuation = suggestions.valuation.value;
    _entryPoint = suggestions.entryPoint.value;
    _riskLevel = suggestions.riskLevel.value;
    _finalAction = _finalActionFromSuggestions(suggestions);
  }

  Future<void> _applyMultiSectionSuggestions() async {
    final suggestions = _suggestions;
    if (suggestions == null) {
      return;
    }

    final suggestionNotes = _buildSuggestionNotes(
      suggestions,
      businessOverview: _businessOverview,
    );
    final currentNotes = _removeExistingSuggestionsBlock(
      _removeExistingBusinessOverviewBlock(_notesController.text),
    ).trim();

    setState(() {
      _applySuggestionValues(suggestions);
      _notesController.text = [
        suggestionNotes,
        if (currentNotes.isNotEmpty) currentNotes,
      ].join('\n\n');
      _suggestionsMessage =
          'Applied multi-section suggestions. You can still override each field manually.';
    });

    await _saveNow();
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

  _DecisionSuggestions _buildDecisionSuggestions({
    required BusinessOverview? businessOverview,
    required Map<String, dynamic>? economicMoatData,
    required Map<String, dynamic>? valuationData,
    required Map<String, dynamic>? marginOfSafetyData,
    required Map<String, String> reviewStatuses,
    required Map<String, dynamic> tickerData,
  }) {
    final moatStatus = _completionAwareStatus(
      'Economic Moat',
      reviewStatuses,
      tickerData,
    );
    final valuationStatus = _completionAwareStatus(
      'Valuation Method',
      reviewStatuses,
      tickerData,
    );
    final risksStatus = _completionAwareStatus(
      'Investment Risks',
      reviewStatuses,
      tickerData,
    );
    final moatCheckedCount = _checkedItemCount(economicMoatData?['items']);
    final moatTotalCount = _listCount(economicMoatData?['items']);
    final valuationCheckedCount = _checkedItemCount(valuationData?['checked']);
    final marginOfSafety = marginOfSafetyData == null
        ? null
        : MarginOfSafety.fromJson(marginOfSafetyData);

    final moatIsComplete = moatStatus == 'complete';
    final moatIsFavorable = moatCheckedCount >= 4;
    final valuationIsComplete = valuationStatus == 'complete';
    final valuationIsSupported = valuationCheckedCount > 0;
    final marginIsGood = marginOfSafety?.isGreatEntry == true;
    final risksComplete = risksStatus == 'complete';

    final businessQuality = businessOverview != null
        ? _DecisionSuggestion(
            value: businessOverview.decisionBusinessQuality,
            reason:
                'Business Overview is ${businessOverview.qualityLabel}; mapped from its section score.',
          )
        : moatIsComplete && moatIsFavorable
        ? _DecisionSuggestion(
            value: 'Pass',
            reason:
                'Economic Moat is complete with $moatCheckedCount/$moatTotalCount moat signals checked.',
          )
        : moatIsComplete
        ? _DecisionSuggestion(
            value: moatCheckedCount <= 1 ? 'Fail' : 'Watch',
            reason:
                'Economic Moat is complete but only $moatCheckedCount/$moatTotalCount moat signals are checked.',
          )
        : _DecisionSuggestion(
            value: 'Watch',
            reason: 'Economic Moat is not marked complete yet.',
          );

    final valuation = valuationIsComplete && valuationIsSupported
        ? _DecisionSuggestion(
            value: 'Attractive',
            reason:
                'Valuation Method is complete with $valuationCheckedCount method signal(s) selected.',
          )
        : valuationIsComplete
        ? const _DecisionSuggestion(
            value: 'Fair',
            reason:
                'Valuation Method is complete, but no valuation method is selected.',
          )
        : const _DecisionSuggestion(
            value: 'Fair',
            reason: 'Valuation Method is not marked complete yet.',
          );

    final entryPoint = valuation.value == 'Attractive' && marginIsGood
        ? const _DecisionSuggestion(
            value: 'Good',
            reason:
                'Valuation is attractive and Margin of Safety confirms a great entry.',
          )
        : _DecisionSuggestion(
            value: 'Wait',
            reason: marginIsGood
                ? 'Margin of Safety is favorable, but valuation is not attractive yet.'
                : 'Margin of Safety has not confirmed a great entry.',
          );

    final riskLevel = !risksComplete
        ? _DecisionSuggestion(
            value: 'High',
            reason:
                'Investment Risks is ${_humanizeStatus(risksStatus)}, so unresolved risk remains high.',
          )
        : const _DecisionSuggestion(
            value: 'Medium',
            reason:
                'Investment Risks is complete. Keep Medium unless the risk review supports Low or High.',
          );

    return _DecisionSuggestions(
      businessQuality: businessQuality,
      valuation: valuation,
      entryPoint: entryPoint,
      riskLevel: riskLevel,
      finalAction: _DecisionSuggestion(
        value: _finalActionFor(
          businessQuality.value,
          valuation.value,
          entryPoint.value,
          riskLevel.value,
        ),
        reason: 'Derived from the four suggested decision fields.',
      ),
    );
  }

  String _completionAwareStatus(
    String sectionTitle,
    Map<String, String> reviewStatuses,
    Map<String, dynamic> tickerData,
  ) {
    if (SectionCompletionRules.isComplete(
      sectionTitle: sectionTitle,
      tickerData: tickerData,
    )) {
      return 'complete';
    }

    final stored = reviewStatuses[sectionTitle] ?? 'notStarted';
    return stored == 'complete' ? 'inReview' : stored;
  }

  int _checkedItemCount(Object? value) {
    if (value is List<bool>) {
      return value.where((item) => item).length;
    }
    if (value is List) {
      return value.where((item) {
        if (item is bool) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          return item['isChecked'] == true;
        }
        return false;
      }).length;
    }
    return 0;
  }

  int _listCount(Object? value) {
    return value is List ? value.length : 0;
  }

  String _finalActionFromSuggestions(_DecisionSuggestions suggestions) {
    return _finalActionFor(
      suggestions.businessQuality.value,
      suggestions.valuation.value,
      suggestions.entryPoint.value,
      suggestions.riskLevel.value,
    );
  }

  String _finalActionFor(
    String businessQuality,
    String valuation,
    String entryPoint,
    String riskLevel,
  ) {
    if (businessQuality == 'Fail' || riskLevel == 'High') {
      return 'Avoid';
    }
    if (businessQuality == 'Pass' &&
        valuation == 'Attractive' &&
        entryPoint == 'Good' &&
        riskLevel != 'High') {
      return 'Buy Zone';
    }
    return 'Watchlist';
  }

  String _humanizeStatus(String value) {
    return switch (value) {
      'notStarted' => 'not started',
      'inReview' => 'in review',
      'complete' => 'complete',
      _ => value,
    };
  }

  String _buildSuggestionNotes(
    _DecisionSuggestions suggestions, {
    required BusinessOverview? businessOverview,
  }) {
    final lines = <String>[
      '[Decision Suggestions]',
      _noteLine(
        'Business quality suggestion',
        '${suggestions.businessQuality.value} - ${suggestions.businessQuality.reason}',
      ),
      _noteLine(
        'Valuation suggestion',
        '${suggestions.valuation.value} - ${suggestions.valuation.reason}',
      ),
      _noteLine(
        'Entry point suggestion',
        '${suggestions.entryPoint.value} - ${suggestions.entryPoint.reason}',
      ),
      _noteLine(
        'Risk level suggestion',
        '${suggestions.riskLevel.value} - ${suggestions.riskLevel.reason}',
      ),
      _noteLine(
        'Final action suggestion',
        '${suggestions.finalAction.value} - ${suggestions.finalAction.reason}',
      ),
      '[/Decision Suggestions]',
      if (businessOverview != null)
        _buildBusinessOverviewNote(businessOverview),
    ];

    return lines.where((line) => line.trim().isNotEmpty).join('\n');
  }

  String _buildBusinessOverviewNote(BusinessOverview businessOverview) {
    final lines = <String>[
      '[Business Overview]',
      'Business quality: ${businessOverview.qualityLabel} (${businessOverview.qualityScore} score)',
      _noteLine('Business model', businessOverview.businessModel),
      _noteLine('Revenue sources', businessOverview.revenueSources),
      _noteLine('Main segment', businessOverview.mainSegment),
      _noteLine('Growth driver', businessOverview.growthDriver),
      _noteLine(
        'Earnings signal',
        _withFreshness(
          businessOverview.earningsSignal,
          businessOverview.earningsSignalCheckedAt,
        ),
      ),
      _noteLine(
        'Analyst rating',
        _withFreshness(
          businessOverview.analystRating,
          businessOverview.analystRatingCheckedAt,
        ),
      ),
      _noteLine(
        'Stock trend',
        _withFreshness(
          businessOverview.stockTrend,
          businessOverview.stockTrendCheckedAt,
        ),
      ),
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

  String _withFreshness(String value, DateTime? checkedAt) {
    final text = value.trim();
    if (text.isEmpty) {
      return '';
    }

    return '$text (last checked: ${_formatFreshness(checkedAt)})';
  }

  String _formatFreshness(DateTime? dateTime) {
    if (dateTime == null) {
      return 'not marked';
    }

    final local = dateTime.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  String _removeExistingBusinessOverviewBlock(String text) {
    return text
        .replaceAll(
          RegExp(r'\n*\[Business Overview\][\s\S]*?\[/Business Overview\]\n*'),
          '\n',
        )
        .trim();
  }

  String _removeExistingSuggestionsBlock(String text) {
    return text
        .replaceAll(
          RegExp(
            r'\n*\[Decision Suggestions\][\s\S]*?\[/Decision Suggestions\]\n*',
          ),
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
                onPressed: _suggestions == null
                    ? null
                    : _applyMultiSectionSuggestions,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Apply Suggestions'),
              ),
              OutlinedButton.icon(
                onPressed: _applyBusinessOverview,
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Refresh Business Overview'),
              ),
            ],
          ),
          if (_suggestions != null) ...[
            const SizedBox(height: 12),
            _SuggestionPanel(suggestions: _suggestions!),
          ],
          if (_suggestionsMessage != null) ...[
            const SizedBox(height: 12),
            AppNote(
              title: 'Suggestion sync',
              icon: Icons.auto_awesome,
              tone: AppNoteTone.success,
              child: Text(_suggestionsMessage!),
            ),
          ],
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
          label: 'Multi-section suggestion',
          value: _suggestions == null
              ? ''
              : 'Business ${_suggestions!.businessQuality.value}, valuation ${_suggestions!.valuation.value}, entry ${_suggestions!.entryPoint.value}, risk ${_suggestions!.riskLevel.value}, action ${_suggestions!.finalAction.value}.',
          icon: Icons.auto_awesome,
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

class _DecisionSuggestion {
  const _DecisionSuggestion({required this.value, required this.reason});

  final String value;
  final String reason;
}

class _DecisionSuggestions {
  const _DecisionSuggestions({
    required this.businessQuality,
    required this.valuation,
    required this.entryPoint,
    required this.riskLevel,
    required this.finalAction,
  });

  final _DecisionSuggestion businessQuality;
  final _DecisionSuggestion valuation;
  final _DecisionSuggestion entryPoint;
  final _DecisionSuggestion riskLevel;
  final _DecisionSuggestion finalAction;

  List<_SuggestionRowData> get rows {
    return [
      _SuggestionRowData('Business Quality', businessQuality),
      _SuggestionRowData('Valuation', valuation),
      _SuggestionRowData('Entry Point', entryPoint),
      _SuggestionRowData('Risk Level', riskLevel),
      _SuggestionRowData('Final Action', finalAction),
    ];
  }
}

class _SuggestionRowData {
  const _SuggestionRowData(this.label, this.suggestion);

  final String label;
  final _DecisionSuggestion suggestion;
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.suggestions});

  final _DecisionSuggestions suggestions;

  @override
  Widget build(BuildContext context) {
    return AppNote(
      title: 'Multi-section suggestions',
      icon: Icons.auto_awesome,
      tone: AppNoteTone.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestions.rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '${row.label}: ${row.suggestion.value}. ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: row.suggestion.reason),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
