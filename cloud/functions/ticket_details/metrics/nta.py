from financial_metric import FinancialMetric


class Nta(FinancialMetric):
    def __init__(self):
        super().__init__(
            "nta",
            0,
            "Net tangible assets value",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for net tangible assets metric for ticker {stock_details.ticker}")
        # Calculate as book value * shares outstanding (approximation)
        if 'bookValue' in yahoo_data and 'sharesOutstanding' in yahoo_data:
            self.value = yahoo_data['bookValue'] * yahoo_data['sharesOutstanding']
            self.data_quality = 0.6  # Moderate quality approximation
            self.last_update = int(time.time())
            print(f"Nta metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"bookValue or sharesOutstanding data not available for {stock_details.ticker}")
            self.data_quality = 0.0