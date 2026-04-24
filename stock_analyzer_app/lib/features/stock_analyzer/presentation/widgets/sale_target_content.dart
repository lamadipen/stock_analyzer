import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/utils/ticker_links.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/domain/sale_target_calculator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late final List<SaleTarget> _targets = [
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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
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
      onSave: (target) => setState(() => _targets.add(target)),
    );
  }

  void _editTarget(int index) {
    _showTargetDialog(
      _targets[index],
      onSave: (target) => setState(() => _targets[index] = target),
    );
  }

  void _deleteTarget(int index) {
    setState(() => _targets.removeAt(index));
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
    final profLinks = buildCompoundInterestLinks(widget.ticker);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- criteria ----
        const Text('View Sale Target:'),
        const SizedBox(height: 16),
        // ---- note box ----
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This gives overview of the sale target for the stock. We calculate the sale target based on the current stock price, the expected growth rate, and the expected dividend yield. Then we compare the sale target with the current stock price to determine if the stock is overvalued or undervalued. And also compare this is compound interest calculation based on investment period and expected return rate.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Text('Sale Target Calculated:')),
            FilledButton.icon(
              onPressed: _addTarget,
              icon: const Icon(Icons.add),
              label: const Text('Add Target'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
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
              rows: _targets.asMap().entries.map((entry) {
                final index = entry.key;
                final target = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(target.title)),
                    DataCell(Text(_formatDate(target.startDate))),
                    DataCell(Text(_formatCurrency(target.principal))),
                    DataCell(Text(_formatPercent(target.growthRatePercent))),
                    DataCell(Text('${target.years}')),
                    DataCell(
                      Text(
                        _formatCurrency(target.targetPrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    DataCell(Text(_formatDate(target.maturityDate))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTarget(index),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteTarget(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Exist Strategy:'),
        const SizedBox(height: 16),
        // ---- profitability references ----
        const Text(
          'Compound Interest References:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profLinks.entries.map((e) {
            return ActionChip(
              label: Text(e.key),
              onPressed: () => _launch(e.value),
              backgroundColor: Colors.green.shade50,
            );
          }).toList(),
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
