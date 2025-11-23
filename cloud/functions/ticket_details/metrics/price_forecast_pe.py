from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class PriceForecastPE(FinancialMetric):
    def __init__(self, stock_details=None):
        super().__init__(
            "priceForecastPE",
            0,
            "Price forecast based on P/E ratio analysis",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, None)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        # Use forward EPS and target P/E for forecast
        # =(8,5+2*(POWER(C2; 1/10)-1)*100)*E2/P2
        growth = self.stock_details.profit_growth_10_years.value
        price = self.stock_details.current_price.value
        pe = self.stock_details.pe.value

        if growth is None or price is None or pe is None:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Missing required data: growth={growth}, price={price}, pe={pe}"
            return

        if growth <= 0 or pe <= 0:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid growth ({growth:.2f}) or P/E ({pe:.2f}) value"
            return

        self.value = (8.5 + 2 * growth * 100) * price / pe

        self.data_quality = self.stock_details.current_price.data_quality * self.stock_details.profit_growth_10_years.data_quality * self.stock_details.pe.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
