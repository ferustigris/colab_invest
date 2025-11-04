from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class CurrentPrice(FinancialMetric):
    def __init__(self):
        super().__init__(
            "currentPrice",
            0,
            "Real-time market price as of latest trading session",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for currentPrice metric for ticker {stock_details.ticker}")
        
        if not 'currentPrice' in yahoo_data:
            print(f"currentPrice data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - currentPrice data not available"
            return

        now = datetime.now()
    
        try:
            yahoo_data_last_update_dt = datetime.strptime(yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - yahoo_data_last_update_dt).days // 1 + 1)
            print(f"Successfully calculated data quality for currentPrice: {self.data_quality}")
        except ValueError:
            print(f"Invalid last update format for currentPrice metric: {yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += " - invalid last update format"
            return

        self.comment += " - last update on " + yahoo_data['lastUpdate']
        self.value = yahoo_data['currentPrice']
        self.last_update = yahoo_data['lastUpdate']
        print(f"CurrentPrice metric loaded successfully: value={self.value}, quality={self.data_quality}")
