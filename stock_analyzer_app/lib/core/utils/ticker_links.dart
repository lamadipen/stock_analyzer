/// Returns a map {sourceName : url} for the entered ticker.
Map<String, String> buildFinancialLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Seeking Alpha': 'https://seekingalpha.com/symbol/$upper/income-statement',
    'Stock Analysis Financials':
        'https://stockanalysis.com/stocks/$lower/financials/',
    'Stock Analysis Revenue':
        'https://stockanalysis.com/stocks/$lower/financials/revenue/',
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
  final String lower = ticker.toLowerCase();
  return {
    'Morningstar': 'https://www.morningstar.com/stocks/xnas/$upper/key-metrics',
    'ADVFN':
        'https://www.advfn.com/stock-market/NYSE/$upper/financials/stats-and-ratios',
    'Finviz': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Macrotrends':
        'https://www.macrotrends.net/stocks/charts/$upper/$lower/gross-profit',
  };
}

/// Debt & solvency deep-links
Map<String, String> buildDebtLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Finviz Debt': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Stock Analysis Ratios':
        'https://stockanalysis.com/stocks/$lower/financials/ratios/',
  };
}

Map<String, String> buildBusinessOverviewLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Stock Analysis Overview': 'https://stockanalysis.com/stocks/$lower/',
    'Stock Analysis Revenue':
        'https://stockanalysis.com/stocks/$lower/financials/revenue/',
    'Stock Analysis Forecast':
        'https://stockanalysis.com/stocks/$lower/forecast/',
    'SEC Filings': 'https://www.sec.gov/edgar/browse/?CIK=$upper',
    'Yahoo Finance Chart': 'https://finance.yahoo.com/chart/$upper',
    'Yahoo Analysis': 'https://finance.yahoo.com/quote/$upper/analysis/',
    'Finviz Snapshot': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Earnings Whispers EPS':
        'https://www.earningswhispers.com/epsdetails/$upper',
  };
}

Map<String, String> buildAnalystForecastLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Stock Analysis Forecast':
        'https://stockanalysis.com/stocks/$lower/forecast/',
    'Yahoo Analysis': 'https://finance.yahoo.com/quote/$upper/analysis/',
    'MarketBeat Forecast':
        'https://www.marketbeat.com/stocks/NASDAQ/$upper/forecast/',
    'Finviz Analyst Snapshot': 'https://finviz.com/quote.ashx?t=$upper&p=d',
  };
}

Map<String, String> buildCompanyFilingLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  return {
    'SEC Company Filings': 'https://www.sec.gov/edgar/browse/?CIK=$upper',
    'SEC Full Text Search':
        'https://www.sec.gov/edgar/search/#/q=$upper&dateRange=custom&category=form-cat1',
    'Company Investor Relations Search':
        'https://www.google.com/search?q=$upper+investor+relations',
  };
}

Map<String, String> buildRevenueLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Stock Analysis Revenue':
        'https://stockanalysis.com/stocks/$lower/financials/revenue/',
    'Macrotrends Revenue':
        'https://www.macrotrends.net/stocks/charts/$upper/$lower/revenue',
    'MarketWatch Financials':
        'https://www.marketwatch.com/investing/stock/$lower/financials?mod=mw_quote_tab',
  };
}

Map<String, String> buildChartAndSnapshotLinks(String ticker) {
  final String upper = ticker.toUpperCase();
  final String lower = ticker.toLowerCase();
  return {
    'Yahoo Finance Chart': 'https://finance.yahoo.com/chart/$upper',
    'Finviz Snapshot': 'https://finviz.com/quote.ashx?t=$upper&p=d',
    'Stock Analysis Chart': 'https://stockanalysis.com/stocks/$lower/chart/',
    'MarketWatch Chart':
        'https://www.marketwatch.com/investing/stock/$lower/charts?mod=mw_quote_tab',
  };
}

Map<String, String> buildTickerResourceHubLinks(String ticker) {
  return {
    ...buildBusinessOverviewLinks(ticker),
    ...buildFinancialLinks(ticker),
    ...buildAnalystForecastLinks(ticker),
    ...buildCompanyFilingLinks(ticker),
    ...buildChartAndSnapshotLinks(ticker),
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
