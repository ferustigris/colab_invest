from financial_metric import FinancialMetric


class BuybackPercent(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buybackPercent",
            0,
            "Percentage of shares bought back relative to outstanding shares",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for buyback percent metric for ticker {stock_details.ticker}")
        # Use sharesPercentSharesOut if available (short interest proxy)
        if 'sharesPercentSharesOut' in yahoo_data:
            self.value = yahoo_data['sharesPercentSharesOut'] * 100  # Convert to percentage
            self.data_quality = 0.3  # Low quality - using short interest as proxy
            self.last_update = int(time.time())
            print(f"BuybackPercent metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"sharesPercentSharesOut data not available for {stock_details.ticker}")
            self.data_quality = 0.0