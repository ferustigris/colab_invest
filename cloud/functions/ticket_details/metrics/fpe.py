from financial_metric import FinancialMetric


class Fpe(FinancialMetric):
    def __init__(self):
        super().__init__(
            "fpe",
            0,
            "Forward price-to-earnings ratio based on next year estimates",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for forward P/E metric for ticker {stock_details.ticker}")
        if 'forwardPE' in yahoo_data:
            self.value = yahoo_data['forwardPE']
            self.data_quality = 0.6  # Good quality analyst estimates
            self.last_update = int(time.time())
            print(f"Fpe metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"forwardPE data not available for {stock_details.ticker}")
            self.data_quality = 0.0