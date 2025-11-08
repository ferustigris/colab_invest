import 'package:flutter/foundation.dart';

class Ticket {
  final String ticker; // ticker
  final String name; // name
  final String? currency; // currency
  final String? summary; // brief company description
  final double? profitGrowth10Years; // profit growth over last 10 years
  final double? currentPrice; // price
  final double? shares; // number of shares, billions
  final double? sma10Years; // SMA 10 years
  final double? priceForecastDiv; // Price forecast DIV based
  final double? priceForecastPE; // Price forecast PE based
  final double? priceForecastFPE; // Price forecast FPE based
  final double? priceForecastEquity; // Price forecast equity based
  final double? priceForecastDivBuyback; // Price forecast DivBuyback based
  final double? marketCap; // Market capitalization, billions
  final double? revenue; // Revenue, billions
  final double? netIncome; // Net profit, net inc, billions
  final double? ebitda; // EBITDA, billions
  final double? nta; // NTA, billions
  final double? pe; // P/E
  final double? ps; // P/S
  final double? evEbitda; // EV/EBITDA
  final double? totalDebt; // Total Debt, billions
  final double? debtEbitda; // Debt/EBITDA
  final double? cash; // Cash, B
  final double? dividend; // Div, %
  final double? peRatio; // PE
  final double? fpe; // FPE
  final double? freeCashFlow; // free Cash flow
  final double? buyback; // buyback
  final double? buybackPercent; // buyback, %
  final double? freeCashFlowPerStock; // free Cash flow per stock

  // Metadata maps for comments and quality scores
  final Map<String, String> comments;
  final Map<String, double> dataQuality;
  final Map<String, DateTime?> lastUpdates;

