import 'package:flutter/material.dart';

class CollapsibleSection extends StatelessWidget {
  final String title;
  final Widget content;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: [Padding(padding: const EdgeInsets.all(16.0), child: content)],
    );
  }
}
