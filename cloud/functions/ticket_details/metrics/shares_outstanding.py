from financial_metric import FinancialMetric


class SharesOutstanding(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sharesOutstanding",
            0,
            "Total number of shares currently outstanding",
            0,
            "1970-01-01T00:00:00Z"
        )