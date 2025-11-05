from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class TrailingAnnualDividendYield(FinancialMetric):
    def __init__(self):
        super().__init__(
            "trailingAnnualDividendYield",
            0,
            "Dividend yield as percentage of current stock price",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")

        if not yahoo_data.get('trailingAnnualDividendYield'):
            print(f"trailingAnnualDividendYield data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - trailingAnnualDividendYield data not available"
            return

        now = datetime.now()
    
        try:
            yahoo_data_last_update_dt = datetime.strptime(yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - yahoo_data_last_update_dt).days // 7 + 1)
            print(f"Successfully calculated data quality for {self.name}: {self.data_quality}")
        except ValueError:
            print(f"Invalid last update format for {self.name} metric: {yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += "\n - invalid last update format"
            return

        self.comment += "\n - last update on " + yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.value = yahoo_data['trailingAnnualDividendYield']
        self.last_update = yahoo_data['lastUpdate']
        print(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")