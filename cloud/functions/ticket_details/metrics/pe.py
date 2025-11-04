from datetime import datetime, timedelta
from functools import reduce
from metrics.metrics_compositor import MetricsCompositor
from metrics.pe_calculated import PeCalculated
from metrics.pe_yahoo_static import PeYahooStatic


class Pe(MetricsCompositor):
    def __init__(self):
        super().__init__(
            "pe",
            0,
            "Price-to-earnings ratio based on trailing twelve months",
            0,
            "1970-01-01T00:00:00Z",
            [
                PeCalculated(),
                PeYahooStatic()
            ]
        )
