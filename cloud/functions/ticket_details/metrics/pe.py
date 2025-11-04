from financial_metric import FinancialMetric


class Pe(FinancialMetric):
    def __init__(self):
        super().__init__(
            "pe",
            0,
            "Price-to-earnings ratio based on trailing twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )