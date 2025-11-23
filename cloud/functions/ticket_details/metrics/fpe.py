from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class Fpe(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "fpe",
            "Forward price-to-earnings ratio based on next year estimates",
            ["forwardPE"],
            stock_details, yahoo_data)
