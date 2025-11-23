import os
from general_utils import get_from_rest_or_cache_anonymous
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

        response_json = get_from_rest_or_cache_anonymous(f"{get_metric_url}/{self.stock_details.ticker}/{self.name}", headers={})

        self.value = response_json.get("value", 0)
        self.data_quality = response_json.get("dataQuality", 0  if self.value else 0.0)
        self.comment += "\n" + response_json.get("rawData", "No data available")
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.last_update = response_json.get("lastUpdate", "1970-01-01T00:00:00Z")
        
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")
