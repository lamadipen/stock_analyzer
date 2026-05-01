import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/ollama_ai_service.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/notion_bullet_summary.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class BusinessOverviewContent extends StatefulWidget {
  final String ticker;
  const BusinessOverviewContent({super.key, required this.ticker});

  @override
  State<BusinessOverviewContent> createState() =>
      _BusinessOverviewContentState();
}

class _BusinessOverviewContentState extends State<BusinessOverviewContent> {
  final TextEditingController _businessModelController =
      TextEditingController();
  final TextEditingController _revenueSourcesController =
      TextEditingController();
  final TextEditingController _mainSegmentController = TextEditingController();
  final TextEditingController _growthDriverController = TextEditingController();
  final TextEditingController _earningsSignalController =
      TextEditingController();
  final TextEditingController _stockTrendController = TextEditingController();
  final TextEditingController _rawResearchController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController(
    text: 'http://localhost:11434',
  );
  final TextEditingController _modelController = TextEditingController(
    text: 'gemma3',
  );
  final TextEditingController _apiKeyController = TextEditingController();
  Timer? _saveDebounce;

  AiAnalysisProvider _provider = AiAnalysisProvider.ollama;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGenerating = false;
  bool _hasSavedData = false;
  bool _suspendAutosave = false;
  bool _showReportMode = false;
  DateTime? _lastSavedAt;
  String? _errorMessage;
  late List<_BusinessChecklistItem> _items = _defaultItems();

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_scheduleSave);
    }
    _baseUrlController.addListener(_scheduleSave);
    _modelController.addListener(_scheduleSave);
    _loadSavedData();
  }

  List<TextEditingController> get _controllers => [
    _businessModelController,
    _revenueSourcesController,
    _mainSegmentController,
    _growthDriverController,
    _earningsSignalController,
    _stockTrendController,
    _rawResearchController,
  ];

  List<_BusinessChecklistItem> _defaultItems() {
    return const [
      _BusinessChecklistItem(
        title: 'Clear business model',
        subtitle:
            'You can explain what the company sells and who pays for it in one sentence.',
        isChecked: true,
      ),
      _BusinessChecklistItem(
        title: 'Revenue sources are understandable',
        subtitle:
            'Major products, services, segments, or customer groups are identifiable.',
      ),
      _BusinessChecklistItem(
        title: 'Recurring or durable revenue profile',
        subtitle:
            'Subscriptions, usage, repeat purchases, or high retention support revenue durability.',
      ),
      _BusinessChecklistItem(
        title: 'Demand has a long-term tailwind',
        subtitle:
            'Growth is connected to a durable market trend instead of only short-term hype.',
      ),
      _BusinessChecklistItem(
        title: 'Stock trend supports investor confidence',
        subtitle:
            'The 1-year and 5-year charts do not contradict the business story.',
      ),
      _BusinessChecklistItem(
        title: 'Earnings expectations support momentum',
        subtitle:
            'Expected EPS, recent beats/misses, and price reaction do not point to a broken setup.',
      ),
    ];
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.businessOverviewSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _businessModelController.text = '${data['businessModel'] ?? ''}';
    _revenueSourcesController.text = '${data['revenueSources'] ?? ''}';
    _mainSegmentController.text = '${data['mainSegment'] ?? ''}';
    _growthDriverController.text = '${data['growthDriver'] ?? ''}';
    _earningsSignalController.text = '${data['earningsSignal'] ?? ''}';
    _stockTrendController.text = '${data['stockTrend'] ?? ''}';
    _rawResearchController.text = '${data['rawResearch'] ?? ''}';
    _provider = AiAnalysisProvider.values.firstWhere(
      (provider) => provider.name == '${data['provider'] ?? ''}',
      orElse: () => AiAnalysisProvider.ollama,
    );
    _baseUrlController.text = '${data['baseUrl'] ?? _baseUrlController.text}'
        .trim();
    _modelController.text = '${data['model'] ?? _defaultModelFor(_provider)}'
        .trim();

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

  void _scheduleSave() {
    if (_isLoading || _suspendAutosave) {
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
      section: StockAnalysisStorage.businessOverviewSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'businessModel': _businessModelController.text.trim(),
        'revenueSources': _revenueSourcesController.text.trim(),
        'mainSegment': _mainSegmentController.text.trim(),
        'growthDriver': _growthDriverController.text.trim(),
        'earningsSignal': _earningsSignalController.text.trim(),
        'stockTrend': _stockTrendController.text.trim(),
        'rawResearch': _rawResearchController.text.trim(),
        'provider': _provider.name,
        'baseUrl': _baseUrlController.text.trim(),
        'model': _modelController.text.trim(),
        'items': _items.map((item) {
          return {'title': item.title, 'isChecked': item.isChecked};
        }).toList(),
        'qualityScore': _qualityScore,
        'qualityLabel': _qualityLabel,
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

  Future<void> _generateDraft() async {
    final model = _modelController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (_rawResearchController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Paste raw research before generating.';
      });
      return;
    }

    if (model.isEmpty ||
        (_provider == AiAnalysisProvider.ollama && baseUrl.isEmpty)) {
      setState(() {
        _errorMessage = 'Enter a provider URL and model name.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final draft = await const OllamaAiService().generateBusinessOverviewDraft(
        provider: _provider,
        baseUrl: baseUrl,
        model: model,
        apiKey: apiKey,
        ticker: widget.ticker,
        rawResearch: _rawResearchController.text,
      );

      if (!mounted) {
        return;
      }

      _suspendAutosave = true;
      _businessModelController.text = draft.businessModel;
      _revenueSourcesController.text = draft.revenueSources;
      _mainSegmentController.text = draft.mainSegment;
      _growthDriverController.text = draft.growthDriver;
      _earningsSignalController.text = draft.earningsSignal;
      _stockTrendController.text = draft.stockTrend;
      _suspendAutosave = false;

      await _saveNow();
    } on OllamaAiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _suspendAutosave = false;
        });
      }
    }
  }

  Future<void> _resetSection() async {
    _saveDebounce?.cancel();
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.businessOverviewSection,
    );

    if (!mounted) {
      return;
    }

    _suspendAutosave = true;
    setState(() {
      for (final controller in _controllers) {
        controller.clear();
      }
      _items = _defaultItems();
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
      _errorMessage = null;
    });
    _suspendAutosave = false;
  }

  int get _qualityScore => _items.where((item) => item.isChecked).length;

  String get _qualityLabel {
    final score = _qualityScore;
    if (score >= 5) {
      return 'Strong';
    }
    if (score >= 3) {
      return 'Mixed';
    }
    return 'Weak';
  }

  AppNoteTone get _qualityTone {
    return switch (_qualityLabel) {
      'Strong' => AppNoteTone.success,
      'Weak' => AppNoteTone.risk,
      _ => AppNoteTone.warning,
    };
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final links = buildBusinessOverviewLinks(widget.ticker);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Business Overview for ${widget.ticker.toUpperCase()}',
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
        _SectionModeToggle(
          showReportMode: _showReportMode,
          onChanged: (value) => setState(() => _showReportMode = value),
        ),
        const SizedBox(height: 12),
        if (_showReportMode) ...[
          _businessOverviewReport(),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Business Overview References:', links: links),
        ] else ...[
          AppNote(
            title: 'Business quality: $_qualityLabel',
            icon: Icons.lightbulb_outline,
            tone: _qualityTone,
            child: Text(
              'Score: $_qualityScore/${_items.length}. Understand what ${widget.ticker.toUpperCase()} does, how revenue is generated, and whether earnings expectations support the business story.',
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
          _rawResearchField(),
          const SizedBox(height: 16),
          _AiDraftControls(
            provider: _provider,
            baseUrlController: _baseUrlController,
            modelController: _modelController,
            apiKeyController: _apiKeyController,
            isGenerating: _isGenerating,
            onProviderChanged: (provider) {
              setState(() {
                _provider = provider;
                _modelController.text = _defaultModelFor(provider);
                _errorMessage = null;
              });
              _scheduleSave();
            },
            onGenerate: _generateDraft,
          ),
          if (_isGenerating) ...[
            const SizedBox(height: 12),
            AppNote(
              title: 'Generating business overview',
              icon: Icons.hourglass_top,
              tone: AppNoteTone.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(
                    'Waiting for ${_provider.label}. Local models can take a little longer.',
                  ),
                ],
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            AppNote(
              tone: AppNoteTone.risk,
              title: 'AI draft issue',
              icon: Icons.error_outline,
              child: Text(_errorMessage!),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Business Research Notes',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          EditableTable(
            rows: [
              EditableTableRow(
                label: 'Business model',
                value: _textField(
                  controller: _businessModelController,
                  hintText:
                      'Example: Adobe sells creative, document, and digital experience software to consumers and enterprises.',
                ),
              ),
              EditableTableRow(
                label: 'Revenue sources',
                value: _textField(
                  controller: _revenueSourcesController,
                  hintText:
                      'Subscriptions, services, licensing, advertising, transactions, hardware, or other streams.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Main segment',
                value: _textField(
                  controller: _mainSegmentController,
                  hintText:
                      'Largest revenue segment and any segment growing faster than the rest.',
                ),
              ),
              EditableTableRow(
                label: 'Growth driver',
                value: _textField(
                  controller: _growthDriverController,
                  hintText:
                      'Products, customers, geographies, acquisitions, AI, pricing, or market expansion.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Earnings signal',
                value: _textField(
                  controller: _earningsSignalController,
                  hintText:
                      'Next earnings date, expected EPS, whisper expectation, recent beats/misses, and expected reaction.',
                  minLines: 2,
                ),
              ),
              EditableTableRow(
                label: 'Stock trend',
                value: _textField(
                  controller: _stockTrendController,
                  hintText:
                      '1-year, 5-year, and max chart read. Note whether the trend confirms or challenges the thesis.',
                  minLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _businessOverviewReport(),
          const SizedBox(height: 16),
          const AppNote(
            tone: AppNoteTone.info,
            child: Text(
              'Example for Adobe: Digital Media and Digital Experience are the key operating segments. Creative Cloud, Document Cloud, and enterprise experience tools explain most of the business model, while EPS expectations and price reaction help validate near-term sentiment.',
            ),
          ),
          const SizedBox(height: 16),
          const AppNote(
            tone: AppNoteTone.warning,
            icon: Icons.fact_check_outlined,
            child: Text(
              'Do not rely only on product popularity. Confirm revenue growth, profitability, earnings consistency, and whether recent acquisitions improve the core business.',
            ),
          ),
          const SizedBox(height: 16),
          ReferenceLinks(title: 'Business Overview References:', links: links),
        ],
      ],
    );
  }

  Widget _businessOverviewReport() {
    return NotionBulletSummary(
      title: '${widget.ticker.toUpperCase()} Business Overview',
      subtitle:
          'Business quality: $_qualityLabel ($_qualityScore/${_items.length}).',
      bullets: [
        NotionSummaryBullet(
          label: 'Business model',
          value: _businessModelController.text.trim(),
          icon: Icons.business_center_outlined,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Revenue sources',
          value: _revenueSourcesController.text.trim(),
          icon: Icons.payments_outlined,
          tone: AppSummaryTone.info,
        ),
        NotionSummaryBullet(
          label: 'Main segment',
          value: _mainSegmentController.text.trim(),
          icon: Icons.account_tree_outlined,
          tone: AppSummaryTone.neutral,
        ),
        NotionSummaryBullet(
          label: 'Growth driver',
          value: _growthDriverController.text.trim(),
          icon: Icons.trending_up,
          tone: AppSummaryTone.success,
        ),
        NotionSummaryBullet(
          label: 'Earnings signal',
          value: _earningsSignalController.text.trim(),
          icon: Icons.event_available_outlined,
          tone: AppSummaryTone.warning,
        ),
        NotionSummaryBullet(
          label: 'Stock trend',
          value: _stockTrendController.text.trim(),
          icon: Icons.show_chart,
          tone: AppSummaryTone.neutral,
        ),
        NotionSummaryBullet(
          label: 'Checked quality signals',
          value: _checkedQualitySignals,
          icon: Icons.checklist,
          tone: _qualityLabel == 'Strong'
              ? AppSummaryTone.success
              : _qualityLabel == 'Weak'
              ? AppSummaryTone.risk
              : AppSummaryTone.warning,
        ),
      ],
    );
  }

  String get _checkedQualitySignals {
    final checked = _items.where((item) => item.isChecked).map((item) {
      return item.title;
    }).toList();
    return checked.isEmpty ? '' : checked.join(', ');
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _rawResearchField() {
    return TextField(
      controller: _rawResearchController,
      minLines: 4,
      maxLines: 8,
      decoration: const InputDecoration(
        labelText: 'Raw Research / Paste Zone',
        hintText:
            'Paste company description, StockAnalysis stats, revenue breakdown, or EarningsWhispers notes here.',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.content_paste_search),
      ),
    );
  }

  String _defaultModelFor(AiAnalysisProvider provider) {
    return switch (provider) {
      AiAnalysisProvider.ollama => 'gemma3',
      AiAnalysisProvider.gemini => 'gemini-2.5-flash',
      AiAnalysisProvider.groq => 'llama-3.3-70b-versatile',
    };
  }
}

class _AiDraftControls extends StatelessWidget {
  const _AiDraftControls({
    required this.provider,
    required this.baseUrlController,
    required this.modelController,
    required this.apiKeyController,
    required this.isGenerating,
    required this.onProviderChanged,
    required this.onGenerate,
  });

  final AiAnalysisProvider provider;
  final TextEditingController baseUrlController;
  final TextEditingController modelController;
  final TextEditingController apiKeyController;
  final bool isGenerating;
  final ValueChanged<AiAnalysisProvider> onProviderChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final providerField = DropdownButtonFormField<AiAnalysisProvider>(
      initialValue: provider,
      decoration: const InputDecoration(
        labelText: 'AI Provider',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.hub_outlined),
      ),
      items: AiAnalysisProvider.values.map((provider) {
        return DropdownMenuItem(value: provider, child: Text(provider.label));
      }).toList(),
      onChanged: isGenerating
          ? null
          : (value) {
              if (value != null) {
                onProviderChanged(value);
              }
            },
    );

    final urlField = TextField(
      controller: baseUrlController,
      enabled: !isGenerating,
      decoration: const InputDecoration(
        labelText: 'Ollama URL',
        hintText: 'http://localhost:11434',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
      ),
    );
    final modelField = TextField(
      controller: modelController,
      enabled: !isGenerating,
      decoration: const InputDecoration(
        labelText: 'Model',
        hintText: 'gemma3, gemini-2.5-flash, llama-3.3-70b-versatile',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.smart_toy_outlined),
      ),
    );
    final apiKeyField = TextField(
      controller: apiKeyController,
      obscureText: true,
      enabled: !isGenerating,
      decoration: InputDecoration(
        labelText: '${provider.label} API Key',
        hintText: 'Paste your API key',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.key),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppNote(
          title: 'AI draft',
          icon: Icons.auto_awesome,
          child: Text(
            'Paste raw source text, then generate a structured draft. API keys are used only for the request and are not saved.',
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final fields = [
              providerField,
              if (provider == AiAnalysisProvider.ollama) urlField,
              modelField,
              if (provider != AiAnalysisProvider.ollama) apiKeyField,
            ];

            if (constraints.maxWidth < 720) {
              return Column(
                children: fields
                    .expand((field) => [field, const SizedBox(height: 12)])
                    .take(fields.length * 2 - 1)
                    .toList(),
              );
            }

            return Row(
              children: [
                for (var i = 0; i < fields.length; i++) ...[
                  Expanded(flex: i == 0 ? 2 : 3, child: fields[i]),
                  if (i != fields.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: isGenerating ? null : onGenerate,
          icon: isGenerating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_fix_high),
          label: Text(isGenerating ? 'Generating...' : 'Generate Draft'),
        ),
      ],
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

class _BusinessChecklistItem {
  const _BusinessChecklistItem({
    required this.title,
    required this.subtitle,
    this.isChecked = false,
  });

  final String title;
  final String subtitle;
  final bool isChecked;

  _BusinessChecklistItem copyWith({bool? isChecked}) {
    return _BusinessChecklistItem(
      title: title,
      subtitle: subtitle,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
