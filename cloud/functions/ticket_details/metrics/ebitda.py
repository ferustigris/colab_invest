from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class Ebitda(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "ebitda",
            "Earnings before interest, taxes, depreciation, and amortization",
            ["ebitda"],
            stock_details, yahoo_data)
