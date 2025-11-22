from financial_metric import FinancialMetric


class BuybackPercent(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buybackPercent",
            0,
            "Percentage of shares bought back relative to capitalization",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        buyback = stock_details.buyback.value
        shares_outstanding = stock_details.shares.value
        price = stock_details.current_price.value

        if buyback is None or shares_outstanding is None or price is None:
            print(f"Missing data for {self.name}: buyback={buyback}, shares={shares_outstanding}, price={price}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Missing buyback ({buyback}), shares ({shares_outstanding}), or price ({price})"
            return

        try:
            self.value = buyback / (shares_outstanding * price)
            self.data_quality = stock_details.buyback.data_quality * stock_details.shares.data_quality
        except ZeroDivisionError:
            print(f"Shares outstanding is zero for ticker {stock_details.ticker}, cannot compute {self.name}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += "\n - shares outstanding is zero, cannot compute metric"
            return

        self.data_quality = stock_details.buyback.data_quality * stock_details.shares.data_quality * stock_details.current_price.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        print(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
