from metrics.ai_metric import AiMetric


class ProfitGrowth10Years(AiMetric):
    def __init__(self):
        super().__init__(
            "AnnualProfitGrowth10Years",
            0,
            "Growth over the past decade (10 years) of net income (profit)",
            0,
            "1970-01-01T00:00:00Z"
        )
