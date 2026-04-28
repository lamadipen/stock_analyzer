import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/ollama_ai_service.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_markdown_exporter.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class AiAnalysisSummaryContent extends StatefulWidget {
  const AiAnalysisSummaryContent({super.key, required this.ticker});

  final String ticker;

  @override
  State<AiAnalysisSummaryContent> createState() =>
      _AiAnalysisSummaryContentState();
}

class _AiAnalysisSummaryContentState extends State<AiAnalysisSummaryContent> {
  final TextEditingController _baseUrlController = TextEditingController(
    text: 'http://localhost:11434',
  );
  final TextEditingController _modelController = TextEditingController(
    text: 'gemma3',
  );
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  AiAnalysisProvider _provider = AiAnalysisProvider.ollama;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isSaving = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.aiAnalysisSummarySection,
    );

    if (!mounted) {
      return;
    }

    if (data != null) {
      _provider = AiAnalysisProvider.values.firstWhere(
        (provider) => provider.name == '${data['provider'] ?? ''}',
        orElse: () => AiAnalysisProvider.ollama,
      );
      _baseUrlController.text = '${data['baseUrl'] ?? _baseUrlController.text}'
          .trim();
      _modelController.text = '${data['model'] ?? _modelController.text}'
          .trim();
      _summaryController.text = '${data['summary'] ?? ''}';
    }

    setState(() {
      _isLoading = false;
      _hasSavedData = data != null;
      _lastSavedAt = DateTime.tryParse('${data?['savedAt'] ?? ''}');
    });
  }

  Future<void> _generateSummary() async {
    final model = _modelController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

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
      final analysisData = await StockAnalysisStorage.loadTickerAnalysis(
        ticker: widget.ticker,
      );
      final markdown = StockAnalysisMarkdownExporter.buildMarkdown(
        ticker: widget.ticker,
        data: analysisData,
      );
      final summary = await const OllamaAiService().generateAnalysisSummary(
        provider: _provider,
        baseUrl: baseUrl,
        model: model,
        apiKey: apiKey,
        analysisMarkdown: markdown,
      );

      if (!mounted) {
        return;
      }

      _summaryController.text = summary;
      await _saveSummary();
    } on OllamaAiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _saveSummary() async {
    setState(() => _isSaving = true);
    final savedAt = DateTime.now();

    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.aiAnalysisSummarySection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'provider': _provider.name,
        'baseUrl': _baseUrlController.text.trim(),
        'model': _modelController.text.trim(),
        'summary': _summaryController.text.trim(),
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

  Future<void> _clearSummary() async {
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.aiAnalysisSummarySection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _summaryController.clear();
      _hasSavedData = false;
      _lastSavedAt = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _summaryController.dispose();
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
                'AI Analysis Summary for ${widget.ticker.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            SectionSaveStatusChip(
              isSaving: _isSaving,
              hasSavedData: _hasSavedData,
              lastSavedAt: _lastSavedAt,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const AppNote(
          title: 'AI provider',
          icon: Icons.memory,
          child: Text(
            'Use local Ollama, Gemini, or Groq to summarize your saved checklist notes. API keys are used only for the request and are not saved by this app.',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<AiAnalysisProvider>(
          initialValue: _provider,
          decoration: const InputDecoration(
            labelText: 'AI Provider',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.hub_outlined),
          ),
          items: AiAnalysisProvider.values.map((provider) {
            return DropdownMenuItem(
              value: provider,
              child: Text(provider.label),
            );
          }).toList(),
          onChanged: (provider) {
            if (provider == null) {
              return;
            }

            setState(() {
              _provider = provider;
              _modelController.text = _defaultModelFor(provider);
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 680;
            final urlField = TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Ollama URL',
                hintText: 'http://localhost:11434',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            );
            final modelField = TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'gemma3, gemini-2.5-flash, llama-3.3-70b-versatile',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.smart_toy_outlined),
              ),
            );
            final apiKeyField = TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '${_provider.label} API Key',
                hintText: 'Paste your API key',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
              ),
            );

            final fields = [
              if (_provider == AiAnalysisProvider.ollama) urlField,
              modelField,
              if (_provider != AiAnalysisProvider.ollama) apiKeyField,
            ];

            if (isNarrow) {
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
                  Expanded(flex: i == 0 ? 3 : 2, child: fields[i]),
                  if (i != fields.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _isGenerating ? null : _generateSummary,
              icon: _isGenerating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Summary'),
            ),
            OutlinedButton.icon(
              onPressed: _summaryController.text.trim().isEmpty
                  ? null
                  : _saveSummary,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
            OutlinedButton.icon(
              onPressed: _clearSummary,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear'),
            ),
          ],
        ),
        if (_isGenerating) ...[
          const SizedBox(height: 12),
          AppNote(
            title: 'Generating AI summary',
            icon: Icons.hourglass_top,
            tone: AppNoteTone.info,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  'Waiting for ${_provider.label}. This can take a few seconds for cloud APIs and longer for local models.',
                ),
              ],
            ),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          AppNote(
            tone: AppNoteTone.risk,
            title: 'AI connection issue',
            icon: Icons.error_outline,
            child: Text(_errorMessage!),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _summaryController,
          minLines: 12,
          maxLines: 24,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'AI Summary',
            hintText: 'Generated summary will appear here.',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
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
