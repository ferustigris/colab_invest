from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class Revenue(FinancialMetric):
    def __init__(self):
        super().__init__(
            "revenue",
            0,
            "Total revenue for the last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for revenue metric for ticker {stock_details.ticker}")
        
        if not 'totalRevenue' in yahoo_data:
            print(f"totalRevenue data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - totalRevenue data not available"
            return

        now = datetime.now()
    
        try:
            yahoo_data_last_update_dt = datetime.strptime(yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - yahoo_data_last_update_dt).days // 7 + 1)
            print(f"Successfully calculated data quality for revenue: {self.data_quality}")
        except ValueError:
            print(f"Invalid last update format for revenue metric: {yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += " - invalid last update format"
            return

        self.comment += " - last update on " + yahoo_data['lastUpdate']
        self.value = yahoo_data['totalRevenue']
        self.last_update = yahoo_data['lastUpdate']
        print(f"Revenue metric loaded successfully: value={self.value}, quality={self.data_quality}")