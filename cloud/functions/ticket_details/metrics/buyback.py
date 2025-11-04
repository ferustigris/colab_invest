from financial_metric import FinancialMetric


class Buyback(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buyback",
            0,
            "Total amount spent on share buybacks in last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for buyback metric for ticker {stock_details.ticker}")
        
        # Estimate from operating cash flow - free cash flow (approximation)
        if 'operatingCashflow' in yahoo_data and 'freeCashflow' in yahoo_data:
            # This is a rough approximation
            capex = yahoo_data['operatingCashflow'] - yahoo_data['freeCashflow']
            self.value = max(0, capex * 0.3)  # Assume 30% might go to buybacks
            self.data_quality = 0.3  # Low quality approximation
            self.last_update = int(time.time())
            print(f"Buyback metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"operatingCashflow or freeCashflow data not available for {stock_details.ticker}")
            self.data_quality = 0.0