import logging

logger = logging.getLogger(__name__)

DEFAULT_QUALITY = 0.6
LOW_QUALITY = 0.1
QUALITY_THREASHOLD = 0.5

class FinancialMetric:
    def __init__(self, name, value, comment, data_quality, last_update, stock_details=None, yahoo_data=None):
        self.name = name
        self.value = value
        self.comment = comment
        self.data_quality = data_quality
        self.last_update = last_update
        self.stock_details = stock_details
        self.yahoo_data = yahoo_data
    
    def to_json(self):
        return {
            "name": self.name,
            "value": self.value,
            "comment": self.comment,
            "dataQuality": self.data_quality,
            "lastUpdate": self.last_update
        }
    
    def get_load_for_ticker(self):
        """
        Load financial metric data for a specific ticker from stored data.
        Override this method in subclasses to implement specific loading logic.
        """
        pass
