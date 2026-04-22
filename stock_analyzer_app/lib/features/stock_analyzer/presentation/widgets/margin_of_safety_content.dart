import 'package:flutter/material.dart';

class MarginOfSafetyContent extends StatelessWidget {
  final String ticker;
  const MarginOfSafetyContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Margin of Safety of $ticker will be displayed here.');
  }
}