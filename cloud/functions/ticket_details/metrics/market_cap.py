from financial_metric import FinancialMetric


class MarketCap(FinancialMetric):
    def __init__(self):
        super().__init__(
            "marketCap",
            0,
            "Total market capitalization based on current share price",
            0,
            "1970-01-01T00:00:00Z"
        )