from financial_metric import FinancialMetric


class Revenue(FinancialMetric):
    def __init__(self):
        super().__init__(
            "revenue",
            0,
            "Total revenue for the last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )