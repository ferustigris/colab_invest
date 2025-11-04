from financial_metric import FinancialMetric


class PriceForecastPE(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastPE",
            0,
            "Price forecast based on P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for price forecast P/E metric for ticker {stock_details.ticker}")
        # Use forward EPS and target P/E for forecast
        if 'forwardEps' in yahoo_data and 'forwardPE' in yahoo_data:
            self.value = yahoo_data['forwardEps'] * yahoo_data['forwardPE']
            self.data_quality = 0.6  # Good quality analyst estimates
            self.last_update = int(time.time())
            print(f"PriceForecastPE metric loaded successfully: value={self.value}, quality={self.data_quality}")
        elif 'targetMeanPrice' in yahoo_data:
            self.value = yahoo_data['targetMeanPrice']
            self.data_quality = 0.6  # High quality analyst targets
            self.last_update = int(time.time())
            print(f"PriceForecastPE metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"forwardEps, forwardPE or targetMeanPrice data not available for {stock_details.ticker}")
            self.data_quality = 0.0