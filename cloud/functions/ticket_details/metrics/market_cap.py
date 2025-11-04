from financial_metric import FinancialMetric


class MarketCap(FinancialMetric):
    def __init__(self):
        super().__init__(
            "marketCap",
            0,
            "Total market capitalization based on current share price",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for marketCap metric for ticker {stock_details.ticker}")
        
        if 'marketCap' in yahoo_data:
            self.value = yahoo_data['marketCap']
            self.data_quality = 0.6  # High quality calculated value
            self.last_update = int(time.time())
            print(f"MarketCap metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"marketCap data not available for {stock_details.ticker}")
            self.data_quality = 0.0