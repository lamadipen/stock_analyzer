import 'package:flutter/material.dart';

class BusinessOverviewContent extends StatelessWidget {
  final String ticker;
  const BusinessOverviewContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Business Overview of $ticker will be displayed here.');
  }
}