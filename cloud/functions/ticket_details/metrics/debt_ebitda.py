from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class DebtEbitda(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "debtEbitda",
            0,
            "Debt-to-EBITDA ratio indicating leverage",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.info(f"Loading data for debt EBITDA metric for ticker {self.stock_details.ticker}")
        # Calculate debt-to-EBITDA ratio
        if ('totalDebt' in self.yahoo_data and self.yahoo_data['totalDebt'] is not None and
            'ebitda' in self.yahoo_data and self.yahoo_data['ebitda'] is not None and 
            self.yahoo_data['ebitda'] > 0):
            self.value = self.yahoo_data['totalDebt'] / self.yahoo_data['ebitda']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            logger.info(f"DebtEbitda metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            logger.debug(f"totalDebt or ebitda data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
