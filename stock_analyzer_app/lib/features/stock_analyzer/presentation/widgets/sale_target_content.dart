import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/sale_target_calculator.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/shared_analysis_widgets.dart';

class SaleTarget {
  SaleTarget({
    required this.title,
    required this.startDate,
    required this.principal,
    required this.growthRatePercent,
    required this.years,
  });

  final String title;
  final DateTime startDate;
  final double principal;
  final double growthRatePercent;
  final int years;

  double get targetPrice => SaleTargetCalculator.calculateTargetPrice(
    principal: principal,
    growthRatePercent: growthRatePercent,
    years: years,
  );

  DateTime get maturityDate => SaleTargetCalculator.calculateMaturityDate(
    startDate: startDate,
    years: years,
  );

  SaleTarget copyWith({
    String? title,
    DateTime? startDate,
    double? principal,
    double? growthRatePercent,
    int? years,
  }) {
    return SaleTarget(
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      principal: principal ?? this.principal,
      growthRatePercent: growthRatePercent ?? this.growthRatePercent,
      years: years ?? this.years,
    );
  }
}

class SaleTargetContent extends StatefulWidget {
  final String ticker;
  const SaleTargetContent({super.key, required this.ticker});

  @override
  State<SaleTargetContent> createState() => _SaleTargetContentState();
}

