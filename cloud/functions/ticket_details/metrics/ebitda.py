from financial_metric import FinancialMetric


class Ebitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "ebitda",
            0,
            "Earnings before interest, taxes, depreciation, and amortization",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for EBITDA metric for ticker {stock_details.ticker}")
        if 'ebitda' in yahoo_data:
            self.value = yahoo_data['ebitda']
            self.data_quality = 0.6  # Good quality financial statement data
            self.last_update = int(time.time())
            print(f"Ebitda metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"ebitda data not available for {stock_details.ticker}")
            self.data_quality = 0.0