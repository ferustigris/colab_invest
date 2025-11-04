from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class NetIncome(FinancialMetric):
    def __init__(self):
        super().__init__(
            "netIncome",
            0,
            "Net income after all expenses and taxes",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for netIncome metric for ticker {stock_details.ticker}")
        
        if not 'netIncomeToCommon' in yahoo_data:
            print(f"netIncomeToCommon data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - netIncomeToCommon data not available"
            return

        now = datetime.now()
    
        try:
            yahoo_data_last_update_dt = datetime.strptime(yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1/((now - yahoo_data_last_update_dt + timedelta(seconds=1)) / timedelta(days=7))
            print(f"Successfully calculated data quality for netIncome: {self.data_quality}")
        except ValueError:
            print(f"Invalid last update format for netIncome metric: {yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += " - invalid last update format"
            return

        self.comment += " - last update on " + yahoo_data['lastUpdate']
        self.value = yahoo_data['netIncomeToCommon']
        self.data_quality = 0.8
        self.last_update = yahoo_data['lastUpdate']
        print(f"NetIncome metric loaded successfully: value={self.value}, quality={self.data_quality}")