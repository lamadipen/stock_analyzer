import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
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
  late Future<List<SavedTickerSummary>> _savedTickersFuture;

  @override
  void initState() {
    super.initState();
    _savedTickersFuture = StockAnalysisStorage.loadSavedTickerSummaries();
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  void _searchStock() {
    final String ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isNotEmpty) {
      _openTicker(ticker);
    }
  }

  void _openTicker(String ticker) {
    _tickerController.text = ticker;
    setState(() {
      _activeTicker = ticker;
      _showResults = true;
    });
  }

  void _showDashboard() {
    setState(() {
      _showResults = false;
      _savedTickersFuture = StockAnalysisStorage.loadSavedTickerSummaries();
    });
  }

  void _refreshDashboard() {
    setState(() {
      _savedTickersFuture = StockAnalysisStorage.loadSavedTickerSummaries();
    });
  }

  Future<void> _showTickerSearchDialog() async {
    final controller = TextEditingController(text: _activeTicker);
    final ticker = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Ticker'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Stock ticker',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value.trim().toUpperCase());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim().toUpperCase(),
                );
              },
              child: const Text('Analyze'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (ticker != null && ticker.isNotEmpty) {
      _openTicker(ticker);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Analyzer'),
        actions: [
          if (_showResults) ...[
            IconButton(
              tooltip: 'Change ticker',
              icon: const Icon(Icons.search),
              onPressed: _showTickerSearchDialog,
            ),
            IconButton(
              tooltip: 'Dashboard',
              icon: const Icon(Icons.dashboard_outlined),
              onPressed: _showDashboard,
            ),
          ] else
            IconButton(
              tooltip: 'Refresh dashboard',
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDashboard,
            ),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 680;
                  if (_showResults && isNarrow) {
                    return const SizedBox.shrink();
                  }

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

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueGrey.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
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
                    ),
                  );
                },
              ),
              if (!_showResults) const SizedBox(height: 16),
              Expanded(
                child: _showResults
                    ? AnalysisResultsView(ticker: _activeTicker)
                    : _SavedTickersDashboard(
                        summariesFuture: _savedTickersFuture,
                        onAnalyzeTicker: _openTicker,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTickersDashboard extends StatelessWidget {
  const _SavedTickersDashboard({
    required this.summariesFuture,
    required this.onAnalyzeTicker,
  });

  final Future<List<SavedTickerSummary>> summariesFuture;
  final ValueChanged<String> onAnalyzeTicker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<SavedTickerSummary>>(
      future: summariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final summaries = snapshot.data ?? const <SavedTickerSummary>[];
        if (summaries.isEmpty) {
          return _EmptyDashboardState(theme: theme);
        }

        final buyZoneCount = summaries
            .where((summary) => summary.finalAction == 'Buy Zone')
            .length;
        final watchlistCount = summaries
            .where((summary) => summary.finalAction == 'Watchlist')
            .length;
        final highRiskCount = summaries
            .where((summary) => summary.riskLevel == 'High')
            .length;

        return ListView(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DashboardMetricCard(
                  label: 'Saved Tickers',
                  value: '${summaries.length}',
                  icon: Icons.folder_copy_outlined,
                  color: AnalysisColors.reference,
                ),
                _DashboardMetricCard(
                  label: 'Buy Zone',
                  value: '$buyZoneCount',
                  icon: Icons.trending_up,
                  color: AnalysisColors.favorable,
                ),
                _DashboardMetricCard(
                  label: 'Watchlist',
                  value: '$watchlistCount',
                  icon: Icons.visibility_outlined,
                  color: AnalysisColors.caution,
                ),
                _DashboardMetricCard(
                  label: 'High Risk',
                  value: '$highRiskCount',
                  icon: Icons.warning_amber,
                  color: AnalysisColors.risk,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 760;
                if (isNarrow) {
                  return Column(
                    children: summaries.map((summary) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TickerSummaryCard(
                          summary: summary,
                          onTap: () => onAnalyzeTicker(summary.ticker),
                        ),
                      );
                    }).toList(),
                  );
                }

                return _TickerSummaryTable(
                  summaries: summaries,
                  onAnalyzeTicker: onAnalyzeTicker,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(label, style: TextStyle(color: color.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerSummaryTable extends StatelessWidget {
  const _TickerSummaryTable({
    required this.summaries,
    required this.onAnalyzeTicker,
  });

  final List<SavedTickerSummary> summaries;
  final ValueChanged<String> onAnalyzeTicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(Colors.blueGrey.shade50),
        columns: const [
          DataColumn(label: Text('Ticker')),
          DataColumn(label: Text('Updated')),
          DataColumn(label: Text('Final Action')),
          DataColumn(label: Text('Risk')),
          DataColumn(label: Text('Progress')),
          DataColumn(label: Text('Actions')),
        ],
        rows: summaries.map((summary) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  summary.ticker,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DataCell(Text(_formatDate(summary.updatedAt))),
              DataCell(_SummaryPill(value: summary.finalAction)),
              DataCell(_SummaryPill(value: summary.riskLevel)),
              DataCell(_ProgressSummary(summary: summary)),
              DataCell(
                FilledButton.icon(
                  onPressed: () => onAnalyzeTicker(summary.ticker),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TickerSummaryCard extends StatelessWidget {
  const _TickerSummaryCard({required this.summary, required this.onTap});

  final SavedTickerSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade50,
                  child: Text(summary.ticker.characters.first),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.ticker,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text('Updated ${_formatDate(summary.updatedAt)}'),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryPill(value: summary.finalAction),
                _SummaryPill(value: summary.riskLevel),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressSummary(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final color = AnalysisColors.forDecision(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(color: color.shade900, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.summary});

  final SavedTickerSummary summary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${summary.completedSections} / ${summary.totalSections} complete',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: summary.completionProgress),
        ],
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState({required this.theme});

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
            Icon(Icons.dashboard_outlined, size: 44, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              'No saved tickers yet',
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

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Not saved';
  }

  return '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}';
}
