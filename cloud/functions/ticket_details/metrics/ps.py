from financial_metric import FinancialMetric


class Ps(FinancialMetric):
    def __init__(self):
        super().__init__(
            "ps",
            0,
            "Price-to-sales ratio",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for price-to-sales metric for ticker {stock_details.ticker}")
        if 'priceToSalesTrailing12Months' in yahoo_data:
            self.value = yahoo_data['priceToSalesTrailing12Months']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            print(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"priceToSalesTrailing12Months data not available for {stock_details.ticker}")
            self.data_quality = 0.0