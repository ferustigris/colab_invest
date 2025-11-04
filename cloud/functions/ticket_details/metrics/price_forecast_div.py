from financial_metric import FinancialMetric


class PriceForecastDiv(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastDiv",
            0,
            "Price forecast based on dividend discount model",
            0,
            "1970-01-01T00:00:00Z"
        )