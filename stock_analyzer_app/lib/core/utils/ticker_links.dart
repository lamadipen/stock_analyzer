/// Returns a map {sourceName : url} for the entered ticker.
Map<String, String> buildFinancialLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'Seeking Alpha': 'https://seekingalpha.com/symbol/$upper/income-statement',
    'Stock Analysis': 'https://stockanalysis.com/stocks/$upper/financials/',
    'WSJ':
        'https://www.wsj.com/market-data/quotes/XE/$upper/financials/annual/income-statement',
    'ADVFN':
        'https://www.advfn.com/stock-market/NASDAQ/$upper/financials/stats-and-ratios',
    'MarketWatch':
        'https://www.marketwatch.com/investing/stock/$upper/financials?mod=mw_quote_tab',
  };
}

/// Profitability-focused deep-links
Map<String, String> buildProfitabilityLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'Morningstar': 'https://www.morningstar.com/stocks/xnas/$upper/key-metrics',
    'ADVFN':
        'https://www.advfn.com/stock-market/NYSE/$upper/financials/stats-and-ratios',
    'Finviz': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Macrotrends':
        'https://www.macrotrends.net/stocks/charts/$upper/${upper.toLowerCase()}/gross-profit',
  };
}

/// Debt & solvency deep-links
Map<String, String> buildDebtLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'Finviz Debt': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Stock Analysis Ratios':
        'https://stockanalysis.com/stocks/$upper/financials/ratios/',
  };
}

/// Profitability-focused deep-links
Map<String, String> buildSectorComparisionLinks(String ticker) {
  return {'Finviz': 'https://finviz.com/groups.ashx?g=sector&v=210&o=name'};
}
