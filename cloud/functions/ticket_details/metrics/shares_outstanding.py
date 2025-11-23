from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class SharesOutstanding(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "sharesOutstanding",
            "Total number of shares currently outstanding",
            ["sharesOutstanding"],
            stock_details, yahoo_data)
