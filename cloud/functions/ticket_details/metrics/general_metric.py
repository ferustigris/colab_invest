from financial_metric import LOW_QUALITY, FinancialMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class GenericMetric(FinancialMetric):
    def __init__(self, name: str, comment: str, possible_keys: list[str], stock_details=None, yahoo_data=None):
        super().__init__(
            name,
            0,
            comment,
            0,
            "1970-01-01T00:00:00Z", 
            stock_details, yahoo_data)
        self.possible_keys = possible_keys
    
    def get_load_for_ticker(self):
        logger.debug(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        

        for key in self.possible_keys:
            if key in self.yahoo_data:
                self.value = self.yahoo_data[key]
                break
        if self.value is None:
            logger.warning(f"{self.possible_keys} data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - metrics is not available"
            self.value = 0.0
            return

        now = datetime.now()
    
        try:
            self.yahoo_data_last_update_dt = datetime.strptime(self.yahoo_data['lastUpdate'], "%Y-%m-%dT%H:%M:%SZ")
            now = datetime.now()
            self.data_quality = 1.0/((now - self.yahoo_data_last_update_dt).days // 7 + 1) if self.value else 0.0
            logger.debug(f"Successfully calculated data quality for {self.name}: {self.data_quality:.2f}")
        except ValueError:
            logger.warning(f"Invalid last update format for {self.name} metric: {self.yahoo_data.get('lastUpdate', 'N/A')}")
            self.data_quality = LOW_QUALITY
            self.comment += "\n - invalid last update format"
            return
        self.comment += "\n - last update on " + self.yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value:.2f}, quality={self.data_quality:.2f}")
