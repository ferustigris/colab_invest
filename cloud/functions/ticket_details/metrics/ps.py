from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class Ps(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "ps",
            0,
            "Price-to-sales ratio",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.info(f"Loading data for price-to-sales metric for ticker {self.stock_details.ticker}")
        if 'priceToSalesTrailing12Months' in self.yahoo_data:
            self.value = self.yahoo_data['priceToSalesTrailing12Months']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            logger.debug(f"priceToSalesTrailing12Months data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
