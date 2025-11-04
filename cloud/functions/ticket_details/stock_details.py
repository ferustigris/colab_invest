from metrics.all_metrics import *


class StockDetails:
    def __init__(self, ticker):
        self.ticker = ticker
        self.name = f"Company {ticker}"
        self.summary = f"Summary about company {ticker}"
        
        # Financial metrics with initialized default values
        self.profit_growth_10_years = ProfitGrowth10Years()
        self.current_price = CurrentPrice()
        self.shares_outstanding = SharesOutstanding()
        self.sma_10_years = Sma10Years()
        self.price_forecast_div = PriceForecastDiv()
        self.price_forecast_pe = PriceForecastPE()
        self.price_forecast_equity = PriceForecastEquity()
        self.market_cap = MarketCap()
        self.revenue = Revenue()
        self.net_income = NetIncome()
        self.ebitda = Ebitda()
        self.nta = Nta()
        self.pe = Pe()
        self.fpe = Fpe()
        self.ps = Ps()
        self.ev_ebitda = EvEbitda()
        self.total_debt = TotalDebt()
        self.debt_ebitda = DebtEbitda()
        self.cash = Cash()
        self.dividend = Dividend()
        self.dividend_yield = DividendYield()
        self.free_cash_flow = FreeCashFlow()
        self.buyback = Buyback()
        self.buyback_percent = BuybackPercent()
        self.free_cash_flow_per_stock = FreeCashFlowPerStock()
    
    def to_json(self):
        return {
            "ticker": self.ticker,
            "name": self.name,
            "summary": self.summary,
            "profitGrowth10Years": self.profit_growth_10_years.to_json(),
            "currentPrice": self.current_price.to_json(),
            "sharesOutstanding": self.shares_outstanding.to_json(),
            "sma10Years": self.sma_10_years.to_json(),
            "priceForecastDiv": self.price_forecast_div.to_json(),
            "priceForecastPE": self.price_forecast_pe.to_json(),
            "priceForecastEquity": self.price_forecast_equity.to_json(),
            "marketCap": self.market_cap.to_json(),
            "revenue": self.revenue.to_json(),
            "netIncome": self.net_income.to_json(),
            "ebitda": self.ebitda.to_json(),
            "nta": self.nta.to_json(),
            "pe": self.pe.to_json(),
            "fpe": self.fpe.to_json(),
            "ps": self.ps.to_json(),
            "evEbitda": self.ev_ebitda.to_json(),
            "totalDebt": self.total_debt.to_json(),
            "debtEbitda": self.debt_ebitda.to_json(),
            "cash": self.cash.to_json(),
            "dividend": self.dividend.to_json(),
            "dividendYield": self.dividend_yield.to_json(),
            "freeCashFlow": self.free_cash_flow.to_json(),
            "buyback": self.buyback.to_json(),
            "buybackPercent": self.buyback_percent.to_json(),
            "freeCashFlowPerStock": self.free_cash_flow_per_stock.to_json()
        }