from financial_metric import FinancialMetric
from datetime import datetime, timedelta


class SharesImpliedCalculated(FinancialMetric):
    def __init__(self):
        super().__init__(
            "sharesImplied",
            0,
            "Total number of shares implied by the current stock price and market capitalization",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")

        if not 'currentPrice' in yahoo_data:
            print(f"currentPrice data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - currentPrice data not available"
            return
        if not 'marketCap' in yahoo_data:
            print(f"marketCap data not available for {stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - marketCap data not available"
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
        self.value = yahoo_data['marketCap'] / yahoo_data['currentPrice']
        self.last_update = yahoo_data['lastUpdate']
        print(f"CalculatedimpliedSharesOutstanding metric loaded successfully: value={self.value}, quality={self.data_quality}")