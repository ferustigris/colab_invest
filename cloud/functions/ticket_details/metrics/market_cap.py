from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class MarketCap(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "marketCap",
            "Total market capitalization based on current share price",
            ["marketCap"],
            stock_details, yahoo_data)
