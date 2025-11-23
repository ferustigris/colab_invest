from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class ForwardAnnualDividendYield(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "forwardAnnualDividendYield",
            "Forward dividend yield as percentage of current stock price",
            ["forwardAnnualDividendYield"],
            stock_details, yahoo_data)
