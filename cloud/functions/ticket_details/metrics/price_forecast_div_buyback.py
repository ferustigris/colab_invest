from financial_metric import FinancialMetric


class PriceForecastDivBuyback(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastDivBuyback",
            0,
            "Price forecast based on dividend discount model with buyback consideration",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        # Use current price, dividend and buyback for forecast
        # =2/3*E2*(V2+buyback)/(1-1/(1+Trands!$D$3))
        price = stock_details.current_price.value
        div = stock_details.dividend.value
        buyback_percent = stock_details.buyback_percent.value

        print(f"Calculating {self.name} with price={price}, dividend={div}, buyback_percent={buyback_percent}")
            
        self.value = 2.0/3 * price * (div + buyback_percent) / (1 - 1/(1 + 0.026))

        self.data_quality = stock_details.current_price.data_quality * stock_details.dividend.data_quality * stock_details.buyback_percent.data_quality
        self.comment += f"\n - price: {price:.2f}, dividend: {div:.2f}, buyback: {buyback_percent:.2f}"
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"