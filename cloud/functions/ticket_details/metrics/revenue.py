from financial_metric import FinancialMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Revenue(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "revenue",
            0,
            "Total revenue for the last twelve months",
            0,
            "1970-01-01T00:00:00Z",
            stock_details,
            yahoo_data
        )
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        
        if not 'totalRevenue' in self.yahoo_data:
            logger.debug(f"totalRevenue data not available for {self.stock_details.ticker}")
            self.data_quality = 0.0
            self.comment += "\n - totalRevenue data not available"
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
        self.value = self.yahoo_data['totalRevenue']
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
