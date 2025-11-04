from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class SharesOutstanding(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sharesOutstanding",
            0,
            "Total number of shares currently outstanding",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for sharesOutstanding metric for ticker {stock_details.ticker}")
        
        if not 'sharesOutstanding' in yahoo_data:
            print(f"sharesOutstanding data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - sharesOutstanding data not available"
            return

        now = datetime.now()
    
        try:
            yahoo_data_last_update_dt = datetime.strptime(yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - yahoo_data_last_update_dt).days // 7 + 1)
            print(f"Successfully calculated data quality for sharesOutstanding: {self.data_quality}")
        except ValueError:
            print(f"Invalid last update format for sharesOutstanding metric: {yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += " - invalid last update format"
            return

        self.comment += " - last update on " + yahoo_data['lastUpdate']
        self.value = yahoo_data['sharesOutstanding']
        self.last_update = yahoo_data['lastUpdate']
        print(f"SharesOutstanding metric loaded successfully: value={self.value}, quality={self.data_quality}")