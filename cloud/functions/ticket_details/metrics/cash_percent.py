from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class CashPercent(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "cashPercent",
            0,
            "Percentage of cash relative to capitalization",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.debug(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        cash = self.stock_details.cash.value
        market_cap = self.stock_details.market_cap.value

        if cash is None or market_cap is None:
            logger.debug(f"Missing data for {self.name}: cash={cash}, market_cap={market_cap}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Missing cash ({cash}) or market cap ({market_cap})"
            return

        try:
            self.value = cash / market_cap
            self.data_quality = self.stock_details.cash.data_quality * self.stock_details.market_cap.data_quality
        except ZeroDivisionError:
            logger.warning(f"Shares outstanding is zero for ticker {self.stock_details.ticker}, cannot compute {self.name}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += "\n - shares outstanding is zero, cannot compute metric"
            return

        self.data_quality = self.stock_details.cash.data_quality * self.stock_details.market_cap.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
