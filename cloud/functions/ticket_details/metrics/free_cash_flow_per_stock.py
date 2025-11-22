from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class FreeCashFlowPerStock(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "freeCashFlowPerStock",
            0,
            "Free cash flow divided by shares outstanding",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        import time
        logger.info(f"Loading data for free cash flow per stock metric for ticker {self.stock_details.ticker}")
        # Calculate FCF per share
        free_cashflow = self.yahoo_data.get('freeCashflow')
        shares_outstanding = self.yahoo_data.get('sharesOutstanding')
        
        if (free_cashflow is not None and 
            shares_outstanding is not None and 
            isinstance(shares_outstanding, (int, float)) and 
            shares_outstanding > 0):
            self.value = free_cashflow / shares_outstanding
            self.data_quality = 0.6  # Good quality calculated metric
            self.last_update = int(time.time())
            logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            logger.debug(f"freeCashflow or sharesOutstanding data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
