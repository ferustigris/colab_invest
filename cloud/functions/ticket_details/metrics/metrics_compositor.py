from functools import reduce
from financial_metric import FinancialMetric


class MetricsCompositor(FinancialMetric):
    def __init__(self, name, value, comment, data_quality, last_update, methods):
        super().__init__(
            name,
            value,
            comment,
            data_quality,
            last_update
        )

        self.methods = methods
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        print(f"Loading data for {self.name} metric for ticker {stock_details.ticker}")
        print(f"Processing {len(self.methods)} methods for {self.name} metric")

        for metric in self.methods:
            metric.get_load_for_ticker(stock_details, yahoo_data)
            print(f"Method {metric.name} completed with quality={metric.data_quality}, value={metric.value}")

        valid_metrics = [metric for metric in self.methods if metric.data_quality > 0]

        self.data_quality = reduce(lambda x, y: x * y, [metric.data_quality for metric in valid_metrics], 1.0)
        print(f"Initial data quality (product): {self.data_quality}")
        
        self.value = reduce(lambda x, y: x + y, [metric.value for metric in valid_metrics], 0) / len(valid_metrics)
        print(f"Average value: {self.value}")

        max_value = reduce(lambda x, y: max(x, y.value), valid_metrics, -1e9)
        min_value = reduce(lambda x, y: min(x, y.value), valid_metrics, 1e9)

        print(f"Max value among methods: {max_value}, Min value among methods: {min_value}")

        if max_value != 0:
            variance_factor = (min_value / max_value)
            print(f"Applying variance factor: {variance_factor}")
            self.data_quality *= variance_factor
            print(f"Final data quality after variance adjustment: {self.data_quality}")
        else:
            print("Max value is 0 - no variance adjustment applied")

        self.comment += "\n - last update on " + yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.comment += f"\n - max {self.name} among methods: {max_value}, min {self.name} among methods: {min_value}"
        self.comment += f"\n - amount of valid methods used: {len(valid_metrics)}"
        
        # Add details for each child metric
        for metric in self.methods:
            self.comment += f"\n - {metric.name}: value={metric.value}, quality={metric.data_quality:.2f}"
        self.last_update = yahoo_data['lastUpdate']
        print(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")

