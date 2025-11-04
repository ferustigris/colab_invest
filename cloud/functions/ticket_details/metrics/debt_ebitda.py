from financial_metric import FinancialMetric


class DebtEbitda(FinancialMetric):
    def __init__(self):
        super().__init__(
            "debtEbitda",
            0,
            "Debt-to-EBITDA ratio indicating leverage",
            0,
            "1970-01-01T00:00:00Z"
        )
    
    def get_load_for_ticker(self, stock_details, yahoo_data):
        import time
        print(f"Loading data for debt EBITDA metric for ticker {stock_details.ticker}")
        # Calculate debt-to-EBITDA ratio
        if 'totalDebt' in yahoo_data and 'ebitda' in yahoo_data and yahoo_data['ebitda'] > 0:
            self.value = yahoo_data['totalDebt'] / yahoo_data['ebitda']
            self.data_quality = 0.6  # Good quality calculated ratio
            self.last_update = int(time.time())
            print(f"DebtEbitda metric loaded successfully: value={self.value}, quality={self.data_quality}")
        else:
            print(f"totalDebt or ebitda data not available for {stock_details.ticker}")
            self.data_quality = 0.0