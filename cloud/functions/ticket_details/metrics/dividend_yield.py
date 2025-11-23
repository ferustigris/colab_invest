from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class DividendYield(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "dividendYield",
            "Dividend yield as percentage of current stock price",
            ["dividendYield"],
            stock_details, yahoo_data)
