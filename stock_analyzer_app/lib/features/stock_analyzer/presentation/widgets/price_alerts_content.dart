import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/core/services/stock_analysis_storage.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/section_save_status_chip.dart';

class PriceAlertsContent extends StatefulWidget {
  const PriceAlertsContent({super.key, required this.ticker});

  final String ticker;

  @override
  State<PriceAlertsContent> createState() => _PriceAlertsContentState();
}

class _PriceAlertsContentState extends State<PriceAlertsContent> {
  final TextEditingController _currentPriceController = TextEditingController();
  final TextEditingController _buyZoneController = TextEditingController();
  final TextEditingController _sellTargetController = TextEditingController();
  final TextEditingController _marginOfSafetyController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRestoring = false;
  bool _hasSavedData = false;
  DateTime? _lastSavedAt;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_scheduleSave);
    }
    _loadSavedData();
  }

  List<TextEditingController> get _controllers {
    return [
      _currentPriceController,
      _buyZoneController,
      _sellTargetController,
      _marginOfSafetyController,
      _notesController,
    ];
  }

  Future<void> _loadSavedData() async {
    final data = await StockAnalysisStorage.loadSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.priceAlertsSection,
    );

    if (!mounted) {
      return;
    }

    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isRestoring = true;
    _currentPriceController.text = '${data['currentPrice'] ?? ''}';
    _buyZoneController.text = '${data['buyZone'] ?? ''}';
    _sellTargetController.text = '${data['sellTarget'] ?? ''}';
    _marginOfSafetyController.text = '${data['marginOfSafetyPrice'] ?? ''}';
    _notesController.text = '${data['notes'] ?? ''}';
    _isRestoring = false;

    setState(() {
      _isLoading = false;
      _hasSavedData = true;
      _lastSavedAt = DateTime.tryParse('${data['savedAt'] ?? ''}');
    });
  }

  void _scheduleSave() {
    if (_isLoading || _isRestoring) {
      return;
    }

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveNow);
  }

  Future<void> _saveNow() async {
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = true);
    final savedAt = DateTime.now();
    await StockAnalysisStorage.saveSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.priceAlertsSection,
      data: {
        'savedAt': savedAt.toIso8601String(),
        'currentPrice': _currentPriceController.text,
        'buyZone': _buyZoneController.text,
        'sellTarget': _sellTargetController.text,
        'marginOfSafetyPrice': _marginOfSafetyController.text,
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
    _isRestoring = true;
    for (final controller in _controllers) {
      controller.clear();
    }
    _isRestoring = false;

    await StockAnalysisStorage.clearSection(
      ticker: widget.ticker,
      section: StockAnalysisStorage.priceAlertsSection,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _hasSavedData = false;
      _lastSavedAt = null;
      _isSaving = false;
    });
  }

  double? _valueOf(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '').trim());
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentPrice = _valueOf(_currentPriceController);
    final buyZone = _valueOf(_buyZoneController);
    final sellTarget = _valueOf(_sellTargetController);
    final marginOfSafety = _valueOf(_marginOfSafetyController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Price Alerts / Target Tracking for ${widget.ticker}',
                style: const TextStyle(fontWeight: FontWeight.w600),
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
        const _TrackingNote(
          text:
              'Use this worksheet to track manual price levels. It does not fetch live prices yet, but it keeps your buy, sell, and margin-of-safety thresholds actionable.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final fields = [
              _PriceField(
                controller: _currentPriceController,
                label: 'Current Price',
                icon: Icons.attach_money,
              ),
              _PriceField(
                controller: _buyZoneController,
                label: 'Buy Zone',
                icon: Icons.shopping_cart_checkout,
              ),
              _PriceField(
                controller: _sellTargetController,
                label: 'Sell Target',
                icon: Icons.flag,
              ),
              _PriceField(
                controller: _marginOfSafetyController,
                label: 'Margin-of-Safety Price',
                icon: Icons.shield,
              ),
            ];

            if (isNarrow) {
              return Column(
                children: fields
                    .map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: field,
                      ),
                    )
                    .toList(),
              );
            }

            return Wrap(spacing: 12, runSpacing: 12, children: fields);
          },
        ),
        const SizedBox(height: 16),
        _TrackingSummary(
          currentPrice: currentPrice,
          buyZone: buyZone,
          sellTarget: sellTarget,
          marginOfSafety: marginOfSafety,
          formatCurrency: _formatCurrency,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Tracking Notes',
            hintText: 'Add chart context, trigger notes, or alert plan.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixText: r'$',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _TrackingSummary extends StatelessWidget {
  const _TrackingSummary({
    required this.currentPrice,
    required this.buyZone,
    required this.sellTarget,
    required this.marginOfSafety,
    required this.formatCurrency,
  });

  final double? currentPrice;
  final double? buyZone;
  final double? sellTarget;
  final double? marginOfSafety;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _TrackingStatusCard(
        label: 'Buy Zone',
        value: _priceRelationship(
          target: buyZone,
          favorableWhenCurrentIsBelow: true,
        ),
        icon: Icons.shopping_cart_checkout,
        color: _isAtOrBelow(buyZone)
            ? AnalysisColors.favorable
            : AnalysisColors.reference,
      ),
      _TrackingStatusCard(
        label: 'Sell Target',
        value: _priceRelationship(
          target: sellTarget,
          favorableWhenCurrentIsBelow: false,
        ),
        icon: Icons.flag,
        color: _isAtOrAbove(sellTarget)
            ? AnalysisColors.favorable
            : AnalysisColors.caution,
      ),
      _TrackingStatusCard(
        label: 'Margin of Safety',
        value: _priceRelationship(
          target: marginOfSafety,
          favorableWhenCurrentIsBelow: true,
        ),
        icon: Icons.shield,
        color: _isAtOrBelow(marginOfSafety)
            ? AnalysisColors.favorable
            : AnalysisColors.reference,
      ),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: cards);
  }

  bool _isAtOrBelow(double? target) {
    return currentPrice != null && target != null && currentPrice! <= target;
  }

  bool _isAtOrAbove(double? target) {
    return currentPrice != null && target != null && currentPrice! >= target;
  }

  String _priceRelationship({
    required double? target,
    required bool favorableWhenCurrentIsBelow,
  }) {
    if (currentPrice == null || target == null) {
      return 'Add prices';
    }

    final difference = currentPrice! - target;
    if (difference == 0) {
      return 'At ${formatCurrency(target)}';
    }

    final absoluteDifference = difference.abs();
    final direction = difference > 0 ? 'above' : 'below';
    final signal = favorableWhenCurrentIsBelow
        ? difference <= 0
              ? 'Inside range'
              : 'Wait'
        : difference >= 0
        ? 'Reached'
        : 'Below target';

    return '$signal • ${formatCurrency(absoluteDifference)} $direction';
  }
}

class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({
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
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color.shade800)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingNote extends StatelessWidget {
  const _TrackingNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
