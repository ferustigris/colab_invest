# Import all metric classes from individual files
from metrics.profit_growth_10_years import ProfitGrowth10Years
from metrics.current_price import CurrentPrice
from metrics.shares import Shares
from metrics.sma_10_years import Sma10Years
from metrics.price_forecast_div import PriceForecastDiv
from metrics.price_forecast_pe import PriceForecastPE
from metrics.price_forecast_equity import PriceForecastEquity
from metrics.market_cap import MarketCap
from metrics.revenue import Revenue
from metrics.net_income import NetIncome
from metrics.ebitda import Ebitda
from metrics.nta import Nta
from metrics.pe import Pe
from metrics.fpe import Fpe
from metrics.ps import Ps
from metrics.ev_ebitda import EvEbitda
from metrics.total_debt import TotalDebt
from metrics.debt_ebitda import DebtEbitda
from metrics.cash import Cash
from metrics.dividend import Dividend
from metrics.free_cash_flow import FreeCashFlow
from metrics.buyback import Buyback
from metrics.buyback_percent import BuybackPercent
from metrics.free_cash_flow_per_stock import FreeCashFlowPerStock


class StockDetails:
    def __init__(self, ticker):
        self.ticker = ticker
        self.name = f"Company {ticker}"
        self.summary = f"Summary about company {ticker}"
        
        # Financial metrics with initialized default values
        self.profit_growth_10_years = ProfitGrowth10Years()
        self.current_price = CurrentPrice()
        self.shares = Shares()
        self.sma_10_years = Sma10Years()
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
        self.free_cash_flow = FreeCashFlow()
        self.buyback = Buyback()
        self.buyback_percent = BuybackPercent()
        self.free_cash_flow_per_stock = FreeCashFlowPerStock()
        # Computed price forecasts
        self.price_forecast_div = PriceForecastDiv()
        self.price_forecast_pe = PriceForecastPE()
        self.price_forecast_equity = PriceForecastEquity()

    def to_json(self):
        return {
            "ticker": self.ticker,
            "name": self.name,
            "summary": self.summary,
            "profitGrowth10Years": self.profit_growth_10_years.to_json(),
            "currentPrice": self.current_price.to_json(),
            "shares": self.shares.to_json(),
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
            "freeCashFlow": self.free_cash_flow.to_json(),
            "buyback": self.buyback.to_json(),
            "buybackPercent": self.buyback_percent.to_json(),
            "freeCashFlowPerStock": self.free_cash_flow_per_stock.to_json()
        }
    
    def update_from_yahoo_data(self, yahoo_data):
        """
        Update financial metrics from Yahoo data
        """
        self.profit_growth_10_years.get_load_for_ticker(self, yahoo_data)
        self.current_price.get_load_for_ticker(self, yahoo_data)
        self.shares.get_load_for_ticker(self, yahoo_data)
        self.sma_10_years.get_load_for_ticker(self, yahoo_data)
        self.market_cap.get_load_for_ticker(self, yahoo_data)
        self.revenue.get_load_for_ticker(self, yahoo_data)
        self.net_income.get_load_for_ticker(self, yahoo_data)
        self.ebitda.get_load_for_ticker(self, yahoo_data)
        self.nta.get_load_for_ticker(self, yahoo_data)
        self.pe.get_load_for_ticker(self, yahoo_data)
        self.fpe.get_load_for_ticker(self, yahoo_data)
        self.ps.get_load_for_ticker(self, yahoo_data)
        self.ev_ebitda.get_load_for_ticker(self, yahoo_data)
        self.total_debt.get_load_for_ticker(self, yahoo_data)
        self.debt_ebitda.get_load_for_ticker(self, yahoo_data)
        self.cash.get_load_for_ticker(self, yahoo_data)
        self.dividend.get_load_for_ticker(self, yahoo_data)
        self.free_cash_flow.get_load_for_ticker(self, yahoo_data)
        self.buyback.get_load_for_ticker(self, yahoo_data)
        self.buyback_percent.get_load_for_ticker(self, yahoo_data)
        self.free_cash_flow_per_stock.get_load_for_ticker(self, yahoo_data)
        # Compute price forecasts based on previously loaded metrics
        self.price_forecast_div.get_load_for_ticker(self, yahoo_data)
        self.price_forecast_pe.get_load_for_ticker(self, yahoo_data)
        self.price_forecast_equity.get_load_for_ticker(self, yahoo_data)
        