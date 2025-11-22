from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class PriceForecastEquity(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "priceForecastEquity",
            0,
            "Price forecast based on equity valuation model",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        nta = self.stock_details.nta.value
        shares_outstanding = self.stock_details.shares.value

        if nta is None or shares_outstanding is None:
            logger.debug(f"NTA or shares outstanding not available for {self.stock_details.ticker}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += "\n - required data not available"
            return

        try:
            if shares_outstanding == 0:
                raise ZeroDivisionError("Shares outstanding is zero")
            self.value = nta / shares_outstanding
            self.data_quality = self.stock_details.nta.data_quality * self.stock_details.shares.data_quality
        except ZeroDivisionError:
            logger.debug(f"Shares outstanding is zero for ticker {self.stock_details.ticker}, cannot compute {self.name}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += "\n - shares outstanding is zero, cannot compute metric"
            return

        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
