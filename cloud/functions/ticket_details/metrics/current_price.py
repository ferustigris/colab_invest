from financial_metric import FinancialMetric


class CurrentPrice(FinancialMetric):
    def __init__(self):
        super().__init__(
            "currentPrice",
            0,
            "Real-time market price as of latest trading session",
            0,
            "1970-01-01T00:00:00Z"
        )