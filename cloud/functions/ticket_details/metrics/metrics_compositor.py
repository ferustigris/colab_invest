from functools import reduce
from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class MetricsCompositor(FinancialMetric):
    def __init__(self, name, value, comment, data_quality, last_update, methods, stock_details=None, yahoo_data=None):
        super().__init__(
            name,
            value,
            comment,
            data_quality,
            last_update,
            stock_details,
            yahoo_data
        )

        self.methods = []
        for method in methods:
            if isinstance(method, MetricsCompositor):
                self.methods.extend(method.methods)
            else:
                self.methods.append(method)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        logger.info(f"Processing {len(self.methods)} methods for {self.name} metric")

        for metric in self.methods:
            metric.get_load_for_ticker()
            logger.debug(f"Method {metric.name} completed with quality={metric.data_quality}, value={metric.value}")

        valid_metrics = [metric for metric in self.methods if metric.data_quality > 0 and metric.value is not None]

        self.data_quality = reduce(lambda x, y: x * y, [metric.data_quality for metric in valid_metrics], 1.0) * len(valid_metrics) / len(self.methods)
        logger.debug(f"Initial data quality (product): {self.data_quality}")

        try:
            self.value = reduce(lambda x, y: x + y, [metric.value for metric in valid_metrics], 0) / len(valid_metrics)
            logger.debug(f"Average value: {self.value}")
        except ZeroDivisionError:
            logger.debug(f"No valid metrics available to compute average for {self.name}")
            self.value = 0
            self.data_quality = 0.0
            self.comment += "\n - no valid metrics available to compute average"
            return

        max_value = reduce(lambda x, y: max(x, y.value), valid_metrics, -1e9)
        min_value = reduce(lambda x, y: min(x, y.value), valid_metrics, 1e9)

        logger.debug(f"Max value among methods: {max_value}, Min value among methods: {min_value}")

        if max_value != 0:
            variance_factor = (min_value / max_value)
            logger.debug(f"Applying variance factor: {variance_factor}")
            self.data_quality *= variance_factor
            logger.debug(f"Final data quality after variance adjustment: {self.data_quality}")
        else:
            logger.debug("Max value is 0 - no variance adjustment applied")

        self.comment += "\n - last update on " + self.yahoo_data['lastUpdate']
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
        self.comment += f"\n - max {self.name} among methods: {max_value:.2f}, min {self.name} among methods: {min_value:.2f}"
        self.comment += f"\n - amount of valid methods used: {len(valid_metrics)}"
        
        # Add details for each child metric
        for metric in self.methods:
            value_str = f"{metric.value:.2f}" if metric.value is not None else "0.00"
            self.comment += f"\n - {metric.name}: value={value_str}, quality={metric.data_quality:.2f}"
        self.last_update = self.yahoo_data['lastUpdate']
        logger.info(f"{self.name} metric loaded successfully: value={self.value}, quality={self.data_quality}")

