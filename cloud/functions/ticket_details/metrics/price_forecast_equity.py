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
        import time
        print(f"Loading data for price forecast equity metric for ticker {stock_details.ticker}")
        # Use book value and P/B ratio for equity-based valuation
        if 'bookValue' in yahoo_data and 'priceToBook' in yahoo_data:
            self.value = yahoo_data['bookValue'] * yahoo_data['priceToBook']
            self.data_quality = 0.6  # Moderate quality book value based
            self.last_update = int(time.time())
            print(f"PriceForecastEquity metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"bookValue or priceToBook data not available for {stock_details.ticker}")
            self.data_quality = 0.0