from financial_metric import FinancialMetric


class DividendYield(FinancialMetric):
    def __init__(self):
        super().__init__(
            "dividendYield",
            0,
            "Dividend yield as percentage of current stock price",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for dividend yield metric for ticker {stock_details.ticker}")
        if 'dividendYield' in yahoo_data:
            self.value = yahoo_data['dividendYield'] * 100  # Convert to percentage
            self.data_quality = 0.6  # Good quality calculated yield
            self.last_update = int(time.time())
            print(f"DividendYield metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"dividendYield data not available for {stock_details.ticker}")
            self.data_quality = 0.0