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
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for pe metric for ticker {stock_details.ticker}")
        
        if 'trailingPE' in yahoo_data:
            self.value = yahoo_data['trailingPE']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            print(f"PE metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"trailingPE data not available for {stock_details.ticker}")
            self.data_quality = 0.0