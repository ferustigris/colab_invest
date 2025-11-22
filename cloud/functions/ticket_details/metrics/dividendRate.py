from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class Dividend(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "dividend",
            0,
            "Annual dividend per share",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.info(f"Loading data for dividend metric for ticker {self.stock_details.ticker}")
        if 'dividendRate' in self.yahoo_data:
            self.value = self.yahoo_data['dividendRate']
            self.data_quality = 0.6  # Good quality dividend data
            self.last_update = int(time.time())
            logger.info(f"Dividend metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            logger.debug(f"dividendRate data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
