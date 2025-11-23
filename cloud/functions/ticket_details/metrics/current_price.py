from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class CurrentPrice(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "currentPrice",
            "Real-time market price as of latest trading session",
            ["currentPrice"],
            stock_details,
            yahoo_data
        )
