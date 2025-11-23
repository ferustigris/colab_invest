from metrics.general_metric import GenericMetric
from financial_metric import LOW_QUALITY
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Cash(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "cash",
            "Cash and cash equivalents on balance sheet",
            ["totalCash", "freeCashflow"], 
            stock_details, yahoo_data)
