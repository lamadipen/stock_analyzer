import 'package:flutter/material.dart';

class AnalysisColors {
  const AnalysisColors._();

  static const MaterialColor favorable = Colors.green;
  static const MaterialColor caution = Colors.amber;
  static const MaterialColor risk = Colors.red;
  static const MaterialColor reference = Colors.blueGrey;

  static MaterialColor forDecision(String value) {
    return switch (value.toLowerCase()) {
      'pass' || 'attractive' || 'good' || 'low' || 'buy zone' => favorable,
      'watch' || 'fair' || 'wait' || 'medium' || 'watchlist' => caution,
      'fail' || 'expensive' || 'high' || 'avoid' => risk,
      _ => reference,
    };
  }
}
