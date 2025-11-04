from financial_metric import FinancialMetric


class Sma10Years(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sma10Years",
            0,
            "10-year simple moving average indicating long-term trend",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for 10-year SMA metric for ticker {stock_details.ticker}")
        # Use 200-day average as proxy for long-term trend
        if 'twoHundredDayAverage' in yahoo_data:
            self.value = yahoo_data['twoHundredDayAverage']
            self.data_quality = 0.6  # Moderate quality - 200 day vs 10 year approximation
            self.last_update = int(time.time())
            print(f"Sma10Years metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"twoHundredDayAverage data not available for {stock_details.ticker}")
            self.data_quality = 0.0