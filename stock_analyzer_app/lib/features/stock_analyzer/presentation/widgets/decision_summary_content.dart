import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
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
  DateTime? _lastSavedAt;

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
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.decisionSummarySection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _businessQuality = _readOption(
      data['businessQuality'],
      _businessQualityOptions,
      _businessQuality,
    );
    _valuation = _readOption(data['valuation'], _valuationOptions, _valuation);
    _entryPoint = _readOption(
      data['entryPoint'],
      _entryPointOptions,
      _entryPoint,
    );
    _riskLevel = _readOption(data['riskLevel'], _riskLevelOptions, _riskLevel);
    _finalAction = _readOption(
      data['finalAction'],
      _finalActionOptions,
      _finalAction,
    );
    _notesController.text = '${data['notes'] ?? ''}';

    setState(() {
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
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
      data: {
        'savedAt': savedAt.toIso8601String(),
        'businessQuality': _businessQuality,
        'valuation': _valuation,
        'entryPoint': _entryPoint,
        'riskLevel': _riskLevel,
        'finalAction': _finalAction,
        'notes': _notesController.text,
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
    });
  }

  void _setValue(void Function() update) {
    setState(update);
    _scheduleSave();
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
        const SizedBox(height: 16),
        EditableTable(
          rows: [
            EditableTableRow(
              label: 'Business Quality',
              value: _optionField(
                value: _businessQuality,
                options: _businessQualityOptions,
                onChanged: (value) => _setValue(() => _businessQuality = value),
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
