import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_markdown_exporter.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/content_registry.dart';

enum _AppAnalysisLayout { classic, workspace, focus }

enum _ReviewStatus {
  notStarted('Not Started'),
  inReview('In Review'),
  complete('Complete');

  const _ReviewStatus(this.label);

  final String label;
}

class AnalysisResultsView extends StatefulWidget {
  final String ticker;
  const AnalysisResultsView({super.key, required this.ticker});

  @override
  State<AnalysisResultsView> createState() => _AnalysisResultsViewState();
}

class _AnalysisResultsViewState extends State<AnalysisResultsView> {
  _AppAnalysisLayout _layout = _AppAnalysisLayout.workspace;
  int _selectedIndex = 0;
  bool _isLoadingStatuses = true;
  final Map<String, _ReviewStatus> _reviewStatuses = {};

  final List<_AnalysisSection> _sections = const [
    _AnalysisSection(
      title: 'Decision Summary',
      category: 'Summary',
      icon: Icons.fact_check,
    ),
    _AnalysisSection(
      title: 'Business Overview',
      category: 'Company',
      icon: Icons.business_center,
    ),
    _AnalysisSection(
      title: 'Financial Highlights',
      category: 'Company',
      icon: Icons.insert_chart_outlined,
    ),
    _AnalysisSection(
      title: 'Competitor Study',
      category: 'Company',
      icon: Icons.compare_arrows,
    ),
    _AnalysisSection(
      title: 'Economic Moat',
      category: 'Quality',
      icon: Icons.castle,
    ),
    _AnalysisSection(
      title: 'Growth Driver',
      category: 'Quality',
      icon: Icons.rocket_launch,
    ),
    _AnalysisSection(
      title: 'Valuation Method',
      category: 'Valuation',
      icon: Icons.price_check,
    ),
    _AnalysisSection(
      title: 'Margin of Safety',
      category: 'Valuation',
      icon: Icons.shield,
    ),
    _AnalysisSection(
      title: 'Sale Target',
      category: 'Valuation',
      icon: Icons.flag,
    ),
    _AnalysisSection(
      title: 'Investment Risks',
      category: 'Risk',
      icon: Icons.warning_amber,
    ),
    _AnalysisSection(
      title: 'Implied Volatility (IV)',
      category: 'Risk',
      icon: Icons.show_chart,
    ),
    _AnalysisSection(
      title: 'Institutional Ownership',
      category: 'Ownership',
      icon: Icons.account_balance,
    ),
    _AnalysisSection(
      title: 'Insider Activity',
      category: 'Ownership',
      icon: Icons.badge,
    ),
    _AnalysisSection(
      title: 'Sector Comparison',
      category: 'Market',
      icon: Icons.pie_chart,
    ),
    _AnalysisSection(
      title: 'Short Term Investment',
      category: 'Market',
      icon: Icons.timeline,
    ),
    _AnalysisSection(title: 'Resources', category: 'Market', icon: Icons.link),
  ];

  @override
  void initState() {
    super.initState();
    _loadReviewStatuses();
  }

