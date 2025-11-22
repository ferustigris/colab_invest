# Import all metric classes from individual files
from metrics.profit_growth_10_years import ProfitGrowth10Years
from metrics.current_price import CurrentPrice
from metrics.shares import Shares
from metrics.sma_10_years import Sma10Years
from metrics.price_forecast_div import PriceForecastDiv
from metrics.price_forecast_div_buyback import PriceForecastDivBuyback
from metrics.price_forecast_pe import PriceForecastPE
from metrics.price_forecast_fpe import PriceForecastFPE
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
        self.currency = "USD"
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
        self.price_forecast_div_buyback = PriceForecastDivBuyback()
        self.price_forecast_pe = PriceForecastPE()
        self.price_forecast_fpe = PriceForecastFPE()
        self.price_forecast_equity = PriceForecastEquity()

    def to_json(self):
        print(f"Starting to_json() for ticker: {self.ticker}")
        
        def serialize_value(obj):
            """Helper function to handle complex numbers and other non-serializable objects"""
            # print(f"Serializing object of type: {type(obj).__name__}")
            if isinstance(obj, complex):
                print(f"Found complex number: {str(obj)}, converting to string")
                return str(obj)
            elif hasattr(obj, 'to_json'):
                # print(f"Object has to_json method, calling it")
                result = obj.to_json()
                return result
            else:
                return obj
        
        print("Building JSON dictionary...")
        result = {
            "ticker": self.ticker,
            "currency": self.currency,
            "name": self.name,
            "summary": self.summary,
            "profitGrowth10Years": serialize_value(self.profit_growth_10_years),
            "currentPrice": serialize_value(self.current_price),
            "shares": serialize_value(self.shares),
            "sma10Years": serialize_value(self.sma_10_years),
            "priceForecastDiv": serialize_value(self.price_forecast_div),
            "priceForecastDivBuyback": serialize_value(self.price_forecast_div_buyback),
            "priceForecastPE": serialize_value(self.price_forecast_pe),
            "priceForecastFPE": serialize_value(self.price_forecast_fpe),
            "priceForecastEquity": serialize_value(self.price_forecast_equity),
            "marketCap": serialize_value(self.market_cap),
            "revenue": serialize_value(self.revenue),
            "netIncome": serialize_value(self.net_income),
            # "ebitda": serialize_value(self.ebitda),
            "nta": serialize_value(self.nta),
            "pe": serialize_value(self.pe),
            "fpe": serialize_value(self.fpe),
            # "ps": serialize_value(self.ps),
            # "evEbitda": serialize_value(self.ev_ebitda),
            "totalDebt": serialize_value(self.total_debt),
            # "debtEbitda": serialize_value(self.debt_ebitda),
            "cash": serialize_value(self.cash),
            "dividend": serialize_value(self.dividend),
            "freeCashFlow": serialize_value(self.free_cash_flow),
            "buyback": serialize_value(self.buyback),
            "buybackPercent": serialize_value(self.buyback_percent),
            # "freeCashFlowPerStock": serialize_value(self.free_cash_flow_per_stock)
        }
        
        print(f"Completed to_json() for ticker: {self.ticker}, result keys: {result}")
        return result
    
    def update_from_yahoo_data(self, yahoo_data):
        """
        Update financial metrics from Yahoo data
        """
        print(f"Updating StockDetails for ticker: {self.ticker} from Yahoo data")
        import requests
        
        self.name = yahoo_data.get("longName", self.name)
        self.currency = yahoo_data.get("currency", "USD")
        
        # Create array of all metric objects
        metrics = [
            self.profit_growth_10_years,
            self.current_price,
            self.shares,
            self.sma_10_years,
            self.market_cap,
            self.revenue,
            self.net_income,
            self.ebitda,
            self.nta,
            self.pe,
            self.fpe,
            self.ps,
            self.ev_ebitda,
            self.total_debt,
            self.debt_ebitda,
            self.cash,
            self.dividend,
            self.free_cash_flow,
            self.buyback,
            self.free_cash_flow_per_stock
        ]
        
        # Process all basic metrics
        for metric in metrics:
            try:
                metric.get_load_for_ticker(self, yahoo_data)
                # print(f"Successfully loaded metric: {metric.__class__.__name__}")
            except (requests.exceptions.HTTPError, ValueError, TypeError) as e:
                print(f"Error loading metric {metric.__class__.__name__}: {e}")
                continue
        
        # Process computed price forecasts (these depend on previously loaded metrics)
        # The order here matters if there are dependencies among the forecasts
        forecast_metrics = [
            self.buyback_percent,
            self.price_forecast_div,
            self.price_forecast_div_buyback,
            self.price_forecast_pe,
            self.price_forecast_fpe,
            self.price_forecast_equity
        ]
        
        for metric in forecast_metrics:
            try:
                metric.get_load_for_ticker(self, yahoo_data)
                # print(f"Successfully loaded forecast metric: {metric.__class__.__name__}")
            except (requests.exceptions.HTTPError, ValueError, TypeError) as e:
                print(f"Error loading forecast metric {metric.__class__.__name__}: {e}")
                continue
        