  Ticket({
    required this.ticker,
    required this.name,
    this.currency,
    this.summary,
    this.profitGrowth10Years,
    this.currentPrice,
    this.shares,
    this.sma10Years,
    this.priceForecastDiv,
    this.priceForecastPE,
    this.priceForecastEquity,
    this.priceForecastDivBuyback,
    this.marketCap,
    this.revenue,
    this.netIncome,
    this.ebitda,
    this.nta,
    this.pe,
    this.ps,
    this.evEbitda,
    this.totalDebt,
    this.debtEbitda,
    this.cash,
    this.dividend,
    this.peRatio,
    this.fpe,
    this.priceForecastFPE,
    this.freeCashFlow,
    this.buyback,
    this.buybackPercent,
    this.freeCashFlowPerStock,
    this.comments = const {},
    this.dataQuality = const {},
    this.lastUpdates = const {},
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing JSON for ticket: ${json['ticker']} - ${json['name']}');
    final comments = <String, String>{};
    final dataQuality = <String, double>{};
    final lastUpdates = <String, DateTime?>{};

    final ticket = Ticket(
      ticker: _parseStringValue(json['ticker']) ?? '',
      name: _parseStringValue(json['name']) ?? '',
      summary: _parseStringValue(json['summary']),
      currency: _parseStringValue(json['currency']),
      profitGrowth10Years: _parseMetricValue(
        json['profitGrowth10Years'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      currentPrice: _parseMetricValue(
        json['currentPrice'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      shares: _parseMetricValue(
        json['shares'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      sma10Years: _parseMetricValue(
        json['sma10Years'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      priceForecastDiv: _parseMetricValue(
        json['priceForecastDiv'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      priceForecastPE: _parseMetricValue(
        json['priceForecastPE'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      priceForecastEquity: _parseMetricValue(
        json['priceForecastEquity'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      priceForecastDivBuyback: _parseMetricValue(
        json['priceForecastDivBuyback'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      priceForecastFPE: _parseMetricValue(
        json['priceForecastFPE'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      marketCap: _parseMetricValue(
        json['marketCap'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      revenue: _parseMetricValue(
        json['revenue'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      netIncome: _parseMetricValue(
        json['netIncome'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      ebitda: _parseMetricValue(
        json['ebitda'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      nta: _parseMetricValue(json['nta'], comments, dataQuality, lastUpdates),
      pe: _parseMetricValue(json['pe'], comments, dataQuality, lastUpdates),
      ps: _parseMetricValue(json['ps'], comments, dataQuality, lastUpdates),
      evEbitda: _parseMetricValue(
        json['evEbitda'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      totalDebt: _parseMetricValue(
        json['totalDebt'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      debtEbitda: _parseMetricValue(
        json['debtEbitda'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      cash: _parseMetricValue(json['cash'], comments, dataQuality, lastUpdates),
      dividend: _parseMetricValue(
        json['dividend'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      peRatio: _parseMetricValue(
        json['peRatio'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      fpe: _parseMetricValue(json['fpe'], comments, dataQuality, lastUpdates),
      freeCashFlow: _parseMetricValue(
        json['freeCashFlow'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      buyback: _parseMetricValue(
        json['buyback'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      buybackPercent: _parseMetricValue(
        json['buybackPercent'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      freeCashFlowPerStock: _parseMetricValue(
        json['freeCashFlowPerStock'],
        comments,
        dataQuality,
        lastUpdates,
      ),
      comments: comments,
      dataQuality: dataQuality,
      lastUpdates: lastUpdates,
    );

    debugPrint(
      'Created ticket: ${ticket.ticker} - ${ticket.name}, price: ${ticket.currentPrice}',
    );
    return ticket;
  }

  static double? _parseMetricValue(
    dynamic metricData,
    Map<String, String> comments,
    Map<String, double> dataQuality,
    Map<String, DateTime?> lastUpdates,
  ) {
    if (metricData == null) return null;

    // Handle new format with metric object
    if (metricData is Map<String, dynamic>) {
      final name = _parseStringValue(metricData['name']);
      if (name != null) {
        comments[name] = _parseStringValue(metricData['comment']) ?? '';
        dataQuality[name] = _parseDouble(metricData['dataQuality']) ?? 0.0;

        final lastUpdateStr = _parseStringValue(metricData['lastUpdate']);
        if (lastUpdateStr != null && lastUpdateStr != '1970-01-01T00:00:00Z') {
          lastUpdates[name] = DateTime.tryParse(lastUpdateStr);
        }
      }

      return _parseDouble(metricData['value']);
    }

    // Handle old format - direct value
    return _parseDouble(metricData);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static String? _parseStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    // Helper function to create metric object with metadata
    dynamic createMetricObject(String fieldName, dynamic value) {
      if (value == null) return null;

      final comment = comments[fieldName];
      final quality = dataQuality[fieldName];
      final lastUpdate = lastUpdates[fieldName];

      // If no metadata exists, return simple value
      if (comment == null && quality == null && lastUpdate == null) {
        return value;
      }

      // Return object with metadata
      final result = <String, dynamic>{'name': fieldName, 'value': value};

      if (comment != null) result['comment'] = comment;
      if (quality != null) result['dataQuality'] = quality;
      if (lastUpdate != null) {
        result['lastUpdate'] = lastUpdate.toIso8601String();
      }

      return result;
    }

    return {
      'ticker': ticker,
      'name': name,
      'summary': summary,
      'profitGrowth10Years': createMetricObject(
        'profitGrowth10Years',
        profitGrowth10Years,
      ),
      'currentPrice': createMetricObject('currentPrice', currentPrice),
      'shares': createMetricObject('shares', shares),
      'sma10Years': createMetricObject('sma10Years', sma10Years),
      'priceForecastDiv': createMetricObject(
        'priceForecastDiv',
        priceForecastDiv,
      ),
      'priceForecastPE': createMetricObject('priceForecastPE', priceForecastPE),
      'priceForecastEquity': createMetricObject(
        'priceForecastEquity',
        priceForecastEquity,
      ),
      'priceForecastDivBuyback': createMetricObject(
        'priceForecastDivBuyback',
        priceForecastDivBuyback,
      ),
      'priceForecastFPE': createMetricObject(
        'priceForecastFPE',
        priceForecastFPE,
      ),
      'marketCap': createMetricObject('marketCap', marketCap),
      'revenue': createMetricObject('revenue', revenue),
      'netIncome': createMetricObject('netIncome', netIncome),
      'ebitda': createMetricObject('ebitda', ebitda),
      'nta': createMetricObject('nta', nta),
      'pe': createMetricObject('pe', pe),
      'ps': createMetricObject('ps', ps),
      'evEbitda': createMetricObject('evEbitda', evEbitda),
      'totalDebt': createMetricObject('totalDebt', totalDebt),
      'debtEbitda': createMetricObject('debtEbitda', debtEbitda),
      'cash': createMetricObject('cash', cash),
      'dividend': createMetricObject('dividend', dividend),
      'peRatio': createMetricObject('peRatio', peRatio),
      'fpe': createMetricObject('fpe', fpe),
      'freeCashFlow': createMetricObject('freeCashFlow', freeCashFlow),
      'buyback': createMetricObject('buyback', buyback),
      'buybackPercent': createMetricObject('buybackPercent', buybackPercent),
      'freeCashFlowPerStock': createMetricObject(
        'freeCashFlowPerStock',
        freeCashFlowPerStock,
      ),
    };
  }

  // Helper methods to get metadata for specific metrics
  String getComment(String metricName) => comments[metricName] ?? '';
  double getDataQuality(String metricName) => dataQuality[metricName] ?? 0.0;
  DateTime? getLastUpdate(String metricName) => lastUpdates[metricName];
}
