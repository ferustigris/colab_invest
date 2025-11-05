from financial_metric import FinancialMetric


class EvEbitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "evEbitda",
            0,
            "Enterprise value to EBITDA ratio",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for EV/EBITDA metric for ticker {stock_details.ticker}")
        if 'enterpriseToEbitda' in yahoo_data:
            self.value = yahoo_data['enterpriseToEbitda']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            print(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"enterpriseToEbitda data not available for {stock_details.ticker}")
            self.data_quality = 0.0