from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class Ebitda(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "ebitda",
            0,
            "Earnings before interest, taxes, depreciation, and amortization",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.info(f"Loading data for EBITDA metric for ticker {self.stock_details.ticker}")
        if 'ebitda' in self.yahoo_data:
            self.value = self.yahoo_data['ebitda']
            self.data_quality = 0.6  # Good quality financial statement data
            self.last_update = int(time.time())
            logger.info(f"Ebitda metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            logger.debug(f"ebitda data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
