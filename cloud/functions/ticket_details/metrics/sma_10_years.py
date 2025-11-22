from financial_metric import FinancialMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Sma10Years(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "sma10Years",
            0,
            "10-year simple moving average indicating long-term trend",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        
        if not 'twoHundredDayAverage' in self.yahoo_data or self.yahoo_data['twoHundredDayAverage'] is None:
            logger.debug(f"twoHundredDayAverage data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.value = 0
            self.comment += "\n - twoHundredDayAverage data not available"
            return

        now = datetime.now()
    
        try:
            self.yahoo_data_last_update_dt = datetime.strptime(self.yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - self.yahoo_data_last_update_dt).days // 7 + 1)
            logger.debug(f"Successfully calculated data quality for {self.name}: {self.data_quality}")
        except ValueError:
            logger.debug(f"Invalid last update format for {self.name} metric: {self.yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = 0.1
            self.comment += "\n - invalid last update format"
            return

        self.comment += "\n - last update on " + self.yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.value = self.yahoo_data['twoHundredDayAverage']
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
