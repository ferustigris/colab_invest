from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class Ps(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "ps",
            "Price-to-sales ratio",
            ["ps"],
            stock_details, yahoo_data)
