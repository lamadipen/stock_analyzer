import 'package:flutter/material.dart';

class CollapsibleSection extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final String? status;
  final Color? statusColor;
  final Widget? statusSelector;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.status,
    this.statusColor,
    this.statusSelector,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: icon == null ? null : Icon(icon),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: status == null
            ? null
            : Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (statusColor ?? Colors.blueGrey).withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      color: statusColor ?? Colors.blueGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
        children: [
          const Divider(height: 1),
          if (statusSelector != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: statusSelector!,
              ),
            ),
          Padding(padding: const EdgeInsets.all(16.0), child: content),
        ],
      ),
    );
  }
}
