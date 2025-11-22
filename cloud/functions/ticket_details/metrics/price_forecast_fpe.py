from financial_metric import FinancialMetric


class PriceForecastFPE(FinancialMetric):
    def __init__(self):
        super().__init__(
            "priceForecastFPE",
            0,
            "Price forecast based on Forward P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        # Use forward EPS and target P/E for forecast
        # =(8,5+2*(POWER(C2; 1/10)-1)*100)*E2/P2
        # (8.5 + 2 * (pow(growth, 1/10) - 1) * 100) * price * fpe
        growth = stock_details.profit_growth_10_years.value
        price = stock_details.current_price.value
        fpe = stock_details.fpe.value

        if growth is None or fpe is None or price is None or growth <= 0 or fpe <= 0:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid growth ({growth}), Forward P/E ({fpe}), or price ({price}) value"
            return

        self.value = (8.5 + 2 * growth * 100) * price / fpe

        self.data_quality = stock_details.current_price.data_quality * stock_details.profit_growth_10_years.data_quality * stock_details.fpe.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"