from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class PriceForecastFPE(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "priceForecastFPE",
            0,
            "Price forecast based on Forward P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        # Use forward EPS and target P/E for forecast
        # =(8,5+2*(POWER(C2; 1/10)-1)*100)*E2/P2
        # (8.5 + 2 * (pow(growth, 1/10) - 1) * 100) * price * fpe
        growth = self.stock_details.profit_growth_10_years.value
        price = self.stock_details.current_price.value
        fpe = self.stock_details.fpe.value

        if growth is None or fpe is None or price is None or growth <= 0 or fpe <= 0:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid growth ({growth}), Forward P/E ({fpe}), or price ({price}) value"
            return

        self.value = (8.5 + 2 * growth * 100) * price / fpe

        self.data_quality = self.stock_details.current_price.data_quality * self.stock_details.profit_growth_10_years.data_quality * self.stock_details.fpe.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
