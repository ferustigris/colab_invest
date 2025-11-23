from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class TrailingAnnualDividendYield(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "trailingAnnualDividendYield",
            "Dividend yield as percentage of current stock price",
            ["trailingAnnualDividendYield"], 
            stock_details, yahoo_data)
