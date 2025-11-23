from financial_metric import DEFAULT_QUALITY, FinancialMetric
import logging

logger = logging.getLogger(__name__)


class MarketCap(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "marketCap",
            0,
            "Total market capitalization based on current share price",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.debug(f"Loading data for marketCap metric for ticker {self.stock_details.ticker}")
        
        if 'marketCap' in self.yahoo_data:
            self.value = self.yahoo_data['marketCap']
            if self.value is None:
                self.value = 0.0
            self.data_quality = DEFAULT_QUALITY if self.value else 0.0  # High quality calculated value
            self.last_update = int(time.time())
            logger.info(f"{self.name} metric loaded successfully: value={self.value:.2f}, quality={self.data_quality:.2f}")
        else:
            logger.debug(f"marketCap data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
