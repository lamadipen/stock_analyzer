import 'package:flutter/material.dart';

class CollapsibleSection extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.icon,
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
        children: [
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16.0), child: content),
        ],
      ),
    );
  }
}