  @override
  void didUpdateWidget(covariant AnalysisResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticker != widget.ticker) {
      _selectedIndex = 0;
      _reviewStatuses.clear();
      _loadReviewStatuses();
    }
  }

  Future<void> _loadReviewStatuses() async {
    setState(() => _isLoadingStatuses = true);
    final statuses = await StockAnalysisStorage.loadReviewStatuses(
      ticker: widget.ticker,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      for (final section in _sections) {
        _reviewStatuses[section.title] = _statusFromStorage(
          statuses[section.title],
        );
      }
      _isLoadingStatuses = false;
    });
  }

  Future<void> _setReviewStatus(
    _AnalysisSection section,
    _ReviewStatus status,
  ) async {
    setState(() => _reviewStatuses[section.title] = status);
    await StockAnalysisStorage.saveReviewStatus(
      ticker: widget.ticker,
      section: section.title,
      status: status.name,
    );
  }

  _ReviewStatus _statusFor(_AnalysisSection section) {
    return _reviewStatuses[section.title] ?? _ReviewStatus.notStarted;
  }

  _ReviewStatus _statusFromStorage(String? value) {
    return _ReviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => _ReviewStatus.notStarted,
    );
  }

  Color _statusColor(_ReviewStatus status) {
    return switch (status) {
      _ReviewStatus.notStarted => AnalysisColors.reference,
      _ReviewStatus.inReview => AnalysisColors.caution,
      _ReviewStatus.complete => AnalysisColors.favorable,
    };
  }

  Future<void> _showExportDialog() async {
    final analysisData = await StockAnalysisStorage.loadTickerAnalysis(
      ticker: widget.ticker,
    );

    if (!mounted) {
      return;
    }

    final markdown = StockAnalysisMarkdownExporter.buildMarkdown(
      ticker: widget.ticker,
      data: analysisData,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Export Markdown Report'),
          content: SizedBox(
            width: 720,
            height: 520,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  markdown,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: markdown));
                if (!dialogContext.mounted) {
                  return;
                }
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Markdown report copied')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Markdown'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSection = _sections[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResultsHeader(
          ticker: widget.ticker,
          layout: _layout,
          completedCount: _reviewStatuses.values
              .where((status) => status == _ReviewStatus.complete)
              .length,
          inReviewCount: _reviewStatuses.values
              .where((status) => status == _ReviewStatus.inReview)
              .length,
          totalCount: _sections.length,
          isLoadingStatuses: _isLoadingStatuses,
          onLayoutChanged: (layout) => setState(() => _layout = layout),
          onExport: _showExportDialog,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (_layout) {
            _AppAnalysisLayout.classic => _buildClassicLayout(),
            _AppAnalysisLayout.workspace => _buildWorkspaceLayout(
              selectedSection,
            ),
            _AppAnalysisLayout.focus => _buildFocusLayout(selectedSection),
          },
        ),
      ],
    );
  }

  Widget _buildClassicLayout() {
    return ListView.separated(
      itemCount: _sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final section = _sections[index];
        final content = getContentWidget(section.title, widget.ticker);

        return CollapsibleSection(
          title: section.title,
          icon: section.icon,
          status: _statusFor(section).label,
          statusColor: _statusColor(_statusFor(section)),
          statusSelector: _StatusDropdown(
            status: _statusFor(section),
            onChanged: (status) => _setReviewStatus(section, status),
          ),
          content: content,
        );
      },
    );
  }

  Widget _buildWorkspaceLayout(_AnalysisSection selectedSection) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 820;
        if (isNarrow) {
          return Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedIndex,
                decoration: const InputDecoration(
                  labelText: 'Analysis Section',
                  prefixIcon: Icon(Icons.view_list),
                ),
                items: _sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return DropdownMenuItem(
                    value: index,
                    child: Text(section.title),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedIndex = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _SectionSurface(
                  section: selectedSection,
                  ticker: widget.ticker,
                  status: _statusFor(selectedSection),
                  onStatusChanged: (status) =>
                      _setReviewStatus(selectedSection, status),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 280,
              child: _SectionNavigation(
                sections: _sections,
                statuses: _reviewStatuses,
                selectedIndex: _selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SectionSurface(
                section: selectedSection,
                ticker: widget.ticker,
                status: _statusFor(selectedSection),
                onStatusChanged: (status) =>
                    _setReviewStatus(selectedSection, status),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFocusLayout(_AnalysisSection selectedSection) {
    final grouped = <String, List<_AnalysisSection>>{};
    for (final section in _sections) {
      grouped.putIfAbsent(section.category, () => []).add(section);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        final categoryRail = ListView(
          children: grouped.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryGroup(
                title: entry.key,
                sections: entry.value,
                statuses: _reviewStatuses,
                selectedTitle: selectedSection.title,
                onSelected: (section) {
                  setState(() => _selectedIndex = _sections.indexOf(section));
                },
              ),
            );
          }).toList(),
        );

        if (isNarrow) {
          return Column(
            children: [
              SizedBox(height: 190, child: categoryRail),
              const SizedBox(height: 12),
              Expanded(
                child: _SectionSurface(
                  section: selectedSection,
                  ticker: widget.ticker,
                  status: _statusFor(selectedSection),
                  onStatusChanged: (status) =>
                      _setReviewStatus(selectedSection, status),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 340, child: categoryRail),
            const SizedBox(width: 12),
            Expanded(
              child: _SectionSurface(
                section: selectedSection,
                ticker: widget.ticker,
                status: _statusFor(selectedSection),
                onStatusChanged: (status) =>
                    _setReviewStatus(selectedSection, status),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.ticker,
    required this.layout,
    required this.completedCount,
    required this.inReviewCount,
    required this.totalCount,
    required this.isLoadingStatuses,
    required this.onLayoutChanged,
    required this.onExport,
  });

  final String ticker;
  final _AppAnalysisLayout layout;
  final int completedCount;
  final int inReviewCount;
  final int totalCount;
  final bool isLoadingStatuses;
  final ValueChanged<_AppAnalysisLayout> onLayoutChanged;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueGrey.shade50,
                child: Text(ticker.isEmpty ? '?' : ticker[0]),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticker,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Analysis workspace',
                    style: TextStyle(color: Colors.blueGrey.shade700),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLoadingStatuses
                            ? 'Loading progress'
                            : '$completedCount / $totalCount sections complete',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('$inReviewCount in review'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
          SegmentedButton<_AppAnalysisLayout>(
            segments: const [
              ButtonSegment(
                value: _AppAnalysisLayout.classic,
                icon: Icon(Icons.view_agenda),
                label: Text('Classic'),
              ),
              ButtonSegment(
                value: _AppAnalysisLayout.workspace,
                icon: Icon(Icons.dashboard_customize),
                label: Text('Workspace'),
              ),
              ButtonSegment(
                value: _AppAnalysisLayout.focus,
                icon: Icon(Icons.account_tree),
                label: Text('Focus'),
              ),
            ],
            selected: {layout},
            onSelectionChanged: (selection) => onLayoutChanged(selection.first),
          ),
          FilledButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.ios_share),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _SectionNavigation extends StatelessWidget {
  const _SectionNavigation({
    required this.sections,
    required this.statuses,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_AnalysisSection> sections;
  final Map<String, _ReviewStatus> statuses;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final selected = index == selectedIndex;
          final status = statuses[section.title] ?? _ReviewStatus.notStarted;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              selected: selected,
              selectedTileColor: Colors.blueGrey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: Icon(section.icon),
              title: Text(section.title),
              subtitle: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(section.category),
                  _StatusBadge(status: status),
                ],
              ),
              dense: true,
              onTap: () => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({
    required this.section,
    required this.ticker,
    required this.status,
    required this.onStatusChanged,
  });

  final _AnalysisSection section;
  final String ticker;
  final _ReviewStatus status;
  final ValueChanged<_ReviewStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Icon(section.icon, color: Colors.blueGrey.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        section.category,
                        style: TextStyle(color: Colors.blueGrey.shade700),
                      ),
                    ],
                  ),
                ),
                _StatusDropdown(status: status, onChanged: onStatusChanged),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: getContentWidget(section.title, ticker),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.title,
    required this.sections,
    required this.statuses,
    required this.selectedTitle,
    required this.onSelected,
  });

  final String title;
  final List<_AnalysisSection> sections;
  final Map<String, _ReviewStatus> statuses;
  final String selectedTitle;
  final ValueChanged<_AnalysisSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sections.map((section) {
              final selected = section.title == selectedTitle;
              final status =
                  statuses[section.title] ?? _ReviewStatus.notStarted;
              return FilterChip(
                selected: selected,
                avatar: Icon(section.icon, size: 18),
                label: Text('${section.title} • ${status.label}'),
                onSelected: (_) => onSelected(section),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.status, required this.onChanged});

  final _ReviewStatus status;
  final ValueChanged<_ReviewStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<_ReviewStatus>(
      value: status,
      underline: const SizedBox.shrink(),
      items: _ReviewStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: _StatusBadge(status: status),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _ReviewStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _ReviewStatus.notStarted => AnalysisColors.reference,
      _ReviewStatus.inReview => AnalysisColors.caution,
      _ReviewStatus.complete => AnalysisColors.favorable,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AnalysisSection {
  const _AnalysisSection({
    required this.title,
    required this.category,
    required this.icon,
  });

  final String title;
  final String category;
  final IconData icon;
}
