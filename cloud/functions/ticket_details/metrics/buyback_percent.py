import os
import requests
from financial_metric import FinancialMetric


class BuybackPercent(FinancialMetric):
    def __init__(self):
        super().__init__(
            "buybackPercent",
            0,
            "Percentage of shares bought back relative to outstanding shares",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        get_metric_url = os.environ.get("GET_METRIC_URL")
        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(f"{get_metric_url}/{stock_details.ticker}", headers=headers, json={
            "metric": self.name
        })
        response.raise_for_status()

        self.value = response.text
        self.data_quality = 0.7
