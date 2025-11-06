from financial_metric import FinancialMetric


class PriceForecastPE(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastPE",
            0,
            "Price forecast based on P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        # Use forward EPS and target P/E for forecast
        # =(8,5+2*(POWER(C2; 1/10)-1)*100)*E2/P2
        growth = stock_details.profit_growth_10_years.value + 1
        price = stock_details.current_price.value
        pe = stock_details.pe.value

        if growth <= 0 or pe <= 0:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid growth ({growth}) or P/E ({pe}) value"
            return

        self.value = (8.5 + 2 * (pow(growth, 1/10) - 1) * 100) * price / pe

        self.data_quality = stock_details.current_price.data_quality * stock_details.profit_growth_10_years.data_quality * stock_details.pe.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
