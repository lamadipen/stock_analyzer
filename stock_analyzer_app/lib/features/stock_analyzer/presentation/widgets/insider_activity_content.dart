import 'package:flutter/material.dart';

class InsiderActivityContent extends StatelessWidget {
  final String ticker;
  const InsiderActivityContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Insider Activity of $ticker will be displayed here.');
  }
}