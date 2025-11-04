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