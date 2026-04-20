import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/widgets/analysis_results_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _tickerController = TextEditingController();
  bool _showResults = false;

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  void _searchStock() {
    final String ticker = _tickerController.text.trim();
    if (ticker.isNotEmpty) {
      setState(() {
        _showResults = true;
      });
      // TODO: Implement stock data fetching logic
      print('Searching for stock: $ticker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tickerController,
              decoration: const InputDecoration(
                labelText: 'Enter Stock Ticker (e.g., AAPL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchStock,
              child: const Text('Search'),
            ),
            if (_showResults) ...[
              const SizedBox(height: 16.0),
              Expanded(child: AnalysisResultsView()),
            ],
          ],
        ),
      ),
    );
  }
}
