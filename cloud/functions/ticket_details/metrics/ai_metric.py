import os
import requests
from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class AiMetric(FinancialMetric):
    def __init__(self, name, value, comment, data_quality, last_update, stock_details=None, yahoo_data=None):
        super().__init__(
            name,
            value,
            comment,
            data_quality,
            last_update,
            stock_details,
            yahoo_data
        )
    
    def get_load_for_ticker(self):
        get_metric_url = os.environ.get("GET_METRIC_URL")

        response = requests.post(f"{get_metric_url}/{self.stock_details.ticker}/{self.name}")
        response.raise_for_status()

        self.value = response.json().get("value", 0)
        self.data_quality = response.json().get("dataQuality", 0)
        self.comment += "\n" + response.json().get("rawData", "No data available")
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.last_update = response.json().get("lastUpdate", "1970-01-01T00:00:00Z")
        
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
