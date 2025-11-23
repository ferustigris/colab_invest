from metrics.general_metric import GenericMetric
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class NetIncome(GenericMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "netIncome",
            "Net income after all expenses and taxes",
            ["netIncomeToCommon"],
            stock_details, yahoo_data)
    