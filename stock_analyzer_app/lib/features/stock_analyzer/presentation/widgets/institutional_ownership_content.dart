import 'package:flutter/material.dart';

class InstitutionalOwnershipContent extends StatelessWidget {
  final String ticker;
  const InstitutionalOwnershipContent({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Text('Details for Institutional Ownership of $ticker will be displayed here.');
  }
}