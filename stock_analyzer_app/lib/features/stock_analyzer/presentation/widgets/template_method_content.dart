import 'package:flutter/material.dart';

class TemplateMethodContent extends StatelessWidget {
  final String ticker;
  const TemplateMethodContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Details for Valuation Method of $ticker will be displayed here.',
    );
  }
}
