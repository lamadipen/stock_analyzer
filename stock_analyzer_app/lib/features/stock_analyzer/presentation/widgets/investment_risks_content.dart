import 'package:flutter/material.dart';

class InvestmentRisksContent extends StatelessWidget {
  final String ticker;
  const InvestmentRisksContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Investment Risks of $ticker will be displayed here.');
  }
}