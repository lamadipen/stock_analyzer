import 'package:flutter/material.dart';

class EconomicMoatContent extends StatelessWidget {
  final String ticker;
  const EconomicMoatContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Economic Moat of $ticker will be displayed here.');
  }
}