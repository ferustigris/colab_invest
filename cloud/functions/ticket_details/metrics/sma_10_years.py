from financial_metric import FinancialMetric


class Sma10Years(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sma10Years",
            0,
            "10-year simple moving average indicating long-term trend",
            0,
            "1970-01-01T00:00:00Z"
        )