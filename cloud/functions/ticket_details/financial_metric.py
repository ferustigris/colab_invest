class FinancialMetric:
    def __init__(self, name, value, comment, data_quality, last_update):
        self.name = name
        self.value = value
        self.comment = comment
        self.data_quality = data_quality
        self.last_update = last_update
    
    def to_json(self):
        # print(f"Serializing {self.name} metric to JSON")
        return {
            "name": self.name,
            "value": self.value,
            "comment": self.comment,
            "dataQuality": self.data_quality,
            "lastUpdate": self.last_update
        }
    
    def get_load_for_ticker(self, ticker_data, json_yahoo_data):
        """
        Load financial metric data for a specific ticker from JSON data
        """
        # This method can be used to populate the metric from external data sources
        # For now, it's a placeholder that could be implemented to parse real financial data
        pass