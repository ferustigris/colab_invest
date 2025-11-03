class Ticket {
  final String ticker; // тикет
  final String name; // название
  final double? profitGrowth10Years; // рост прибыли за последние 10 лет
  final double? currentPrice; // цена
  final double? sharesOutstanding; // кол-во акций, млрд
  final double? sma10Years; // SMA 10 years
  final double? priceForecastDiv; // Price forecast DIV based
  final double? priceForecastPE; // Price forecast PE based
  final double? priceForecastEquity; // Price forecast equity based
  final double? marketCap; // Капитализация на бирже, млрд
  final double? revenue; // Выручка, revenue, млрд
  final double? netIncome; // Чистая прибыль, net inc, млрд
  final double? ebitda; // EBITDA, млрд
  final double? nta; // NTA, млрд
  final double? pe; // P/E
  final double? ps; // P/S
  final double? evEbitda; // EV/EBITDA
  final double? totalDebt; // Total Debt, млрд
  final double? debtEbitda; // Debt/EBITDA
  final double? cash; // Cash, B
  final double? dividendYield; // Div, %
  final double? peRatio; // PE
  final double? fpe; // FPE
  final double? freeCashFlow; // free Cash flow
  final double? buyback; // buyback
  final double? buybackPercent; // buyback, %
  final double? freeCashFlowPerStock; // free Cash flow per stock

  Ticket({
    required this.ticker,
    required this.name,
    this.profitGrowth10Years,
    this.currentPrice,
    this.sharesOutstanding,
    this.sma10Years,
    this.priceForecastDiv,
    this.priceForecastPE,
    this.priceForecastEquity,
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
    this.dividendYield,
    this.peRatio,
    this.fpe,
    this.freeCashFlow,
    this.buyback,
    this.buybackPercent,
    this.freeCashFlowPerStock,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticker: json['ticker'] ?? '',
      name: json['name'] ?? '',
      profitGrowth10Years: _parseDouble(json['profitGrowth10Years']),
      currentPrice: _parseDouble(json['currentPrice']),
      sharesOutstanding: _parseDouble(json['sharesOutstanding']),
      sma10Years: _parseDouble(json['sma10Years']),
      priceForecastDiv: _parseDouble(json['priceForecastDiv']),
      priceForecastPE: _parseDouble(json['priceForecastPE']),
      priceForecastEquity: _parseDouble(json['priceForecastEquity']),
      marketCap: _parseDouble(json['marketCap']),
      revenue: _parseDouble(json['revenue']),
      netIncome: _parseDouble(json['netIncome']),
      ebitda: _parseDouble(json['ebitda']),
      nta: _parseDouble(json['nta']),
      pe: _parseDouble(json['pe']),
      ps: _parseDouble(json['ps']),
      evEbitda: _parseDouble(json['evEbitda']),
      totalDebt: _parseDouble(json['totalDebt']),
      debtEbitda: _parseDouble(json['debtEbitda']),
      cash: _parseDouble(json['cash']),
      dividendYield: _parseDouble(json['dividendYield']),
      peRatio: _parseDouble(json['peRatio']),
      fpe: _parseDouble(json['fpe']),
      freeCashFlow: _parseDouble(json['freeCashFlow']),
      buyback: _parseDouble(json['buyback']),
      buybackPercent: _parseDouble(json['buybackPercent']),
      freeCashFlowPerStock: _parseDouble(json['freeCashFlowPerStock']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'profitGrowth10Years': profitGrowth10Years,
      'currentPrice': currentPrice,
      'sharesOutstanding': sharesOutstanding,
      'sma10Years': sma10Years,
      'priceForecastDiv': priceForecastDiv,
      'priceForecastPE': priceForecastPE,
      'priceForecastEquity': priceForecastEquity,
      'marketCap': marketCap,
      'revenue': revenue,
      'netIncome': netIncome,
      'ebitda': ebitda,
      'nta': nta,
      'pe': pe,
      'ps': ps,
      'evEbitda': evEbitda,
      'totalDebt': totalDebt,
      'debtEbitda': debtEbitda,
      'cash': cash,
      'dividendYield': dividendYield,
      'peRatio': peRatio,
      'fpe': fpe,
      'freeCashFlow': freeCashFlow,
      'buyback': buyback,
      'buybackPercent': buybackPercent,
      'freeCashFlowPerStock': freeCashFlowPerStock,
    };
  }
}
