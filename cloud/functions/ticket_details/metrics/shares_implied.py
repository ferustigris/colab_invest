from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class SharesImplied(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "sharesImplied",
            "Total number of shares implied oustanding",
            ["impliedSharesOutstanding"],
            stock_details, yahoo_data)
