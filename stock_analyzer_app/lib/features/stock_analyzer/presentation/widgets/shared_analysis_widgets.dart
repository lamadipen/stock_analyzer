import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppNoteTone { neutral, info, warning, success, risk }

class AppNote extends StatelessWidget {
  const AppNote({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.tone = AppNoteTone.neutral,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final AppNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AppNoteTone.neutral => AnalysisColors.reference,
      AppNoteTone.info => Colors.blue,
      AppNoteTone.warning => AnalysisColors.caution,
      AppNoteTone.success => AnalysisColors.favorable,
      AppNoteTone.risk => AnalysisColors.risk,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline, color: color.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: color.shade900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: color.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistCardItem {
  const ChecklistCardItem({
    required this.title,
    this.subtitle,
    this.isChecked = false,
    this.isChild = false,
  });

  final String title;
  final String? subtitle;
  final bool isChecked;
  final bool isChild;
}

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({super.key, required this.items, this.onChanged});

  final List<ChecklistCardItem> items;
  final void Function(int index, bool isChecked)? onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return CheckboxListTile(
            value: item.isChecked,
            onChanged: onChanged == null
                ? null
                : (value) => onChanged!(index, value ?? false),
            title: Text(item.title),
            subtitle: item.subtitle == null ? null : Text(item.subtitle!),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.only(
              left: item.isChild ? 32 : 8,
              right: 12,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReferenceLinks extends StatelessWidget {
  const ReferenceLinks({
    super.key,
    required this.title,
    required this.links,
    this.color = AnalysisColors.reference,
  });

  final String title;
  final Map<String, String> links;
  final MaterialColor color;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: links.entries.map((entry) {
            return ActionChip(
              label: Text(entry.key),
              onPressed: () => _launch(entry.value),
              backgroundColor: color.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class EditableTableRow {
  const EditableTableRow({required this.label, required this.value});

  final String label;
  final Widget value;
}

class EditableTable extends StatelessWidget {
  const EditableTable({super.key, required this.rows});

  final List<EditableTableRow> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: Colors.blueGrey.shade100)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 560;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      row.value,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: row.value),
                  ],
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
