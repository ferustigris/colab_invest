from financial_metric import FinancialMetric


class ProfitGrowth10Years(FinancialMetric):
    def __init__(self):
        super().__init__(
            "profitGrowth10Years",
            0,
            "Strong consistent growth over the past decade",
            0,
            "1970-01-01T00:00:00Z"
        )


class CurrentPrice(FinancialMetric):
    def __init__(self):
        super().__init__(
            "currentPrice",
            0,
            "Real-time market price as of latest trading session",
            0,
            "1970-01-01T00:00:00Z"
        )


class SharesOutstanding(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sharesOutstanding",
            0,
            "Total number of shares currently outstanding",
            0,
            "1970-01-01T00:00:00Z"
        )


class Sma10Years(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sma10Years",
            0,
            "10-year simple moving average indicating long-term trend",
            0,
            "1970-01-01T00:00:00Z"
        )


class PriceForecastDiv(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastDiv",
            0,
            "Price forecast based on dividend discount model",
            0,
            "1970-01-01T00:00:00Z"
        )


class PriceForecastPE(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastPE",
            0,
            "Price forecast based on P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        )


class PriceForecastEquity(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastEquity",
            0,
            "Price forecast based on equity valuation model",
            0,
            "1970-01-01T00:00:00Z"
        )


class MarketCap(FinancialMetric):
    def __init__(self):
        super().__init__(
            "marketCap",
            0,
            "Total market capitalization based on current share price",
            0,
            "1970-01-01T00:00:00Z"
        )


class Revenue(FinancialMetric):
    def __init__(self):
        super().__init__(
            "revenue",
            0,
            "Total revenue for the last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )


class NetIncome(FinancialMetric):
    def __init__(self):
        super().__init__(
            "netIncome",
            0,
            "Net income after all expenses and taxes",
            0,
            "1970-01-01T00:00:00Z"
        )


class Ebitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "ebitda",
            0,
            "Earnings before interest, taxes, depreciation, and amortization",
            0,
            "1970-01-01T00:00:00Z"
        )


class Nta(FinancialMetric):
    def __init__(self):
        super().__init__(
            "nta",
            0,
            "Net tangible assets value",
            0,
            "1970-01-01T00:00:00Z"
        )


class Pe(FinancialMetric):
    def __init__(self):
        super().__init__(
            "pe",
            0,
            "Price-to-earnings ratio based on trailing twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )


class Fpe(FinancialMetric):
    def __init__(self):
        super().__init__(
            "fpe",
            0,
            "Forward price-to-earnings ratio based on next year estimates",
            0,
            "1970-01-01T00:00:00Z"
        )


class Ps(FinancialMetric):
    def __init__(self):
        super().__init__(
            "ps",
            0,
            "Price-to-sales ratio",
            0,
            "1970-01-01T00:00:00Z"
        )


class EvEbitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "evEbitda",
            0,
            "Enterprise value to EBITDA ratio",
            0,
            "1970-01-01T00:00:00Z"
        )


class TotalDebt(FinancialMetric):
    def __init__(self):
        super().__init__(
            "totalDebt",
            0,
            "Total debt including short-term and long-term obligations",
            0,
            "1970-01-01T00:00:00Z"
        )


class DebtEbitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "debtEbitda",
            0,
            "Debt-to-EBITDA ratio indicating leverage",
            0,
            "1970-01-01T00:00:00Z"
        )


class Cash(FinancialMetric):
    def __init__(self):
        super().__init__(
            "cash",
            0,
            "Cash and cash equivalents on balance sheet",
            0,
            "1970-01-01T00:00:00Z"
        )


class Dividend(FinancialMetric):
    def __init__(self):
        super().__init__(
            "dividend",
            0,
            "Annual dividend per share",
            0,
            "1970-01-01T00:00:00Z"
        )


class DividendYield(FinancialMetric):
    def __init__(self):
        super().__init__(
            "dividendYield",
            0,
            "Dividend yield as percentage of current stock price",
            0,
            "1970-01-01T00:00:00Z"
        )


class FreeCashFlow(FinancialMetric):
    def __init__(self):
        super().__init__(
            "freeCashFlow",
            0,
            "Free cash flow available after capital expenditures",
            0,
            "1970-01-01T00:00:00Z"
        )


class Buyback(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buyback",
            0,
            "Total amount spent on share buybacks in last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )


class BuybackPercent(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buybackPercent",
            0,
            "Percentage of shares bought back relative to outstanding shares",
            0,
            "1970-01-01T00:00:00Z"
        )


class FreeCashFlowPerStock(FinancialMetric):
    def __init__(self):
        super().__init__(
            "freeCashFlowPerStock",
            0,
            "Free cash flow divided by shares outstanding",
            0,
            "1970-01-01T00:00:00Z"
        )