import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/collapsible_section.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/content_registry.dart';

enum _AppAnalysisLayout { classic, workspace, focus }

class AnalysisResultsView extends StatefulWidget {
  final String ticker;
  const AnalysisResultsView({super.key, required this.ticker});

  @override
  State<AnalysisResultsView> createState() => _AnalysisResultsViewState();
}

class _AnalysisResultsViewState extends State<AnalysisResultsView> {
  _AppAnalysisLayout _layout = _AppAnalysisLayout.workspace;
  int _selectedIndex = 0;

  final List<_AnalysisSection> _sections = const [
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
  Widget build(BuildContext context) {
    final selectedSection = _sections[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResultsHeader(
          ticker: widget.ticker,
          layout: _layout,
          onLayoutChanged: (layout) => setState(() => _layout = layout),
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
                selectedIndex: _selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SectionSurface(
                section: selectedSection,
                ticker: widget.ticker,
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
    required this.onLayoutChanged,
  });

  final String ticker;
  final _AppAnalysisLayout layout;
  final ValueChanged<_AppAnalysisLayout> onLayoutChanged;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

class _SectionNavigation extends StatelessWidget {
  const _SectionNavigation({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_AnalysisSection> sections;
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
              subtitle: Text(section.category),
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
  const _SectionSurface({required this.section, required this.ticker});

  final _AnalysisSection section;
  final String ticker;

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
    required this.selectedTitle,
    required this.onSelected,
  });

  final String title;
  final List<_AnalysisSection> sections;
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
              return FilterChip(
                selected: selected,
                avatar: Icon(section.icon, size: 18),
                label: Text(section.title),
                onSelected: (_) => onSelected(section),
              );
            }).toList(),
          ),
        ],
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
