from datetime import datetime, timedelta
from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class PeYahooStatic(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "pe",
            "Price-to-earnings ratio based on trailing twelve months",
            ["trailingPE"],
            stock_details, yahoo_data)
