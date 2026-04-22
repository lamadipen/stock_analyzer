import 'package:flutter/material.dart';

class GrowthDriverContent extends StatelessWidget {
  final String ticker;
  const GrowthDriverContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Growth Driver of $ticker will be displayed here.');
  }
}