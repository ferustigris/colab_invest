from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Revenue(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "revenue",
            "Total revenue for the last twelve months",
            ["totalRevenue"],
            stock_details,
            yahoo_data
        )
