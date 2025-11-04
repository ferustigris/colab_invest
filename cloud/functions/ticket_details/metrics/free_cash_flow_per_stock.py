from financial_metric import FinancialMetric


class FreeCashFlowPerStock(FinancialMetric):
    def __init__(self):
        super().__init__(
            "freeCashFlowPerStock",
            0,
            "Free cash flow divided by shares outstanding",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for free cash flow per stock metric for ticker {stock_details.ticker}")
        # Calculate FCF per share
        if 'freeCashflow' in yahoo_data and 'sharesOutstanding' in yahoo_data and yahoo_data['sharesOutstanding'] > 0:
            self.value = yahoo_data['freeCashflow'] / yahoo_data['sharesOutstanding']
            self.data_quality = 0.6  # Good quality calculated metric
            self.last_update = int(time.time())
            print(f"FreeCashFlowPerStock metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"freeCashflow or sharesOutstanding data not available for {stock_details.ticker}")
            self.data_quality = 0.0