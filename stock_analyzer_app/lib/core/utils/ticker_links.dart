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

/// sector comparison deep-links
Map<String, String> buildSectorComparisionLinks(String ticker) {
  return {'Finviz': 'https://finviz.com/groups.ashx?g=sector&v=210&o=name'};
}

Map<String, String> buildInsiderActivityLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'GuruFocus': 'https://www.gurufocus.com/stock/$upper/insider',
    'MarketWatch':
        'https://www.marketwatch.com/investing/stock/$upper/company-profile?mod=mw_quote_tab',
  };
}

Map<String, String> buildInstitutionalOwnershipLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'Marketbeat':
        'https://www.marketbeat.com/stocks/NASDAQ/$upper/institutional-ownership/',
  };
}

Map<String, String> buildImplivedVolatilityLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'Alphaquery':
        'https://www.alphaquery.com/stock/$upper/volatility-option-statistics/30-day/iv-mean',
  };
}

Map<String, String> buildCompoundInterestLinks(String ticker) {
  return {
    'Compound Interest Calculator':
        'https://www.calculatorsoup.com/calculators/financial/compound-interest-calculator.php',
  };
}

Map<String, String> buildCompetitorStudyLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'MarketBeat Peer Comparison':
        'https://www.marketbeat.com/stocks/NYSE/$upper/competitors-and-alternatives/',
    'Seeking Alpha Peer Comparison':
        'https://seekingalpha.com/symbol/$upper/peers/comparison',
    'Seeking Alpha Charting': 'https://seekingalpha.com/symbol/$upper/charting',
    'MarketWatch Chart':
        'https://www.marketwatch.com/investing/stock/$lower/charts?mod=mw_quote_tab',
    'CNBC Peers': 'https://www.cnbc.com/quotes/$upper?tab=peers',
  };
}

Map<String, String> buildValuationMethodLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Macrotrends PE Ratio':
        'https://www.macrotrends.net/stocks/charts/$upper/$lower/pe-ratio',
    'Valueinvesting Intrinsic Value':
        'https://valueinvesting.io/$upper/valuation/intrinsic-value',
    'Alpha Spread Summary':
        'https://www.alphaspread.com/security/nasdaq/$lower/summary',
    'Alpha Spread Calculator':
        'https://www.alphaspread.com/intrinsic-value-calculator',
    'Macroaxis Valuation':
        'https://www.macroaxis.com/invest/ratio/$upper/Current-Valuation',
    'Simply Wall St Valuation':
        'https://simplywall.st/stocks/us/media/nasdaq-$lower/alphabet/valuation',
    'GuruFocus Valuation': 'https://www.gurufocus.com/stock/$upper/dcf',
  };
}

Map<String, String> buildMarginOfSafetyLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Yahoo Finance Chart': 'https://finance.yahoo.com/chart/$upper',
    'MSN Money Chart':
        'https://www.msn.com/en-us/money/chart?id=$lower&timeFrame=3M&projection=false&chartType=candlestick',
  };
}
