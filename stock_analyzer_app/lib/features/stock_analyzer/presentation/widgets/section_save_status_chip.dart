import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';

class SectionSaveStatusChip extends StatelessWidget {
  const SectionSaveStatusChip({
    super.key,
    required this.isSaving,
    required this.hasSavedData,
    required this.lastSavedAt,
  });

  final bool isSaving;
  final bool hasSavedData;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final label = isSaving
        ? 'Saving...'
        : hasSavedData
        ? 'Saved ${_formatTime(lastSavedAt)}'
        : 'Not saved yet';

    return Chip(
      avatar: Icon(
        isSaving ? Icons.sync : Icons.check_circle_outline,
        size: 18,
      ),
      label: Text(label),
      backgroundColor: hasSavedData ? AnalysisColors.favorable.shade50 : null,
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
