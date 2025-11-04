from financial_metric import FinancialMetric


class ProfitGrowth10Years(FinancialMetric):
    def __init__(self):
        super().__init__(
            "profitGrowth10Years",
            0,
            "Strong consistent growth over the past decade",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for profitGrowth10Years metric for ticker {stock_details.ticker}")
        
        # Calculate profit growth from earnings growth if available
        if 'earningsGrowth' in yahoo_data:
            self.value = yahoo_data['earningsGrowth'] * 100  # Convert to percentage
            self.data_quality = 0.6  # Moderate quality as it's quarterly growth extrapolated
            self.last_update = int(time.time())
            print(f"ProfitGrowth10Years metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"earningsGrowth data not available for {stock_details.ticker}")
            self.data_quality = 0.0  # No data available