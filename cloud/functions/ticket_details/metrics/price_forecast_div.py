from financial_metric import FinancialMetric


class PriceForecastDiv(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastDiv",
            0,
            "Price forecast based on dividend discount model",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        # Use current price and dividend for forecast
        # =2/3*E2*V2/(1-1/(1+Trands!$D$3))
        price = stock_details.current_price.value
        div = stock_details.dividend.value
        self.value = 2/3 * price * div / (1 - 1/(1 + 0.026))
        self.data_quality = stock_details.current_price.data_quality * stock_details.dividend.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