class _SaleTargetContentState extends State<SaleTargetContent> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;

  late final List<SaleTarget> _targets = _defaultTargets();

  List<SaleTarget> _defaultTargets() {
    return [
      SaleTarget(
        title: '1st Level Goal',
        startDate: DateTime(2024, 4, 26),
        principal: 8426,
        growthRatePercent: 10,
        years: 5,
      ),
      SaleTarget(
        title: '2nd Level Goal',
        startDate: DateTime(2024, 4, 26),
        principal: 8426,
        growthRatePercent: 10,
        years: 7,
      ),
      SaleTarget(
        title: '3rd Level Goal',
        startDate: DateTime(2024, 4, 26),
        principal: 8426,
        growthRatePercent: 10,
        years: 10,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.saleTargetSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    final targets = data['targets'];
    if (targets is List) {
      _targets
        ..clear()
        ..addAll(
          targets.whereType<Map<String, dynamic>>().map((target) {
            return SaleTarget(
              title: '${target['title'] ?? ''}',
              startDate:
                  DateTime.tryParse('${target['startDate'] ?? ''}') ??
                  DateTime.now(),
              principal: double.tryParse('${target['principal'] ?? ''}') ?? 0,
              growthRatePercent:
                  double.tryParse('${target['growthRatePercent'] ?? ''}') ?? 0,
              years: int.tryParse('${target['years'] ?? ''}') ?? 1,
            );
          }),
        );
    }

    setState(() {
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
    });
  }

  Future<void> _saveNow() async {
    setState(() => _isSaving = true);
    final savedAt = DateTime.now();
    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.saleTargetSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'targets': _targets.map((target) {
          return {
            'title': target.title,
            'startDate': target.startDate.toIso8601String(),
            'principal': target.principal,
            'growthRatePercent': target.growthRatePercent,
            'years': target.years,
          };
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
    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.saleTargetSection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _targets
        ..clear()
        ..addAll(_defaultTargets());
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
  }

  void _addTarget() {
    final nextLevel = _targets.length + 1;
    _showTargetDialog(
      SaleTarget(
        title: '$nextLevel${_ordinalSuffix(nextLevel)} Level Goal',
        startDate: DateTime.now(),
        principal: 0,
        growthRatePercent: 10,
        years: 5,
      ),
      onSave: (target) {
        setState(() => _targets.add(target));
        _saveNow();
      },
    );
  }

  void _editTarget(int index) {
    _showTargetDialog(
      _targets[index],
      onSave: (target) {
        setState(() => _targets[index] = target);
        _saveNow();
      },
    );
  }

  void _deleteTarget(int index) {
    setState(() => _targets.removeAt(index));
    _saveNow();
  }

  Future<void> _showTargetDialog(
    SaleTarget target, {
    required ValueChanged<SaleTarget> onSave,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: target.title);
    final principalController = TextEditingController(
      text: target.principal == 0 ? '' : target.principal.toStringAsFixed(2),
    );
    final growthController = TextEditingController(
      text: target.growthRatePercent.toStringAsFixed(2),
    );
    final yearsController = TextEditingController(
      text: target.years.toString(),
    );
    var startDate = target.startDate;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(target.title.isEmpty ? 'Sale Target' : target.title),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2200),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (picked != null) {
                              setDialogState(() => startDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(_formatDate(startDate)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: principalController,
                          decoration: const InputDecoration(
                            labelText: 'Principal / Investment Amount',
                            prefixText: r'$',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateGreaterThanZero,
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: growthController,
                          decoration: const InputDecoration(
                            labelText: 'Expected Growth Rate',
                            suffixText: '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validatePositiveNumber,
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: yearsController,
                          decoration: const InputDecoration(labelText: 'Years'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final years = int.tryParse(value?.trim() ?? '');
                            if (years == null || years <= 0) {
                              return 'Enter years greater than zero';
                            }
                            return null;
                          },
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _SaleTargetPreview(
                          startDate: startDate,
                          principal: double.tryParse(
                            principalController.text.trim(),
                          ),
                          growthRatePercent: double.tryParse(
                            growthController.text.trim(),
                          ),
                          years: int.tryParse(yearsController.text.trim()),
                          formatCurrency: _formatCurrency,
                          formatDate: _formatDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    onSave(
                      SaleTarget(
                        title: titleController.text.trim(),
                        startDate: startDate,
                        principal: double.parse(principalController.text),
                        growthRatePercent: double.parse(growthController.text),
                        years: int.parse(yearsController.text),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    principalController.dispose();
    growthController.dispose();
    yearsController.dispose();
  }

  static String? _validateGreaterThanZero(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) {
      return 'Enter a number greater than zero';
    }
    return null;
  }

  static String? _validatePositiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  static String _ordinalSuffix(int value) {
    if (value % 100 >= 11 && value % 100 <= 13) {
      return 'th';
    }
    switch (value % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String _formatCurrency(double value) {
    final rounded = value.toStringAsFixed(2);
    final parts = rounded.split('.');
    final dollars = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < dollars.length; i++) {
      if (i > 0 && (dollars.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(dollars[i]);
    }
    return '\$${buffer.toString()}.${parts.last}';
  }

  static String _formatPercent(double value) {
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}%';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profLinks = buildCompoundInterestLinks(widget.ticker);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text('View Sale Target:'),
        const SizedBox(height: 16),
        const AppNote(
          child: Text(
            'This gives overview of the sale target for the stock. We calculate the sale target based on the current stock price, the expected growth rate, and the expected dividend yield. Then we compare the sale target with the current stock price to determine if the stock is overvalued or undervalued. And also compare this is compound interest calculation based on investment period and expected return rate.',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Sale Target Calculated:'),
            SectionSaveStatusChip(
              isSaving: _isSaving,
              hasSavedData: _hasSavedData,
              lastSavedAt: _lastSavedAt,
            ),
            OutlinedButton.icon(
              onPressed: _resetSection,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
            FilledButton.icon(
              onPressed: _addTarget,
              icon: const Icon(Icons.add),
              label: const Text('Add Target'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SaleTargetsList(
          targets: _targets,
          onEdit: _editTarget,
          onDelete: _deleteTarget,
          formatCurrency: _formatCurrency,
          formatPercent: _formatPercent,
          formatDate: _formatDate,
        ),
        const SizedBox(height: 16),
        const Text('Exit Strategy:'),
        const SizedBox(height: 16),
        ReferenceLinks(
          title: 'Compound Interest References:',
          links: profLinks,
          color: Colors.green,
        ),
      ],
    );
  }
}

class _SaleTargetPreview extends StatelessWidget {
  const _SaleTargetPreview({
    required this.startDate,
    required this.principal,
    required this.growthRatePercent,
    required this.years,
    required this.formatCurrency,
    required this.formatDate,
  });

  final DateTime startDate;
  final double? principal;
  final double? growthRatePercent;
  final int? years;
  final String Function(double value) formatCurrency;
  final String Function(DateTime value) formatDate;

  @override
  Widget build(BuildContext context) {
    final principal = this.principal;
    final growthRatePercent = this.growthRatePercent;
    final years = this.years;
    if (principal == null ||
        principal <= 0 ||
        growthRatePercent == null ||
        growthRatePercent < 0 ||
        years == null ||
        years <= 0) {
      return const SizedBox.shrink();
    }

    final targetPrice = SaleTargetCalculator.calculateTargetPrice(
      principal: principal,
      growthRatePercent: growthRatePercent,
      years: years,
    );
    final maturityDate = SaleTargetCalculator.calculateMaturityDate(
      startDate: startDate,
      years: years,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculated Target',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('Target Price: ${formatCurrency(targetPrice)}'),
          Text('Maturity Date: ${formatDate(maturityDate)}'),
        ],
      ),
    );
  }
}

class _SaleTargetsList extends StatelessWidget {
  const _SaleTargetsList({
    required this.targets,
    required this.onEdit,
    required this.onDelete,
    required this.formatCurrency,
    required this.formatPercent,
    required this.formatDate,
  });

  final List<SaleTarget> targets;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final String Function(double value) formatCurrency;
  final String Function(double value) formatPercent;
  final String Function(DateTime value) formatDate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: targets.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SaleTargetCard(
                  target: entry.value,
                  onEdit: () => onEdit(entry.key),
                  onDelete: () => onDelete(entry.key),
                  formatCurrency: formatCurrency,
                  formatPercent: formatPercent,
                  formatDate: formatDate,
                ),
              );
            }).toList(),
          );
        }

        final theme = Theme.of(context);
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(Colors.green.shade50),
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Start Date')),
                DataColumn(label: Text('Principal')),
                DataColumn(label: Text('Growth')),
                DataColumn(label: Text('Years')),
                DataColumn(label: Text('Target Price')),
                DataColumn(label: Text('Maturity Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: targets.asMap().entries.map((entry) {
                final index = entry.key;
                final target = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(target.title)),
                    DataCell(Text(formatDate(target.startDate))),
                    DataCell(Text(formatCurrency(target.principal))),
                    DataCell(Text(formatPercent(target.growthRatePercent))),
                    DataCell(Text('${target.years}')),
                    DataCell(
                      Text(
                        formatCurrency(target.targetPrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    DataCell(Text(formatDate(target.maturityDate))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => onEdit(index),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => onDelete(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _SaleTargetCard extends StatelessWidget {
  const _SaleTargetCard({
    required this.target,
    required this.onEdit,
    required this.onDelete,
    required this.formatCurrency,
    required this.formatPercent,
    required this.formatDate,
  });

  final SaleTarget target;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(double value) formatCurrency;
  final String Function(double value) formatPercent;
  final String Function(DateTime value) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  target.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const Divider(height: 16),
          _TargetDetailRow(
            label: 'Start Date',
            value: formatDate(target.startDate),
          ),
          _TargetDetailRow(
            label: 'Principal',
            value: formatCurrency(target.principal),
          ),
          _TargetDetailRow(
            label: 'Growth',
            value: formatPercent(target.growthRatePercent),
          ),
          _TargetDetailRow(label: 'Years', value: '${target.years}'),
          _TargetDetailRow(
            label: 'Target Price',
            value: formatCurrency(target.targetPrice),
            isEmphasized: true,
          ),
          _TargetDetailRow(
            label: 'Maturity Date',
            value: formatDate(target.maturityDate),
          ),
        ],
      ),
    );
  }
}

class _TargetDetailRow extends StatelessWidget {
  const _TargetDetailRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final color = isEmphasized ? Colors.green.shade800 : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: isEmphasized ? FontWeight.w800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
