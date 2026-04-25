import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/analysis_results_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _tickerController = TextEditingController();
  bool _showResults = false;
  String _activeTicker = '';

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  void _searchStock() {
    final String ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isNotEmpty) {
      setState(() {
        _activeTicker = ticker;
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Analyzer'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const Icon(Icons.query_stats, size: 18),
              label: Text(_showResults ? _activeTicker : 'Research Workspace'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blueGrey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 680;
                    final searchField = TextField(
                      controller: _tickerController,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _searchStock(),
                      decoration: const InputDecoration(
                        labelText: 'Stock ticker',
                        hintText: 'AAPL, MSFT, GOOGL',
                        prefixIcon: Icon(Icons.search),
                      ),
                    );
                    final searchButton = FilledButton.icon(
                      onPressed: _searchStock,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze'),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Investment checklist workspace',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review quality, valuation, risk, entry points, and sale targets in one place.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isNarrow) ...[
                          searchField,
                          const SizedBox(height: 12),
                          SizedBox(width: double.infinity, child: searchButton),
                        ] else
                          Row(
                            children: [
                              Expanded(child: searchField),
                              const SizedBox(width: 12),
                              searchButton,
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _showResults
                    ? AnalysisResultsView(ticker: _activeTicker)
                    : _EmptyResearchState(theme: theme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResearchState extends StatelessWidget {
  const _EmptyResearchState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stacked_line_chart, size: 44, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              'Start with a ticker',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your checklist, valuation methods, margin of safety notes, and target planning will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.blueGrey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
