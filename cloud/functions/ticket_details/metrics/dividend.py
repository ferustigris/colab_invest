from datetime import datetime, timedelta
from functools import reduce
from metrics.metrics_compositor import MetricsCompositor
from metrics.dividend_yield import DividendYield
from metrics.dividend_yield_annual import TrailingAnnualDividendYield
from metrics.dividend_yield_5years_avg import FiveYearAvgDividendYield
from metrics.dividend_yield_forward import ForwardAnnualDividendYield

class Dividend(MetricsCompositor):
    def __init__(self):
        super().__init__(
            "dividend",
            0,
            "Dividend-related metrics",
            0,
            "1970-01-01T00:00:00Z",
            [
                DividendYield(),
                TrailingAnnualDividendYield(),
                FiveYearAvgDividendYield(),
                ForwardAnnualDividendYield()
            ]
        )
