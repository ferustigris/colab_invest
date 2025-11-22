import os
import requests
from metrics.ai_metric import AiMetric
import logging

logger = logging.getLogger(__name__)


class Buyback(AiMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "AnnualAvgBuybackInUsd",
            0,
            "Total amount spent on share buybacks in last twelve months",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
