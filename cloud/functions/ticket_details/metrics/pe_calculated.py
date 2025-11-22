from datetime import datetime, timedelta
from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)

class PeCalculated(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "pe",
            0,
            "Price-to-earnings ratio based on trailing twelve months",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")

        if self.yahoo_data.get('netIncomeToCommon') is None:
            logger.debug(f"netIncomeToCommon data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - netIncomeToCommon data not available\n"
            return
        if self.yahoo_data.get('sharesOutstanding') is None:
            logger.debug(f"sharesOutstanding data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - sharesOutstanding data not available\n"
            return
        if self.yahoo_data.get('currentPrice') is None:
            logger.debug(f"currentPrice data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += " - currentPrice data not available\n"
            return

        now = datetime.now()
    
        try:
            self.yahoo_data_last_update_dt = datetime.strptime(self.yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - self.yahoo_data_last_update_dt).days // 1 + 1)
            logger.debug(f"Successfully calculated data quality for {self.name}: {self.data_quality}")
        except ValueError:
            logger.debug(f"Invalid last update format for {self.name} metric: {self.yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += "\n - invalid last update format"
            return

        self.comment += "\n - last update on " + self.yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.value = round(self.yahoo_data['netIncomeToCommon'] / self.yahoo_data['sharesOutstanding'] / self.yahoo_data['currentPrice'] * 100)
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
