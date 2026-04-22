import 'package:flutter/material.dart';

class SaleTargetContent extends StatelessWidget {
  final String ticker;
  const SaleTargetContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Sale Target of $ticker will be displayed here.');
  }
}