from financial_metric import FinancialMetric


class Dividend(FinancialMetric):
    def __init__(self):
        super().__init__(
            "dividend",
            0,
            "Annual dividend per share",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for dividend metric for ticker {stock_details.ticker}")
        if 'dividendRate' in yahoo_data:
            self.value = yahoo_data['dividendRate']
            self.data_quality = 0.6  # Good quality dividend data
            self.last_update = int(time.time())
            print(f"Dividend metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"dividendRate data not available for {stock_details.ticker}")
            self.data_quality = 0.0