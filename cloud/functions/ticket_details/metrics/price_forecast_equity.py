from financial_metric import FinancialMetric


class PriceForecastEquity(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastEquity",
            0,
            "Price forecast based on equity valuation model",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        nta = stock_details.nta.value
        shares_outstanding = stock_details.shares.value

        self.value = nta / shares_outstanding

        self.data_quality = stock_details.nta.data_quality * stock_details.shares.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
