from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Sma10Years(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "sma10Years",
            "10-year simple moving average indicating long-term trend",
            ["sma"],
            stock_details, yahoo_data)
