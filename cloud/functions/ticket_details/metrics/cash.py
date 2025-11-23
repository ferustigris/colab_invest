from financial_metric import LOW_QUALITY, FinancialMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Cash(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "cash",
            0,
            "Cash and cash equivalents on balance sheet",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        
        if 'totalCash' in self.yahoo_data:
            self.value = self.yahoo_data['totalCash']
        elif 'freeCashflow' in self.yahoo_data:
            self.value = self.yahoo_data['freeCashflow']
        else:
            logger.debug(f"totalCash data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - totalCash or freeCashflow data not available"
            return
        if self.value is None:
            self.value = 0.0

        now = datetime.now()
    
        try:
            self.yahoo_data_last_update_dt = datetime.strptime(self.yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - self.yahoo_data_last_update_dt).days // 7 + 1) if self.value else 0.0
            logger.debug(f"Successfully calculated data quality for {self.name}: {self.data_quality:.2f}")
        except ValueError:
            logger.debug(f"Invalid last update format for {self.name} metric: {self.yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = LOW_QUALITY
            self.comment += "\n - invalid last update format"
            return
        self.comment += "\n - last update on " + self.yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value:.2f}, quality={self.data_quality:.2f}")
