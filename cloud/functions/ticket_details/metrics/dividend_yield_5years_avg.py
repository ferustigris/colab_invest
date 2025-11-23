from metrics.general_metric import GenericMetric
import logging

logger = logging.getLogger(__name__)


class FiveYearAvgDividendYield(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "fiveYearAvgDividendYield",
            "Dividend yield as percentage of current stock price",
            ["fiveYearAvgDividendYield"], 
            stock_details, yahoo_data)
