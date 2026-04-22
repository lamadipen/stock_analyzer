import 'package:flutter/material.dart';

class ImpliedVolatilityContent extends StatelessWidget {
  final String ticker;
  const ImpliedVolatilityContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Implied Volatility of $ticker will be displayed here.');
  }
}