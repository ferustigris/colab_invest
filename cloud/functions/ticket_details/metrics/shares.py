from datetime import datetime, timedelta
from functools import reduce
from metrics.metrics_compositor import MetricsCompositor
from metrics.shares_implied import SharesImplied
from metrics.shares_implied_calculated import SharesImpliedCalculated
from metrics.shares_outstanding import SharesOutstanding


class Shares(MetricsCompositor):
    def __init__(self):
        super().__init__(
            "Shares",
            0,
            "Total number of shares outstanding from various sources",
            0,
            "1970-01-01T00:00:00Z",
            [
                SharesImplied(),
                SharesImpliedCalculated(),
                SharesOutstanding()
            ]
        )
